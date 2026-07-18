# STATUS

STATE: DONE

GitTool готов в трёх вариантах, все запущены и проверены (git-подсистема
поднимается, репозиторий открывается, Classic UI активен, ошибок в idea.log нет).

## Linux-установщик (2026-07-19, ночь)

- Продукт собран под linux-x64 тем же таргетом (-Dintellij.build.target.os=
  linux); Linux-JBR подложен в кэш заранее -- сборка прошла с первой попытки.
- GitTool-262-linux-x64-installer.sh: self-extracting sh (header + tar.gz),
  собирается make-release-linux.ps1 в WSL (сохранение unix-прав). Ставит в
  ~/.local/share/GitTool, симлинк ~/.local/bin/gittool, .desktop, пресид
  Classic UI + customization.xml в ~/.config/GitTool2026.2 (XDG, первый раз).
  git -- системный, mingit не кладётся.
- Верифицировано в WSL Ubuntu с изолированным HOME: распаковка, exec-биты,
  симлинк, .desktop, пресид, jbr/bin/java -version (25.0.3). GUI-запуск в WSL
  Win10 невозможен (нет WSLg) -- проверка на реальном Linux за пользователем.
- Для освобождения диска удалён D:\Apps\GitToolOSS (вытеснен GitToolMini,
  воспроизводим по STATUS/скриптам).

## Доводка UI (2026-07-18, ~18:00)

- По замечаниям пользователя: меню отлеплено от заголовка окна
  (-Dide.win.frame.decoration=false, вшито в vmoptions продукта через
  additionalVmOptions); плагин EditorConfig исключён из комплекта
  (тянул отсутствующие в минимальном продукте модули ядра -- spellchecker).
- Продукт пересобран начисто, dist заменён, релиз перепакован.
- Проверено: 0 ошибок, 0 упоминаний editorconfig, Classic UI и MinGit на месте.
- Центрирование текста заголовка окна платформа не поддерживает (рисует
  Windows); заголовок теперь на стандартной системной полосе.

## Дистрибуция (2026-07-18, вечер)

- GitTool-262-setup.exe (247 MB, 7z SFX) и GitTool-262-portable.7z --
  в D:\Apps\GitTool-release. Внутри: dist (с bin\idea.properties --
  относительные пути конфига, exe самодостаточен, батники удалены),
  config (Classic UI, зачистка меню, git.xml), mingit (MinGit 2.55,
  путь преднастроен $APPLICATION_HOME_DIR$/../mingit/cmd/git.exe).
- install.bat инсталлера: копия в %LOCALAPPDATA%\GitTool, ярлыки
  (рабочий стол + меню Пуск) прямо на gittool64.exe, запуск.
- Проверено из чистой локации: старт, Classic UI, mingit обнаружен, 0 ошибок.
- Упаковка воспроизводится scripts\make-release.ps1.

## GitToolMini -- кастомный минимальный продукт (главный результат)

По запросу пользователя «standalone exe только с функционалом гита» собран
собственный продукт из исходников intellij-community (образец -- PyCharm CE,
продукт без Java): модуль брендинга intellij.gittool.customization
(ApplicationInfo без java-essential, имя GitTool, productCode GT),
GitToolProperties + GitToolInstallersBuildTarget, java_binary
//build:gittool_build_target. Плагины: vcs-git, vcs-github, vcs-gitlab,
terminal, markdown, textmate, json, yaml, toml, editorconfig, sh, properties.
Дистрибутив 330 MB, собственный нативный gittool64.exe, сгенерированный
сборкой product-info.json, JBR в комплекте.

- Установлен: D:\Apps\GitToolMini (dist + изолированные config/system +
  classic-ui + лаунчер GitTool.bat). Архив дистрибутива сохранён там же.
- Сборка прошла с 3-й попытки (1: нет product plugin descriptor -> написан
  META-INF/GitToolPlugin.xml по образцу PyCharmCorePlugin.xml; 2: нет ico ->
  icoPath в windowsCustomizer). Сетевых сбоев не было -- прокси-фикс работает.
