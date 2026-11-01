# FreeForGemVela (ffgv) 0.4.2 — speed and power

## English

| GPU (power limit) | mode | auto-UV | clocks the miner set | inf/s | W | inf/s/W |
|---|---|---|---|---|---|---|
| RTX 3070 (200 W ceiling) | balance | yes | lock 1500, core +240, mem +0 | 36.02 | 122.3 | 0.295 |
| RTX 3070 (200 W ceiling) | eco | yes | lock 1400, mem 5001, core +270 | 32.71 | 100.0 | 0.327 |
| RTX 4070 Ti (235 W) | speed (= stock) | no | — | 72.82 | 234.1 | 0.311 |
| RTX 4070 Ti (235 W) | balance | no | lock 2250 | 66.17 | 178.5 | 0.371 |
| RTX 4070 Ti (235 W) | eco | no | lock 2100, mem 5001 | 54.01 | 141.1 | 0.383 |
| RTX 4070 Ti (235 W) | speed | yes | core +180 | 75.09 | 234.2 | 0.321 |
| RTX 4070 Ti (235 W) | balance | yes | lock 2250, core +300 | 65.94 | 177.8 | 0.371 |
| RTX 4070 Ti (235 W) | eco | yes | lock 2100, mem 5001, core +180 | 53.99 | 143.0 | 0.378 |
| RTX 3080 Ti (350 W), 0.4.0 | speed (= stock) | no | — | 61.45 | 334.6 | 0.184 |
| RTX 3080 Ti (350 W), 0.4.0 | balance | no | lock 1500 | 56.94 | 283.0 | 0.201 |
| RTX 3080 Ti (350 W), 0.4.0 | eco | no | lock 1400, mem 5001 | 49.43 | 215.2 | 0.230 |
| RTX 3080 Ti (350 W), 0.4.0 | speed | yes | core +165 | 64.16 | 333.0 | 0.193 |
| RTX 3080 Ti (350 W), 0.4.0 | balance | yes | lock 1500, core +120 | 56.85 | 263.7 | 0.216 |
| RTX 3080 Ti (350 W), 0.4.0 | eco | yes | lock 1400, mem 5001, core +225 | 49.35 | 209.6 | 0.235 |
| RTX 4070 Laptop (laptop limit), 0.4.0 | stock | no | — | 30.05 | 67.9 | 0.443 |

The power limit is only a ceiling here (RTX 3070 200 W, RTX 4070 Ti 235 W): the mode sets the clocks, the undervolt the
voltage. **RTX 3070:** `balance` with the undervolt mines at 122 W, `eco` at 100 W (+11% inf/s/W for −9% inf/s against
`balance`); a HiveOS rig of four RTX 3070 in `balance` made 142.1 inf/s at 464 W. **RTX 4070 Ti** with the full 235 W:
`speed` +3.1% inf/s from the undervolt at the same power; the clock locks of `balance` / `eco` cut the power by 24% / 40%
for −9% / −26% inf/s (+19% / +23% inf/s/W), the undervolt on top of a lock changes little. **RTX 3080 Ti** (Windows, 0.4.0
engine — 0.4.2 is ~3–4% faster at the same clocks): the clock locks give `balance` −7.5% inf/s at −21% power and `eco` −20%
inf/s at −37% power; the undervolt on top adds +7% inf/s/W in `balance` and +2.5% in `eco`.

How it was measured: release 0.4.2, Linux, driver 580.178, mining on AriaPool; each value is the average of the miner's
API over 3 minutes after the auto-undervolt had settled (one run per point, 01.11.2026; the undervolt profiles tuned from
scratch). The prompt of the current block changes the speed by up to ±2–3%, so differences below that are noise. The
RTX 3070 rows without the undervolt and `speed` were not measured again for 0.4.2. RTX 4070 Laptop: one run of 0.4.0 at
stock clocks at its 88 °C thermal limit (28–31 inf/s). Your card, cooling and silicon will give somewhat different numbers.
RTX 3080 Ti: Windows 10, driver 591.59, the Windows package started with `start.bat` as administrator, mining on suprnova
7601 / 7604 and AriaPool; the same 3-minute API average (4–5 minutes for the points without auto-UV, 31.10.2026). The
memory search of `speed` / `balance` found no gain on its GDDR6X and kept +0.

Full step-by-step guide for beginners (wallet, Windows, HiveOS, Linux, pools, modes, troubleshooting): **[MANUAL.md](MANUAL.md)** ·
HiveOS flight sheet (with a ready one to import): [HIVEOS.md](HIVEOS.md) · changes: [CHANGELOG.md](CHANGELOG.md).

## Русский

