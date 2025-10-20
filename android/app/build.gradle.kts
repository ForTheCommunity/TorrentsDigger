import com.android.build.api.variant.ApplicationVariant
import org.gradle.api.JavaVersion

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "org.forthecommunity.torrentsdigger"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "org.forthecommunity.torrentsdigger"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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


// F-droid splits APKs by ABI, and requires different versionCode for each ABI.
val abiCodes = mapOf(
    "x86_64" to 1,
    "armeabi-v7a" to 2,
    "arm64-v8a" to 3
)

// F-droid splits APKs by ABI, and requires different versionCode for each ABI.
// For flutter version X.Y.Z, version code is X0Y0ZA, where A is the ABI code.
// See:
// * https://developer.android.com/build/gradle-tips
// * https://developer.android.com/studio/build/configure-apk-splits
// * https://gitlab.com/fdroid/fdroiddata/-/blob/master/metadata/im.nfc.nfsee.yml
android.applicationVariants.all { variant: ApplicationVariant ->
    variant.outputs.all { output ->
        val abiName = output.getFilter("ABI") 
        val abiVersionCode = abiCodes[abiName]
        
        if (abiVersionCode != null) {
            output.versionCodeOverride = variant.versionCode * 10 + abiVersionCode
        }
    }
}