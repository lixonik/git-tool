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

## Трек 1 -- ГОТОВ (ideaIC-2025.2)

- 2025.3+ -- только унифицированный IU-дистрибутив; взят ideaIC-2025.2,
  последняя настоящая Community (Apache 2.0). sha256 сверен.
- Установка: D:\Apps\GitTool (dist + изолированные config/system + лаунчер).
- Проверен запуск: плагины по списку (Git, GitHub, GitLab, Terminal, Markdown,
  TextMate, JSON/YAML/Toml, Modal Commit и пр.), ошибок нет.
- Осталось пользователю: принять User Agreement при первом запуске (1 клик).

## Трек 2 -- сборка из исходников (ИДЁТ)

- Процесс PID в D:\ijbuild\build.pid, лог D:\ijbuild\build.log.
- Команда: installers.cmd, target os/arch=current, пропущены шаги
  windows_exe_installer, cross_platform_dist, sources_archive, maven_artifacts,
  archivePlugins, non_bundled_plugins, provided_modules_list,
  doc_authoring_assets, search_index, keymap_plugins.
- Bazel-каталоги переနаправлены на D: (.bazelrc-user.bazelrc, gitignored).
- Ожидаемые артефакты: D:\Repos\intellij-community\out\idea-ce\artifacts.

## NEXT (для каждого пробуждения сторожа)

1. Проверить процесс сборки: pid из D:\ijbuild\build.pid жив? tail build.log.
2. Диск-гвард: если на D: < 6 GB свободно -- убить сборку, отметить здесь.
3. Если сборка упала -- прочитать хвост лога, починить причину, перезапустить
   (команда выше, из D:\Repos\intellij-community).
4. Если сборка успешна: применить слой конфигурации к OSS-дистрибутиву
   (D:\Apps\GitToolOSS), запустить, проверить по idea.log: открытие репо,
   обнаружение git-корня, версия git. Согласие на сбор статистики -- отклонить.
5. Финал: README, STATE: DONE, удалить cron-сторож (job id c8a9dfc3).
   Пользователя не пинговать до 2026-07-18 21:00.

## Журнал

- 2026-07-18 ~00:xx -- старт. Репо git-tool чистый (только LICENSE).
  Выяснено: interview-project = Angular "BugHunt", источник -- intellij-community
  (plugins/git4idea на месте). Поставлен cron-сторож c8a9dfc3 (каждые 10 мин).
