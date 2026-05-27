import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ─── Release signing config ───────────────────────────────────────────────────
// android/key.properties is gitignored. It MUST be present on any machine that
// produces a release artifact. There is NO debug-signing fallback — a
// debug-signed APK is not acceptable for Play Store, and silently shipping
// one would be worse than a clean build failure.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Fail any release-variant build when key.properties is missing. Runs after
// the task graph is resolved so IDE syncs and debug builds are unaffected —
// only `flutter build apk --release` / `flutter build appbundle --release`
// (or the equivalent Gradle tasks) trip the guard.
gradle.taskGraph.whenReady {
    val needsReleaseSigning = allTasks.any { task ->
        val n = task.name
        (n.startsWith("assemble") || n.startsWith("bundle") || n.startsWith("package"))
            && n.contains("Release")
    }
    if (needsReleaseSigning && !keystorePropertiesFile.exists()) {
        throw GradleException(
            "Release build refused: android/key.properties is missing.\n" +
            "  Create it from android/key.properties.example with the real\n" +
            "  keystore path / passwords / alias before running\n" +
            "  flutter build apk --release or flutter build appbundle --release.\n" +
            "  Debug builds (flutter run, flutter build apk --debug) are unaffected."
        )
    }
}

android {
    namespace = "com.journeyforward.journey_forward"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.journeyforward.journey_forward"
        minSdk = 24          // covers ~99.5% of active devices; required floor for several plugins
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Always the real release signing config. The taskGraph guard
            // above fails the build before this is reached if key.properties
            // is missing, so we never silently fall through to debug-signed.
            signingConfig = signingConfigs.getByName("release")

            // R8 minification + resource shrinking. Drops APK size by ~30-40%
            // and removes unused symbols (defence in depth — harder for an
            // attacker to reverse-engineer the codebase).
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
