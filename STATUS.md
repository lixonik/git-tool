# STATUS

STATE: DONE

GitTool готов в двух вариантах, оба запущены и проверены (git-подсистема
поднимается, репозиторий открывается, Classic UI активен, ошибок в idea.log нет).

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
