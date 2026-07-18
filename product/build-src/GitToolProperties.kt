// Copyright 2000-2026 JetBrains s.r.o. and contributors. Use of this source code is governed by the Apache 2.0 license.
package org.jetbrains.intellij.build

import kotlinx.collections.immutable.persistentListOf
import kotlinx.collections.immutable.plus
import org.jetbrains.intellij.build.productLayout.CommunityModuleSets
import org.jetbrains.intellij.build.productLayout.ProductModulesContentSpec
import org.jetbrains.intellij.build.productLayout.productModules
import java.nio.file.Path

/**
 * A standalone git tool: the IntelliJ platform with VCS/git tooling and nothing
 * else -- no Java, no build systems, no run configurations. Community sources
 * only, Apache 2.0.
 */
class GitToolProperties(private val communityHomeDir: Path) : JetBrainsProductProperties() {
  override val customProductCode: String
    get() = "GT"

  init {
    platformPrefix = "GitTool"
    applicationInfoModule = "intellij.gittool.customization"
    scrambleMainJar = false
    useSplash = false
    buildCrossPlatformDistribution = false
    buildSourcesArchive = false

    productLayout.productImplementationModules = listOf(
      "intellij.platform.starter",
    )

    productLayout.bundledPluginModules = persistentListOf(
      "intellij.vcs.git",
      "intellij.vcs.github",
      "intellij.vcs.gitlab",
      "intellij.terminal",
      "intellij.markdown",
      "intellij.textmate.plugin",
      "intellij.json",
      "intellij.yaml",
      "intellij.toml",
      "intellij.sh.plugin",
      "intellij.properties",
    )

    additionalVmOptions += "-Dide.win.frame.decoration=false"

    productLayout.buildAllCompatiblePlugins = false
    productLayout.prepareCustomPluginRepositoryForPublishedPlugins = false
    productLayout.skipUnresolvedContentModules = true
  }

  override val baseFileName: String
    get() = "gittool"

  override fun getProductContentDescriptor(): ProductModulesContentSpec = productModules {
    deprecatedInclude("intellij.platform.resources", "META-INF/PlatformLangPlugin.xml")

    moduleSet(CommunityModuleSets.ideCommon())
    moduleSet(CommunityModuleSets.rdCommon())

    allowMissingDependencies(knownMissingModuleDependencies)
    allowMissingDependencies("intellij.platform.commercial.dependencies")
    bundledPlugins(productLayout.bundledPluginModules)
  }

  override fun getSystemSelector(appInfo: ApplicationInfoProperties, buildNumber: String): String {
    return "GitTool${appInfo.majorVersion}.${appInfo.minorVersionMainPart}"
  }

  override fun getBaseArtifactName(appInfo: ApplicationInfoProperties, buildNumber: String): String = "gittool-$buildNumber"

  override fun getOutputDirectoryName(appInfo: ApplicationInfoProperties): String = "gittool"

  override fun createWindowsCustomizer(projectHome: Path): WindowsDistributionCustomizer = windowsCustomizer(communityHomeDir) {
    icoPath = "build/idea-community-images/win/product.ico"
    icoPathForEAP = "build/idea-community-images/win/product_EAP.ico"
    fullName { "GitTool" }
    installDirNameHandler { "GitTool" }
  }

  override fun createLinuxCustomizer(projectHome: Path): LinuxDistributionCustomizer = object : LinuxDistributionCustomizer() {
    override fun getRootDirectoryName(appInfo: ApplicationInfoProperties, buildNumber: String): String = "gittool"
  }

  override fun createMacCustomizer(projectHome: Path): MacDistributionCustomizer = object : MacDistributionCustomizer() {
    init {
      bundleIdentifier = "com.jetbrains.gittool"
    }

    override fun getRootDirectoryName(appInfo: ApplicationInfoProperties, buildNumber: String): String = "GitTool.app"
  }
}
