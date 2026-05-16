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

// --- 替换后的修复代码 ---
subprojects {
    // 监听所有子项目，当它们应用 Android 库插件或应用插件时执行
    val fixNamespace: (Component) -> Unit = {
        val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null && android.namespace == null) {
            if (project.name == "isar_flutter_libs") {
                android.namespace = "dev.isar.isar_flutter_libs"
            } else {
                // 兜底：使用项目名作为 namespace
                android.namespace = project.group.toString().ifEmpty { "com.example.${project.name.replace("-", "_")}" }
            }
        }
    }

    // 针对 Library 和 Application 插件都进行检查
    plugins.withId("com.android.library") {
        // 既然已经评估过了，我们直接尝试运行逻辑，或者包裹在针对 DSL 的配置中
        val android = extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
        if (android.namespace == null) {
            android.namespace = if (project.name == "isar_flutter_libs") "dev.isar.isar_flutter_libs" else project.group.toString()
        }
    }
    plugins.withId("com.android.application") {
        val android = extensions.getByType(com.android.build.gradle.AppExtension::class.java)
        if (android.namespace == null) {
            android.namespace = project.group.toString()
        }
    }
}
// ----------------------


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
