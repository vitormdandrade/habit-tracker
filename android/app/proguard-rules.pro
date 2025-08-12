# Very permissive ProGuard rules to prevent crashes
# Keep almost everything to avoid obfuscation issues

# Don't obfuscate anything
-dontobfuscate

# Keep all classes
-keep class ** { *; }

# Keep all interfaces
-keep interface ** { *; }

# Keep all enums
-keep enum ** { *; }

# Handle missing Google Play Core classes
-dontwarn com.google.android.play.core.**

# Handle missing OkHttp classes
-dontwarn com.squareup.okhttp.**

# Handle missing Java reflection classes
-dontwarn java.lang.reflect.AnnotatedType

# Ignore missing classes warnings
-dontwarn **

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep enum classes and their values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Retrofit/OkHttp (if used)
-dontwarn retrofit2.**
-dontwarn okio.**
-dontwarn okhttp3.**

# Remove debug logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}