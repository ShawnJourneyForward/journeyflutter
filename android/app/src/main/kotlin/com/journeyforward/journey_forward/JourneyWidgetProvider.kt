package com.journeyforward.journey_forward

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import org.json.JSONObject
import java.util.concurrent.TimeUnit

/**
 * Home-screen widget for Journey Forward.
 *
 * Shows the user's current sober streak (computed from the encrypted profile's
 * soberDate) and a single tap target. Tap → opens the app at /home; we use
 * the launcher intent rather than a custom deep link because the existing
 * router redirect handles "lock screen first" correctly.
 *
 * Data path:
 *   - Flutter writes `flutter.has_profile` and `flutter.profile_sober_date`
 *     to SharedPreferences (FlutterSharedPreferences) on profile save.
 *   - This widget reads those keys directly. We never touch encrypted_storage
 *     from native — the soberDate is non-sensitive (it's also displayed on
 *     the lock screen via the streak counter), so plain prefs is appropriate.
 *
 * BUILD NOTES:
 *   - Register in AndroidManifest.xml with android:resource pointing to
 *     res/xml/journey_widget_info.xml.
 *   - The Flutter side must mirror profile.soberDate into SharedPreferences
 *     under the key `profile_sober_date` (already done by ProfileNotifier
 *     via the shared_preferences plugin — the plugin namespaces keys with
 *     `flutter.` so we read `flutter.profile_sober_date`).
 *   - Call AppWidgetManager.requestPinAppWidget() from a Settings → Widget
 *     row if you want one-tap install.
 */
class JourneyWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            renderWidget(context, appWidgetManager, id)
        }
    }

    /** Convenience for external "data changed" notifications. */
    companion object {
        fun refreshAll(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(
                ComponentName(context, JourneyWidgetProvider::class.java)
            )
            for (id in ids) renderWidget(context, mgr, id)
        }

        private fun renderWidget(
            context: Context,
            mgr: AppWidgetManager,
            widgetId: Int,
        ) {
            val views = RemoteViews(context.packageName, R.layout.journey_widget)

            val days = computeSoberDays(context)
            views.setTextViewText(
                R.id.widget_day_count,
                if (days < 0) "—" else days.toString()
            )
            views.setTextViewText(
                R.id.widget_label,
                if (days == 1L) "day sober" else "days sober"
            )

            // Tap target — opens the launcher activity, which routes through
            // the same lock-screen logic the user gets when they tap the icon.
            val openIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
                ?: Intent()
            val pi = PendingIntent.getActivity(
                context,
                0,
                openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pi)

            mgr.updateAppWidget(widgetId, views)
        }

        private fun computeSoberDays(context: Context): Long {
            val prefs: SharedPreferences = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )
            // shared_preferences plugin namespaces keys with `flutter.`
            val profileBlob = prefs.getString("flutter.profile", null)
                ?: prefs.getString("flutter.profile_sober_date", null)
                ?: return -1L

            val soberDateIso: String? = try {
                // Older builds stored the profile as a raw JSON string.
                val obj = JSONObject(profileBlob)
                obj.optString("soberDate", "")
                    .takeIf { it.isNotEmpty() }
                    ?: profileBlob
            } catch (_: Throwable) {
                profileBlob
            }
            if (soberDateIso.isNullOrEmpty()) return -1L

            val soberMillis = parseIsoMillis(soberDateIso) ?: return -1L
            val elapsed = System.currentTimeMillis() - soberMillis
            if (elapsed < 0) return 0L
            return TimeUnit.MILLISECONDS.toDays(elapsed)
        }

        private fun parseIsoMillis(iso: String): Long? = try {
            java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", java.util.Locale.US)
                .apply { timeZone = java.util.TimeZone.getTimeZone("UTC") }
                .parse(iso)?.time
        } catch (_: Throwable) {
            // Fall back to a permissive parser.
            try {
                Uri.parse(iso).toString() // dummy use to keep import
                java.text.SimpleDateFormat("yyyy-MM-dd", java.util.Locale.US)
                    .parse(iso.substring(0, 10).coerceAtMost(iso))?.time
            } catch (_: Throwable) {
                null
            }
        }
    }
}
