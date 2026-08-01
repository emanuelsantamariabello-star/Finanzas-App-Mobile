import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseKeyPropertiesFile = rootProject.file("key.properties")
val releaseKeyProperties = Properties()
val hasReleaseSigning = releaseKeyPropertiesFile.isFile
if (hasReleaseSigning) {
    releaseKeyPropertiesFile.inputStream().use(releaseKeyProperties::load)
}
val allowUnsignedRelease =
    providers.environmentVariable("ALLOW_UNSIGNED_RELEASE").orNull == "true"

android {
    namespace = "com.finanzas_app_san.emanuelsantamariabello"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.finanzas_app_san.emanuelsantamariabello"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = releaseKeyProperties.getProperty("keyAlias")
                keyPassword = releaseKeyProperties.getProperty("keyPassword")
                storeFile = rootProject.file(
                    releaseKeyProperties.getProperty("storeFile"),
                )
                storePassword = releaseKeyProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

tasks.register("validateReleaseSigning") {
    doLast {
        if (!hasReleaseSigning && !allowUnsignedRelease) {
            throw GradleException(
                "Falta android/key.properties. No se permite firmar release con la clave debug.",
            )
        }
    }
}

tasks.matching {
    it.name == "bundleRelease" || it.name == "assembleRelease"
}.configureEach {
    dependsOn("validateReleaseSigning")
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
