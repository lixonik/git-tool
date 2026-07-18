# STATUS

STATE: IN_PROGRESS

## Текущая фаза

Feasibility завершена. Решение: двухтрековая стратегия.

- Машина: 64 GB RAM, 32 ядра; диск D: 32.9 GB свободно, C: 15.4 GB (на старте).
- installers.cmd = bazel run //build:i_build_target, тянет ALL_COMMUNITY_TARGETS
  (полная компиляция community через Bazel) -- по диску на грани.
- Bazel на Windows пишет в C:/ProgramData/_bazel и кэш на C: --
  перенос на D: сделан через .bazelrc-user.bazelrc.

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
- Команда: installers.cmd, -Djava.net.preferIPv4Stack=true,
  target os/arch=current, пропущены шаги: windows_exe_installer,
  cross_platform_dist, sources_archive, maven_artifacts, archivePlugins,
  non_bundled_plugins, provided_modules_list, doc_authoring_assets,
  search_index, keymap_plugins, repair_utility_bundle_step,
  fus_metadata_bundle_step.
- Bazel-каталоги перенаправлены на D: (.bazelrc-user.bazelrc, gitignored).
- Ожидаемые артефакты: D:\Repos\intellij-community\out\idea-ce\artifacts.

## NEXT (протокол продолжения; cron-сторож снят по запросу пользователя,
## работа идёт непрерывно на мониторах до STATE: DONE)

1. Проверить процесс сборки: pid из D:\ijbuild\build.pid жив? tail build.log.
2. Диск-гвард: если на D: < 6 GB свободно -- убить сборку, отметить здесь.
3. Если сборка упала -- прочитать хвост лога, починить причину, перезапустить
   (команда выше, из D:\Repos\intellij-community).
4. Если сборка успешна: применить слой конфигурации к OSS-дистрибутиву
   (scripts\setup-oss.ps1, установка в D:\Apps\GitToolOSS), запустить,
   проверить по idea.log: открытие репо, обнаружение git-корня, версия git.
   Согласие на сбор статистики -- отклонить. Вернуть C:\Temp\GitTool-dist
   в D:\Apps\GitTool\dist.
5. Финал: README, STATE: DONE. Пользователя не пинговать до 2026-07-18 21:00.

## Находки по intellij-community (для пользователя)

- В индексе git у D:\Repos\intellij-community ~273k staged deletions --
  артефакт прерванной git-операции. Исходники на месте (компиляция проходит),
  но часть корневых файлов реально отсутствовала (LICENSE.txt -- восстановлен
  из HEAD). Индекс я не трогал; лечится git reset --mixed HEAD.
- Для сборки IC обязательны исходники android-плагина (getPlugins.bat);
  склонирован shallow-клон JetBrains/android на коммит c57a20ab (2026-06-09),
  ровесник community HEAD 2fa2f83d -- свежий master android несовместим
  (bazel-таргеты разошлись).

## Журнал сборки (Трек 2)

- Попытка 1: упала -- нет android-исходников. Решение: shallow-клон.
- Попытка 2: упала -- android master новее community HEAD (2026-06-09),
  bazel-таргеты разошлись. Решение: android откачен на c57a20ab (та же дата).
- Попытка 3: bazel-фаза прошла (5939 действий), дистрибутив начал собираться;
  упала на загрузке apache-maven-3.9.16 через cache-redirector (DNS/reset x5).
  Диск D: просел до 5.3 GB.
- Попытка 4: упала мгновенно на той же загрузке. dist Трека 1 временно
  перенесён в C:\Temp\GitTool-dist (вернуть после сборки!).
- Попытка 5: maven-zip взят из кэша (пре-сид сработал), но упали 7 jar-ов
  maven-индексатора: CloudFront-соединения глушатся (DPI), Java-клиент
  рвётся, PowerShell качает нормально. Все 7 подложены с sha1-сверкой.
- Попытка 6: упала на jackson-core-2.16.0 (подложен). Полный список шага --
  build/deps/src/.../BundledMavenDownloader.kt.
- Попытка 7: упала на jcef-windows-x64-262-b37.tar.gz (подложен, 157 MB).
  JBR jbr_jcef-25.0.3-windows-x64-b508.4 подложен заранее (261 MB).
  Имя в кэше: base36(sha256(url+"V3")).substring(0,10) + "-" + имя файла.
- Попытка 8: упала -- в рабочем дереве нет LICENSE.txt (следствие аномалии
  индекса). Восстановлен через git show HEAD:LICENSE.txt (индекс не тронут).
- Попытка 9 (идёт): все известные блокеры сняты.

## Рецепт при сетевых сбоях загрузок сборки

1. В D:\ijbuild\build.log найти строки download (target=..., url=...) рядом
   с "Exception in thread main ... attempts failed".
2. Скачать каждый файл PowerShell-ом (можно и через cache-redirector --
   PowerShell переживает то, что валит Java-клиент), для maven-артефактов
   сверить .sha1, для tar.gz -- полная проверка tar -tzf.
3. Положить в D:\Repos\intellij-community\build\download\ под именем target.
4. Перезапустить сборку (команда в секции "Трек 2"), сборка подхватит кэш:
   в логе будет "use asset from cache".

## Журнал

- 2026-07-18 ~00:xx -- старт. Репо git-tool чистый (только LICENSE).
  Выяснено: interview-project = Angular "BugHunt", источник -- intellij-community
  (plugins/git4idea на месте). Поставлен cron-сторож (10 мин).
- 2026-07-18 ~01:45 -- по запросу пользователя каденс сторожа снижен до
  1 минуты, новый job id 135754cd. Прежний STATUS.md был повреждён кодировкой
  (PowerShell -replace без BOM), перезаписан начисто.
