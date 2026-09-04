# Keep all classes in the com.google.j2objc.annotations package
-keep class com.google.j2objc.annotations.** { *; }

# Suppress warnings related to classes in the com.google.j2objc.annotations package
-dontwarn com.google.j2objc.annotations.**

# Firebase-specific rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Suppress warnings related to the ReflectionSupport class in com.google.j2objc.annotations
-dontwarn com.google.j2objc.annotations.ReflectionSupport

# Keep all classes in the com.google.common.util.concurrent package (optional, if related)
-keep class com.google.common.util.concurrent.** { *; }

# Suppress warnings related to the AbstractFuture class in com.google.common.util.concurrent
-dontwarn com.google.common.util.concurrent.AbstractFuture
