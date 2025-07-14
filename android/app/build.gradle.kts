plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}
android {
    namespace = "com.tune.tunecrate"
    compileSdk = 35
    ndkVersion = "29.0.13113456" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlin {
    jvmToolchain(17)
}

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tune.tunecrate"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled =true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    // Firebase BoM - manages versions automatically
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))

    // Firebase SDKs you need
    implementation("com.google.firebase:firebase-analytics")
    implementation ("androidx.multidex:multidex:2.0.1")
    implementation("com.google.firebase:firebase-auth")
}


