# ─────────────────────────────────────────────────────────────────────────────
# ProGuard / R8 rules for Journey Forward (Flutter release builds)
# ─────────────────────────────────────────────────────────────────────────────

# ── Flutter ──────────────────────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── flutter_local_notifications ──────────────────────────────────────────────
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.dexterous.flutterlocalnotifications.* <fields>;
    @com.dexterous.flutterlocalnotifications.* <methods>;
}

# Gson is used internally by flutter_local_notifications to (de)serialize
# pending notifications across process restarts. Keep its TypeToken classes
# or rescheduled notifications go missing after a reboot.
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ── local_auth (biometric) ───────────────────────────────────────────────────
-keep class androidx.biometric.** { *; }
-keep class io.flutter.plugins.localauth.** { *; }

# ── flutter_secure_storage (uses Android Keystore + EncryptedSharedPreferences)
# ──────────────────────────────────────────────────────────────────────────────
# Without these, R8 strips Tink crypto classes and EncryptedSharedPreferences
# fails silently — every read returns null. This was the root cause of the
# "profile saved fine in-session but lost after a cold restart" bug: the
# encrypted blob WAS being written to disk, but the next launch's read call
# threw inside Tink (ClassNotFoundException on stripped classes), the throw
# was caught by EncryptedStore.read, returned null, and the user was bounced
# back to onboarding even though their data was physically present.
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class androidx.security.crypto.** { *; }
-keep class com.google.crypto.tink.** { *; }
-keep class com.google.crypto.tink.proto.** { *; }
-keepclassmembers class * extends com.google.crypto.tink.shaded.protobuf.GeneratedMessageLite {
    <fields>;
}
-keep class * extends com.google.crypto.tink.shaded.protobuf.GeneratedMessageLite { *; }
-keep class com.google.crypto.tink.shaded.protobuf.** { *; }
-dontwarn com.google.crypto.tink.**
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**

# ── just_audio / ExoPlayer ───────────────────────────────────────────────────
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# ── Riverpod / Dart codegen ──────────────────────────────────────────────────
# Riverpod has no runtime reflection on Android but keep generic signatures
# for any plugin Dart bridges that do.
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ── App-specific ─────────────────────────────────────────────────────────────
-keep class com.journeyforward.journey_forward.** { *; }

# ── Quiet noisy warnings from optional plugin deps ──────────────────────────
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
