import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.saladafactory"
    compileSdk = 36
    ndkVersion = "27.0.12077973" // ✅ النسخة الموحدة

compileOptions {
    sourceCompatibility = JavaVersion.VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_1_8
    isCoreLibraryDesugaringEnabled = true // ✅ مهم جدًا
}

kotlinOptions {
    jvmTarget = "1.8"
}


    defaultConfig {
        applicationId = "com.rzo.operations"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 42
        versionName = "1.4.7"
        ndk {
            debugSymbolLevel = "FULL"
            abiFilters += listOf("armeabi-v7a", "arm64-v8a") // فقط ARM

        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String

        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true         // ✅ ممكن تخليها true لو عايز تقلل حجم التطبيق
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
dependencies {
coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.0")
    // باقي dependencies عندك
}
flutter {
    source = "../.."
}

// ✅ نضيف هذا الجزء في النهاية لتثبيت نسخة الـ NDK على كل الـ subprojects (زي rive_common)
subprojects {
    afterEvaluate {
        extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
            ndkVersion = "27.0.12077973"
        }
    }
}
