# GitTool -- standalone JetBrains git tooling

## Цель

Приложение-инструмент для работы с git (аналог GitHub Desktop), собранное из
исходников IntelliJ Community: полный JetBrains git-инструментарий (git4idea) --
лог, коммит, дифф, ветки, merge/rebase, shelve/stash, аннотации -- без остальной IDE.
Лицензионно чисто для некоммерческого (и вообще любого) использования:
IntelliJ Community Edition распространяется под Apache 2.0.

## Исходные данные

- Репозиторий продукта: D:\Repos\git-tool (этот репо, main, push после каждого коммита)
- Исходники JetBrains: D:\Repos\intellij-community (plugins/git4idea и платформа)
- Примечание: в исходной постановке источником назван D:\Repos\interview-project,
  но это Angular-проект "BugHunt" без какого-либо git-инструментария.
  Единственный осмысленный источник -- intellij-community, работа ведётся с ним.

## Стратегия (по убыванию предпочтительности)

1. Вариант A -- кастомный продукт через build-скрипты intellij-community
   (свой ProductProperties с минимальным набором модулей: платформа + VCS + git4idea).
   Максимально «настоящий» продукт, но самый дорогой по времени и риску.
2. Вариант B -- полная сборка IntelliJ IDEA Community из исходников, затем
   упаковка в «GitTool»: отключение всех плагинов кроме VCS/Git
   (disabled_plugins.txt), преднастройка (Commit tool window, Git log),
   переименование/лаунчер. Надёжно, даёт тот же git-функционал.
3. Вариант C (fallback) -- официальный дистрибутив IC + те же скрипты упаковки,
   если сборка из исходников на этой машине невозможна (диск/память/сеть).

Выбор фиксируется после feasibility-проверки (диск, RAM, JDK, build-скрипты).
