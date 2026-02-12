plugins {
    // Android application plugin
    id("com.android.application")

    // Required for Firebase (processes google-services.json)
    id("com.google.gms.google-services")

    // Kotlin support for Android
    id("kotlin-android")

    // Flutter Gradle plugin (must be applied after Android & Kotlin plugins)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Application namespace (package name)
    namespace = "com.example.flutter_chat_app"

    // Compile SDK version provided by Flutter
    compileSdk = flutter.compileSdkVersion

    // Specify NDK version for native dependencies compatibility
    ndkVersion = "27.0.12077973"

    // Java compatibility options (required for modern Flutter/AGP versions)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Kotlin JVM target version
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Unique Application ID (change this before publishing)
        applicationId = "com.example.flutter_chat_app"

        // Minimum Android version supported (API 23 required for Firebase Auth)
        minSdk = 23

        // Target SDK version provided by Flutter
        targetSdk = flutter.targetSdkVersion

        // App versioning (managed by Flutter)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Replace with your own signing configuration for production
            // Currently using debug signing to allow `flutter run --release`
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    // Path to Flutter project root
    source = "../.."
}
