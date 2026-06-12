package com.journeyforward.journey_forward

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    companion object {
        /** Intent extra carrying a target route from a home-screen widget. */
        const val EXTRA_ROUTE = "open_route"
    }

    private val secureWindowChannel = "com.journeyforward/secure_window"
    private val appSettingsChannel = "com.journeyforward/app_settings"
    private val batteryChannel = "com.journeyforward/battery_opt"
    private val widgetRouteChannel = "com.journeyforward/widget_route"

    /** Route requested by a widget tap, drained once by the Dart side. */
    private var pendingRoute: String? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Warm start: the SOS widget re-delivers its intent here.
        intent.getStringExtra(EXTRA_ROUTE)?.let { pendingRoute = it }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Widget-route bridge — see _consumeWidgetRoute() in lib/main.dart.
        // The Dart side polls at first frame and on every resume; the value
        // is cleared on read so a route fires exactly once.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, widgetRouteChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "takePendingRoute" -> {
                        val route = pendingRoute ?: intent?.getStringExtra(EXTRA_ROUTE)
                        pendingRoute = null
                        intent?.removeExtra(EXTRA_ROUTE)
                        result.success(route)
                    }
                    else -> result.notImplemented()
                }
            }

        // FLAG_SECURE bridge — see lib/utils/secure_window.dart. Sensitive
        // screens call enable()/disable() to block screenshots, screen
        // recording, and the Recents thumbnail rendering of the window.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, secureWindowChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enable" -> {
                        window.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE
                        )
                        result.success(null)
                    }
                    "disable" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }



        // Battery-optimization diagnostics bridge ? policy-safe. This only
        // checks current status and opens Android's general battery settings;
        // it does NOT request the restricted ignore-battery-optimizations
        // permission.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, batteryChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isIgnoringBatteryOptimizations" -> {
                        try {
                            val pm = getSystemService(POWER_SERVICE) as android.os.PowerManager
                            result.success(pm.isIgnoringBatteryOptimizations(packageName))
                        } catch (e: Exception) {
                            result.error("BATTERY_OPT_CHECK_FAILED", e.message, null)
                        }
                    }
                    "openBatteryOptimizationSettings" -> {
                        try {
                            val intent = Intent(
                                Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
                            ).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("BATTERY_OPT_SETTINGS_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // App-settings bridge — see lib/utils/notification_service.dart.
        // Lets the Notifications sheet jump the user straight to system
        // settings when POST_NOTIFICATIONS has been denied. Without this,
        // a denied user has no in-app recovery path — Android 13+ will not
        // re-show the runtime prompt after the first denial.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appSettingsChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openNotificationSettings" -> {
                        try {
                            val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                // O+ (API 26+) supports the dedicated
                                // per-app notification settings screen.
                                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                            } else {
                                // Fallback: open the per-app details screen.
                                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                    data = Uri.parse("package:$packageName")
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                            }
                            startActivity(intent)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("OPEN_SETTINGS_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
