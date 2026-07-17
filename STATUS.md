# STATUS

STATE: IN_PROGRESS

## Текущая фаза

Каркас репозитория создан. Идёт feasibility-проверка (задача #2):
ресурсы машины и build-система intellij-community.

## NEXT

1. Проверить диск/RAM/JDK, найти build-скрипты intellij-community
   (installers.cmd, ProductProperties, build/src).
2. Выбрать вариант сборки (A/B/C из PLAN.md), зафиксировать здесь.
3. Собрать продукт, упаковать, проверить запуск и git-сценарии.
4. Финал: README, STATE: DONE, удалить cron-сторож (job id c8a9dfc3).

## Журнал

- 2026-07-18 ~00:xx -- старт. Репо git-tool чистый (только LICENSE).
  Выяснено: interview-project = Angular "BugHunt", источник -- intellij-community
  (plugins/git4idea на месте). Поставлен cron-сторож c8a9dfc3 (каждые 10 мин).
