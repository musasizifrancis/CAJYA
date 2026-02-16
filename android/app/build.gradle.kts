plugins {
    id "com.android.application"
    id "kotlin-android"
}

android {
    namespace = "com.example.carja_driver"
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11
    }

    defaultConfig {
        applicationId = "com.example.carja_driver"
        minSdkVersion = 21
        targetSdkVersion = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}

dependencies {
    implementation "androidx.core:core:1.10.1"
    implementation "androidx.appcompat:appcompat:1.6.1"
}