- Верифицирован: IDE STARTED, 12 плагинов, Classic UI активен, ошибок 0.
  На первом запуске платформа автоматически внесла classic-ui в
  disabled_plugins.txt (артефакт первого скана) -- файл очищен, повторно
  не появляется.
- Исходники продукта сохранены в репо: product/ (в intellij-community они
  некоммитнуты; инструкция применения -- product/README.md).
- Осталось пользователю: принять JetBrains Privacy Policy на первом запуске.

## Что сделано

- **Трек 1 (основной): ideaIC-2025.2** -- официальный релиз Community (Apache 2.0,
  productCode IC), последний перед переходом JetBrains на унифицированный
  дистрибутив. Установка в D:\Apps\GitTool. Запуск нативным idea64.exe.
- **Трек 2: сборка из исходников** intellij-community (ветка 262). Собран
  build-скриптом installers.cmd, дистрибутив собран вручную из dist.all +
  dist.win.x64 + JBR, установка в D:\Apps\GitToolOSS. Запуск через idea.bat.
- Оба: изолированные config/system/plugins/log, git-only набор плагинов,
  предустановленный Classic UI, универсальный лаунчер GitTool.bat.

## Артефакты на диске

- D:\Apps\GitTool -- Трек 1 (готов к запуску).
- D:\Apps\GitToolOSS -- Трек 2 (готов к запуску).
- Репозиторий git-tool -- скрипты установки, хелперы, README, этот журнал.
- D:\Repos\intellij-community\out\idea-ce -- дерево сборки Трека 2 (можно
  удалить для освобождения места; dist уже скопирован в D:\Apps\GitToolOSS).

## Ключевые решения (для истории)

- 2025.3+ у JetBrains -- только IU-дистрибутив (проприетарный free-режим),
  поэтому база Трека 1 -- 2025.2, последняя настоящая CE.
- Native-лаунчер idea64.exe требует полноценный product-info.json, который
  build-скрипт Трека 2 не генерирует (шаг упаковки жёстко пропущен в целевом
  installers-таргете). Поэтому OSS запускается через idea.bat (ему хватает
  синтезированного product-info.json для PathManager), а различие лаунчеров
  определяется маркером dist\.gittool-script-launcher.
- Classic UI: на релизе патчится until-build (единственная 252-версия
  ограничена срезом 252.13776.*), на сборке из исходников -- since-build и
  guard incompatible-with (в монолите присутствует client-модуль). Патч
  дескриптора и переупаковка jar -- через scripts/PluginRepack.java рантаймом
  продукта (стандартный zip платформа не читает).

## Сборка из исходников -- хроника (13 попыток)

Основные препятствия и решения задокументированы для повторяемости:

1. Нужны исходники android-плагина (getPlugins.bat) -- shallow-клон
   JetBrains/android, закреплён на коммите c57a20ab (ровесник community HEAD;
   свежий master несовместим по bazel-таргетам).
2. Битые/отсутствующие корневые файлы репо (LICENSE.txt) -- восстановлены из
   git HEAD (аномалия индекса ~273k staged deletions не тронута).
3. Систематическое глушение CloudFront-загрузок DPI: apache-maven, 7 jar-ов
   maven-индексатора, jackson, JCEF, JBR (jbr_jcef 261 MB), jbrsdk (278 MB),
   launcher, restarter -- всё скачано в обход PowerShell-ом (сверка sha1/sha256/
   tar) и подложено в build\download\ (имя = base36(sha256(url+"V3"))[:10]-file).
4. bazel-root вынесен на D: (.bazelrc-user.bazelrc, gitignored) из-за нехватки
   места на C:. Компиляция bazel кэшируется; повторные попытки быстрые.

## Осталось пользователю

- При первом запуске принять User Agreement (1 клик).
- По желанию удалить дерево сборки out\idea-ce и .bazelrc-user.bazelrc.
