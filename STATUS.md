# STATUS

STATE: IN_PROGRESS

## Текущая фаза

Feasibility завершена. Решение: двухтрековая стратегия.

- Машина: 64 GB RAM, 32 ядра; диск D: 32.9 GB свободно, C: 15.4 GB.
- installers.cmd = bazel run //build:i_build_target, тянет ALL_COMMUNITY_TARGETS
  (полная компиляция community через Bazel) -- по диску на грани.
- Bazel на Windows пишет в C:/ProgramData/_bazel и кэш на C: --
  при попытке сборки обязателен перенос на D: через .bazelrc-user.bazelrc.

Трек 1 (основной): официальный дистрибутив IdeaIC (Apache 2.0) + упаковка
GitTool (disabled_plugins.txt, изолированные config/system, лаунчер).
Трек 2 (растяжка): сборка из исходников с bazel-root на D: и сторожем диска
(abort при <6 GB свободных на D:).

## NEXT

1. Скачать ideaIC win-zip (data.services.jetbrains.com, code=IIC), распаковать
   в D:\Apps\GitTool\dist.
2. Написать слой упаковки в git-tool: scripts/ (setup, launcher), config/
   (disabled_plugins.txt, idea.properties, vmoptions). Коммит+пуш после шагов.
3. Запустить, проверить git-сценарии (открыть репо, лог, коммит, ветки).
4. Трек 2 при успехе трека 1 и достатке диска.
5. Финал: README, STATE: DONE, удалить cron-сторож (job id c8a9dfc3).

## Журнал

- 2026-07-18 ~00:xx -- старт. Репо git-tool чистый (только LICENSE).
  Выяснено: interview-project = Angular "BugHunt", источник -- intellij-community
  (plugins/git4idea на месте). Поставлен cron-сторож c8a9dfc3 (каждые 10 мин).
