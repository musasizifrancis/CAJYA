pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("com.android.application") version "8.0.0" apply false
    id("com.android.library") version "8.0.0" apply false
    id("dev.flutter.flutter-gradle-plugin") apply false
    id("org.jetbrains.kotlin.android") version "1.7.10" apply false
}

include(":app")

val flutterProjectRoot = rootProject.projectDir.parentFile.toPath()
val plugins = HashMap<String, String>()
val pluginsFile = File(flutterProjectRoot.toFile(), ".flutter-plugins")

if (pluginsFile.exists()) {
    pluginsFile.readLines().forEach { line ->
        val (name, path) = line.split("=")
        plugins[name] = path
    }
}

plugins.forEach { (name, path) ->
    val resolvedPath = flutterProjectRoot.resolve(path).resolve("android").toAbsolutePath().toString()
    include(":$name")
    project(":$name").projectDir = File(resolvedPath)
}
