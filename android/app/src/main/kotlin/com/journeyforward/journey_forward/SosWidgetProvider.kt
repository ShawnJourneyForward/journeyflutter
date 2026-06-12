package com.journeyforward.journey_forward

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

/**
 * SOS home-screen widget — one tap from the home screen straight into the
 * "Ride the Wave" urge timer (/urge-timer), skipping Home entirely.
 *
 * The route travels as an Intent extra ([MainActivity.EXTRA_ROUTE]); the Dart
 * side drains it via the com.journeyforward/widget_route channel and only
 * ever honours the exact /urge-timer value, so the extra is not a general
 * navigation surface. /urge-timer is allow-listed by the router's LockGate —
 * it shows nothing private, so no PIN/biometric stands between a craving and
 * the timer.
 *
 * Request code 100 keeps this PendingIntent distinct from the streak
 * widget's (request code 0) — both target the launcher activity, and with a
 * shared request code FLAG_UPDATE_CURRENT would clobber one with the other.
 */
class SosWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.sos_widget)

            val openIntent = (context.packageManager
                .getLaunchIntentForPackage(context.packageName) ?: Intent())
                .apply { putExtra(MainActivity.EXTRA_ROUTE, "/urge-timer") }
            val pi = PendingIntent.getActivity(
                context,
                100,
                openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.sos_root, pi)

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
