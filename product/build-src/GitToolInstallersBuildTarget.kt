// Copyright 2000-2026 JetBrains s.r.o. and contributors. Use of this source code is governed by the Apache 2.0 license.
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import org.jetbrains.intellij.build.BuildOptions
import org.jetbrains.intellij.build.BuildPaths.Companion.COMMUNITY_ROOT
import org.jetbrains.intellij.build.GitToolProperties
import org.jetbrains.intellij.build.impl.buildDistributions
import org.jetbrains.intellij.build.impl.createBuildContext

object GitToolInstallersBuildTarget {
  @JvmStatic
  fun main(args: Array<String>) {
    runBlocking(Dispatchers.Default) {
      val options = BuildOptions().apply {
        incrementalCompilation = true
        useCompiledClassesFromProjectOutput = false
        buildStepsToSkip += BuildOptions.MAC_SIGN_STEP
        buildStepsToSkip += BuildOptions.WIN_SIGN_STEP
      }
      val context = createBuildContext(
        projectHome = COMMUNITY_ROOT.communityRoot,
        productProperties = GitToolProperties(COMMUNITY_ROOT.communityRoot),
        setupTracer = true,
        options = options,
      )
      context.compileModules(moduleNames = null)
      buildDistributions(context)
    }
  }
}
