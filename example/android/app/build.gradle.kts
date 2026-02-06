plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

//def localProperties = new Properties()
//def localPropertiesFile = rootProject.file('local.properties')
//if (localPropertiesFile.exists()) {
//    localPropertiesFile.withReader('UTF-8') { reader ->
//        localProperties.load(reader)
//    }
//}

//def flutterRoot = localProperties.getProperty('flutter.sdk')
//if (flutterRoot == null) {
//    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
//}

//def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
//if (flutterVersionCode == null) {
//    flutterVersionCode = '1'
//}

//def flutterVersionName = localProperties.getProperty('flutter.versionName')
//if (flutterVersionName == null) {
//    flutterVersionName = '1.0'
//}

//apply plugin: 'com.android.application'
//apply plugin: 'kotlin-android'
//apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {

    namespace = "com.tnkfactory.flutter.rwd.tnk_flutter_rwd_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

//    sourceSets {
//        main.java.srcDirs += 'src/main/kotlin'
//    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.tnkfactory.flutter.rwd.tnk_flutter_rwd_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-build-configuration.
        minSdk =  23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

//        manifestPlaceholders["adiscope_media_id"] = "280"
//        manifestPlaceholders["adiscope_media_secret"] = "a2bc0d66b32446ccb78c42ec8255a75b"
//        manifestPlaceholders["adiscope_sub_domain"] = ""
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
    api(project(":tnk_rwd"))
}
//
//dependencies {
//    implementation(project(":tnk_rwd"))
//    implementation "com.tnkfactory:rwd:8.09.06"
//
//}
