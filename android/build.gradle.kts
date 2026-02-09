allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 1. Define the build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // 2. Apply the build directory to subprojects
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // 3. 🛠️ THE NAMESPACE FIX (Keep this, it's good) 🛠️
    if (project.name == "isar_flutter_libs") {
        afterEvaluate {
            project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                namespace = "dev.isar.isar_flutter_libs"
            }
        }
    }

    // 4. 🔥 THE FIX FOR 'lStar not found' (Force SDK 35) 🔥
    afterEvaluate {
        // Check if the project is an Android Application or Library
        if ((plugins.hasPlugin("com.android.application") || plugins.hasPlugin("com.android.library"))) {
            // Force it to compile with API 35
            configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(35)
            }
        }
    }

    // 5. Ensure app project is evaluated first
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}