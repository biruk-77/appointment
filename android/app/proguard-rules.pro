# Stripe SDK ProGuard Rules for flutter_stripe
# Suppress warnings for missing push provisioning classes (optional feature)
-dontwarn com.stripe.android.pushProvisioning.**
-dontwarn com.reactnativestripesdk.pushprovisioning.**

# Keep essential Stripe classes 
-keep class com.stripe.android.core.** { *; }
-keep class com.stripe.android.model.** { *; }
-keep class com.stripe.android.view.** { *; }
-keep class com.stripe.android.CustomerSession** { *; }
-keep class com.stripe.android.PaymentConfiguration** { *; }
-keep class com.stripe.android.Stripe** { *; }

# Keep React Native Stripe SDK
-keep class com.reactnativestripesdk.** { *; }

# Keep Flutter classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Keep attributes for reflection
-keepattributes Signature,*Annotation*,EnclosingMethod
