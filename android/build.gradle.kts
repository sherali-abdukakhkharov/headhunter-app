allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force every plugin subproject's Kotlin to the same JVM target as its Java.
//
// `file_picker` declares `jvmTarget = 1.8` while AGP compiles its Java at 11,
// and Kotlin 2.x refuses that mismatch outright:
//
//     Inconsistent JVM-target compatibility detected for tasks
//     'compileDebugJavaWithJavac' (11) and 'compileDebugKotlin' (1.8)
//
// It is the plugin's declaration to fix, not ours, but a pub dependency cannot
// be edited — so the targets are aligned here instead. 17 rather than 11,
// matching `android/app/build.gradle.kts`, so every module in the build agrees
// on one number rather than two.
//
// Applies to all subprojects deliberately: the next plugin to ship a stale
// `jvmTarget` should not cost another afternoon.
// Both halves, or the mismatch simply swaps direction: raising only Kotlin
// turns "Java 11 vs Kotlin 1.8" into "Java 11 vs Kotlin 17".
subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>()
        .configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }

    // Through AGP's own `compileOptions`, not `tasks.withType<JavaCompile>`:
    // AGP configures the javac tasks from the extension, so setting the task
    // directly is overwritten and the mismatch survives.
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.api.dsl.LibraryExtension>(
            "android",
        ) {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
