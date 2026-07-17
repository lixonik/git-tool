# GitTool

Автономный инструмент для работы с git (в духе GitHub Desktop), собранный из
JetBrains-инструментария: дистрибутив IntelliJ IDEA Community (Apache 2.0)
с конфигурацией, сводящей его к полноценному git-клиенту -- лог, коммит,
дифф, ветки, merge/rebase, shelve/stash, аннотации, интеграция с GitHub.

## Установка

```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup.ps1
```

Скрипт скачает официальный дистрибутив IdeaIC 2025.2 с download.jetbrains.com
(~1.3 GB, сверка sha256), распакует его в `D:\Apps\GitTool\dist` и применит
конфигурацию GitTool (изолированные config/system, git-only набор плагинов,
лаунчер). Другой путь установки: `-InstallRoot <путь>`.

## Запуск

```
D:\Apps\GitTool\GitTool.bat [путь-к-репозиторию]
```

- При первом запуске JetBrains покажет диалог принятия условий Community
  Edition -- один клик, дальше не появляется.
- Инстанс полностью изолирован от обычной установки IDEA: собственные
  каталоги config/system/plugins/log внутри `D:\Apps\GitTool`.

## Состав

- `scripts/setup.ps1` -- установка и применение конфигурации
- `scripts/GitTool.bat` -- лаунчер (через IDEA_PROPERTIES/IDEA_VM_OPTIONS)
- `config/disabled_plugins.txt` -- всё лишнее выключено, остаётся git/VCS
- `config/gittool.vmoptions` -- параметры JVM
- `config/options/` -- преднастройка (доверенные каталоги и т.п.)

## Почему 2025.2

Начиная с 2025.3 JetBrains публикует только унифицированный дистрибутив
IntelliJ IDEA (productCode IU, проприетарный free-режим). ideaIC-2025.2 --
последний артефакт настоящей Community Edition (productCode IC, Apache 2.0),
поэтому базой выбран он. Альтернатива посвежее -- сборка из исходников
intellij-community (см. STATUS.md, трек 2).

## Лицензии

- IntelliJ IDEA Community Edition -- Apache License 2.0 (JetBrains s.r.o.);
  использование, в том числе некоммерческое, свободно.
- Скрипты и конфигурация этого репозитория -- MIT (см. LICENSE).
