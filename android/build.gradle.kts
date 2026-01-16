allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 1. Define the build directory (Crucial variable)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // 2. Apply the build directory to subprojects
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // 3. 🛠️ THE ISAR NAMESPACE FIX 🛠️
    if (project.name == "isar_flutter_libs") {
        afterEvaluate {
            // Safely configure the Android extension
            project.extensions.configure<com.android.build.gradle.LibraryExtension> {
                namespace = "dev.isar.isar_flutter_libs"
            }
        }
    }

    // 4. Ensure app project is evaluated first
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}