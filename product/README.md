# Кастомный продукт GitTool (исходники)

Файлы, из которых собирается минимальный продукт «GitTool» (productCode GT,
лаунчер `gittool64.exe`) в дереве intellij-community. Скопированы сюда для
сохранности: в самом intellij-community они лежат некоммитнутыми.

## Как применить к чистому intellij-community

1. `gittool-module\` -> скопировать в `<community>\gittool\` (iml + resources;
   в resources добавить иконки: скопировать из
   `community-resources\resources\`: idea-ce*.svg, idea_community_logo*.png).
2. `build-src\GitToolProperties.kt` -> `<community>\build\src\org\jetbrains\intellij\build\`.
3. `build-src\GitToolInstallersBuildTarget.kt` -> `<community>\build\src\`.
4. В `<community>\.idea\modules.xml` добавить строку:
   `<module fileurl="file://$PROJECT_DIR$/gittool/intellij.gittool.customization.iml" filepath="$PROJECT_DIR$/gittool/intellij.gittool.customization.iml" />`
5. В `<community>\build\dev-build.json` в "products" добавить:
   `"GitTool": { "modules": [как у community], "class": "org.jetbrains.intellij.build.GitToolProperties" }`
6. В `<community>\build\BUILD.bazel` добавить java_binary "gittool_build_target"
   (копия i_build_target с main_class = GitToolInstallersBuildTarget).
7. Прогнать `build\jpsModelToBazelCommunityOnly.cmd` (регенерирует BUILD.bazel
   модуля gittool).
8. Собрать: `bazel.cmd run //build:gittool_build_target -- --jvm_flag=-Dintellij.build.target.os=current ...`
   (полная команда со skip-списком -- в STATUS.md корня репозитория).

Артефакт: `out\gittool\artifacts\gittool-<build>.win.zip` -- полный дистрибутив
с собственным product-info.json, нативным лаунчером и JBR.
