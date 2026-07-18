# GitTool

Автономный инструмент для работы с git (в духе GitHub Desktop), собранный из
JetBrains-инструментария: IntelliJ IDEA Community с конфигурацией, сводящей его
к полноценному git-клиенту -- лог, коммит, дифф, ветки, merge/rebase,
shelve/stash, создание и применение патчей, аннотации, интеграция с GitHub/GitLab.

Два способа получить продукт:

- **Трек 1 (рекомендуется)** -- официальный релиз ideaIC-2025.2 (Apache 2.0),
  быстро и надёжно. Запуск через нативный `idea64.exe`.
- **Трек 2** -- сборка из исходников `intellij-community` (свежая ветка 262),
  для тех, кому нужна последняя версия платформы.

## Установка (Трек 1)

```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup.ps1
```

Скрипт скачает официальный дистрибутив IdeaIC 2025.2 с download.jetbrains.com
(~1.3 GB, сверка sha256), распакует его в `D:\Apps\GitTool\dist` и применит
конфигурацию GitTool (изолированные config/system, git-only набор плагинов,
предустановленный Classic UI, лаунчер). Другой путь установки: `-InstallRoot <путь>`.

## Установка (Трек 2, из исходников)

Требует локальный `D:\Repos\intellij-community`. Сборка выполняется его
собственным build-скриптом:

```
installers.cmd -Djava.net.preferIPv4Stack=true \
  -Dintellij.build.target.os=current -Dintellij.build.target.arch=current
```

Затем слой конфигурации накладывается на полученный дистрибутив
(`out/idea-ce/dist.all` + `dist.win.x64`, JBR из кэша сборки):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup-oss.ps1 -ZipPath <не требуется, dist берётся из out>
```

Подробности сборки, обход сетевых блокировок загрузок зависимостей и точные
пути -- в [STATUS.md](STATUS.md).

## Запуск

```
D:\Apps\GitTool\GitTool.bat [путь-к-репозиторию]
```

- При первом запуске JetBrains покажет диалог принятия условий -- один клик,
  дальше не появляется.
- Инстанс полностью изолирован от обычной установки IDEA: собственные каталоги
  config/system/plugins/log внутри корня установки.
- Лаунчер универсален: релизный дистрибутив запускается нативным `idea64.exe`
  (чистый GUI); сборка из исходников -- скриптом `idea.bat` в скрытом окне
  (в ней build-скрипт не генерирует `product-info.json`, который требует
  нативный лаунчер).

## Работа с патчами

Полностью поддержана (механика в ядре платформы, не в отдельном плагине):

- Создать: `Git | Patch | Create Patch from Local Changes`, либо из Git Log --
  правый клик по коммиту -> `Create Patch`.
- Применить: `Git | Patch | Apply Patch` (из файла) и `Apply Patch from Clipboard`
  с предпросмотром, ремапом путей и разрешением конфликтов.
- Формат -- unified diff, совместим с `git apply`.

## Интерфейс

Предустановлен плагин **Classic UI** (классический интерфейс вместо New UI).
Нюансы совместимости решаются в setup-скриптах автоматически:

- Трек 1 (релиз 2025.2): единственная 252-версия Classic UI ограничена срезом
  252.13776.*, поэтому `until-build` расширяется до `252.*`.
- Трек 2 (сборка 262.SNAPSHOT): снимается нижняя граница `since-build` и guard
  `<incompatible-with>com.intellij.jetbrains.client</incompatible-with>`
  (в монолитной сборке из исходников этот модуль присутствует).

Патч дескриптора и переупаковка jar идут через `scripts/PluginRepack.java`
(запускается рантаймом самого продукта): стандартный .NET-архиватор пишет
extra-поля, которые не читает memory-mapped zip-ридер платформы. Общий код --
`scripts/ClassicUi.ps1`. Вернуться к New UI -- удалить `config\plugins\classic-ui`.

## Состав репозитория

- `scripts/setup.ps1` -- установка Трека 1
- `scripts/setup-oss.ps1` -- наложение конфигурации на сборку из исходников
- `scripts/ClassicUi.ps1` -- общий хелпер установки Classic UI
- `scripts/PluginRepack.java` -- переупаковщик jar под zip-ридер платформы
- `scripts/GitTool.bat` -- универсальный лаунчер
- `config/disabled_plugins.txt` -- всё лишнее выключено, остаётся git/VCS
- `config/gittool.vmoptions` -- параметры JVM
- `config/options/` -- преднастройка (доверенные каталоги и т.п.)

## Почему 2025.2 для Трека 1

Начиная с 2025.3 JetBrains публикует только унифицированный дистрибутив
IntelliJ IDEA (productCode IU, проприетарный free-режим). ideaIC-2025.2 --
последний артефакт настоящей Community Edition (productCode IC, Apache 2.0).
Трек 2 обходит это ограничение, собирая свежий Community прямо из исходников.

## Лицензии

- IntelliJ IDEA Community Edition -- Apache License 2.0 (JetBrains s.r.o.);
  использование, в том числе некоммерческое, свободно.
- Скрипты и конфигурация этого репозитория -- MIT (см. LICENSE).