| GPU (лимит мощности) | режим | auto-UV | частоты, которые поставил майнер | inf/s | Вт | inf/s/Вт |
|---|---|---|---|---|---|---|
| RTX 3070 (потолок 200 Вт) | balance | да | лок 1500, ядро +240, память +0 | 36.02 | 122.3 | 0.295 |
| RTX 3070 (потолок 200 Вт) | eco | да | лок 1400, память 5001, ядро +270 | 32.71 | 100.0 | 0.327 |
| RTX 4070 Ti (235 Вт) | speed (= сток) | нет | — | 72.82 | 234.1 | 0.311 |
| RTX 4070 Ti (235 Вт) | balance | нет | лок 2250 | 66.17 | 178.5 | 0.371 |
| RTX 4070 Ti (235 Вт) | eco | нет | лок 2100, память 5001 | 54.01 | 141.1 | 0.383 |
| RTX 4070 Ti (235 Вт) | speed | да | ядро +180 | 75.09 | 234.2 | 0.321 |
| RTX 4070 Ti (235 Вт) | balance | да | лок 2250, ядро +300 | 65.94 | 177.8 | 0.371 |
| RTX 4070 Ti (235 Вт) | eco | да | лок 2100, память 5001, ядро +180 | 53.99 | 143.0 | 0.378 |
| RTX 3080 Ti (350 Вт), 0.4.0 | speed (= сток) | нет | — | 61.45 | 334.6 | 0.184 |
| RTX 3080 Ti (350 Вт), 0.4.0 | balance | нет | лок 1500 | 56.94 | 283.0 | 0.201 |
| RTX 3080 Ti (350 Вт), 0.4.0 | eco | нет | лок 1400, память 5001 | 49.43 | 215.2 | 0.230 |
| RTX 3080 Ti (350 Вт), 0.4.0 | speed | да | ядро +165 | 64.16 | 333.0 | 0.193 |
| RTX 3080 Ti (350 Вт), 0.4.0 | balance | да | лок 1500, ядро +120 | 56.85 | 263.7 | 0.216 |
| RTX 3080 Ti (350 Вт), 0.4.0 | eco | да | лок 1400, память 5001, ядро +225 | 49.35 | 209.6 | 0.235 |
| RTX 4070 Laptop (лимит ноутбука), 0.4.0 | сток | нет | — | 30.05 | 67.9 | 0.443 |

Лимит мощности здесь — только потолок (RTX 3070 200 Вт, RTX 4070 Ti 235 Вт): частоты задаёт режим, напряжение —
андервольт. **RTX 3070:** `balance` с андервольтом майнит при 122 Вт, `eco` — при 100 Вт (+11% inf/s/Вт при −9% inf/s к
`balance`); риг HiveOS из четырёх RTX 3070 в `balance` дал 142,1 inf/s при 464 Вт. **RTX 4070 Ti** с полными 235 Вт: `speed`
+3,1% inf/s от андервольта при той же мощности; локи `balance` / `eco` снижают мощность на 24% / 40% ценой −9% / −26% inf/s
(+19% / +23% inf/s/Вт), андервольт поверх лока почти ничего не меняет. **RTX 3080 Ti** (Windows, движок 0.4.0 — 0.4.2 на тех же
частотах быстрее на ~3–4%): локи дают в `balance` −7.5% inf/s при −21% мощности, в `eco` −20% inf/s при −37% мощности;
андервольт поверх них добавляет +7% inf/s/Вт в `balance` и +2.5% в `eco`.

Как мерили: релиз 0.4.2, Linux, драйвер 580.178, майнинг на AriaPool; каждое значение — среднее по API майнера за 3 минуты
после окончания подбора (по одному прогону на точку, 01.11.2026; профили андервольта подобраны с нуля). Промпт текущего блока
меняет скорость до ±2–3%, разница меньше этого — шум. Строки RTX 3070 без андервольта и `speed` для 0.4.2 не перемерялись.
RTX 4070 Laptop: один прогон 0.4.0 на стоке в тепловом пределе 88 °C (28–31 inf/s). На вашей карте, с вашим охлаждением цифры
будут немного другими.
RTX 3080 Ti: Windows 10, драйвер 591.59, Windows-пакет, запуск `start.bat` от администратора, майнинг на suprnova 7601 / 7604
и AriaPool; то же среднее API за 3 минуты (4–5 минут для точек без auto-UV, 31.10.2026). Подбор памяти в `speed` / `balance`
на её GDDR6X прироста не нашёл и оставил +0.

Подробное пошаговое руководство для новичков (кошелёк, Windows, HiveOS, Linux, пулы, режимы, типичные проблемы): **[MANUAL.ru.md](MANUAL.ru.md)** ·
полётный лист HiveOS (с готовым для импорта): [HIVEOS.md](HIVEOS.md#русский) · изменения: [CHANGELOG.md](CHANGELOG.md).
