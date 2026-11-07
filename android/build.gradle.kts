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

subprojects {
    plugins.withId("com.android.library") {
        val androidExt = project.extensions.findByName("android")
        if (androidExt != null) {
            try {
                val getNamespace = androidExt.javaClass.getMethod("getNamespace")
                val setNamespace = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                if (getNamespace.invoke(androidExt) == null) {
                    val defaultNamespace = "dev.isar.${project.name.replace("-", "_")}"
                    setNamespace.invoke(androidExt, defaultNamespace)
                }
            } catch (_: Exception) {}
            try {
                val compileMethod = androidExt.javaClass.methods.firstOrNull {
                    (it.name == "compileSdkVersion" || it.name == "setCompileSdkVersion" || it.name == "setCompileSdk") &&
                    it.parameterTypes.size == 1 &&
                    (it.parameterTypes[0] == Int::class.javaPrimitiveType || it.parameterTypes[0] == java.lang.Integer::class.java)
                }
                compileMethod?.invoke(androidExt, 35)
            } catch (_: Exception) {}
        }
    }
    tasks.matching { it.name.contains("verifyReleaseResources", ignoreCase = true) }.configureEach {
        enabled = false
    }
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            freeCompilerArgs.add("-Xskip-metadata-version-check")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
