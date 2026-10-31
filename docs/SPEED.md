# FreeForGemVela (ffgv) 0.4.0 — speed and power

## English

| GPU (power limit) | mode | auto-UV | clocks the miner set | inf/s | W | inf/s/W |
|---|---|---|---|---|---|---|
| RTX 3070 (200 W cap) | speed (= stock) | no | — (runs into the 200 W cap) | 39.34 | 199.4 | 0.197 |
| RTX 3070 (200 W cap) | balance | no | lock 1500 | 35.29 | 147.2 | 0.240 |
| RTX 3070 (200 W cap) | eco | no | lock 1400, mem 5001 | 31.88 | 123.6 | 0.258 |
| RTX 3070 (200 W cap) | speed | yes | core +120 | 40.02 | 199.4 | 0.201 |
| RTX 3070 (200 W cap) | balance | yes | lock 1500, core +165, mem +250 | 35.15 | 127.3 | 0.276 |
| RTX 3070 (200 W cap) | eco | yes | lock 1400, mem 5001, core +195 | 31.52 | 105.2 | 0.300 |
| RTX 4070 Ti (190 W) | speed (= stock) | no | — | 65.28 | 189.3 | 0.345 |
| RTX 4070 Ti (190 W) | balance | no | lock 2250 | 64.14 | 179.2 | 0.358 |
| RTX 4070 Ti (190 W) | eco | no | lock 2100, mem 5001 | 52.52 | 144.7 | 0.363 |
| RTX 4070 Ti (190 W) | speed | yes | core +180 | 67.69 | 189.6 | 0.357 |
| RTX 4070 Ti (190 W) | balance | yes | lock 2250, core +150 | 63.89 | 181.8 | 0.351 |
| RTX 4070 Ti (190 W) | eco | yes | lock 2100, mem 5001, core +165 | 52.45 | 145.4 | 0.361 |
| RTX 3080 Ti (350 W) | speed (= stock) | no | — | 61.45 | 334.6 | 0.184 |
| RTX 3080 Ti (350 W) | balance | no | lock 1500 | 56.94 | 283.0 | 0.201 |
| RTX 3080 Ti (350 W) | eco | no | lock 1400, mem 5001 | 49.43 | 215.2 | 0.230 |
| RTX 3080 Ti (350 W) | speed | yes | core +165 | 64.16 | 333.0 | 0.193 |
| RTX 3080 Ti (350 W) | balance | yes | lock 1500, core +120 | 56.85 | 263.7 | 0.216 |
| RTX 3080 Ti (350 W) | eco | yes | lock 1400, mem 5001, core +225 | 49.35 | 209.6 | 0.235 |
| RTX 4070 Laptop (laptop limit) | stock | no | — | 30.05 | 67.9 | 0.443 |

What the auto-undervolt adds: **RTX 3070** (power limit 200 W used only as a safety cap): `speed` has no clock lock and runs into the cap, the undervolt adds +1.7% inf/s at the same power; the clock locks of `balance` / `eco` cut the power by 26% / 38% for −10% / −19% inf/s, and the undervolt on top adds +15% / +16% inf/s/W, so against stock `balance` is +40% inf/s/W and `eco` **+52% inf/s/W**. **RTX 4070 Ti** runs at its power limit: the undervolt
adds +3.7% in `speed`; in `balance` / `eco` the gain comes from the clock locks (up to +5% inf/s/W at −24% power), the
undervolt on top changes little. **RTX 3080 Ti** (Windows): the clock locks give `balance` −7.5% inf/s at −21% power and
`eco` −20% inf/s at −37% power; the undervolt on top of them adds +7% inf/s/W in `balance` and +2.5% in `eco` (both stopped
at the voltage floor), so against stock `balance` is +17% inf/s/W and `eco` **+28% inf/s/W**. `speed`: +4.4% inf/s at the
same power in the table, but the tuner's own comparison on one block prompt gave +0.6% — the rest is the prompt.

How it was measured: release 0.4.0, Linux, driver 580.178, mining on AriaPool; each value is the average of the miner's
API over 3 minutes after the auto-undervolt had settled (one run per point, 31.10.2026). The prompt of the current block
changes the speed by up to ±2–3%, so differences below that are noise. RTX 3070: re-measured on 01.11.2026 with the power limit raised to 200 W, so the limit no longer cuts the locked modes (we do not load a 3070 above ~200 W: the cooling may not keep up; the clock lock and the core offset set the power, the limit is only a safety cap); all six points on one card, the undervolt tuned from scratch, peak 76 °C. The undervolt headroom differs between cards of the same model: on another RTX 3070 the tuner found +210…+300 core instead of +165…+195. RTX 4070 Laptop: one run at stock clocks (no administrator rights on that machine, so the
modes were not measured); the laptop sat at its 88 °C thermal limit, so its speed varied 28–31 inf/s. Your card,
cooling and silicon will give somewhat different numbers.
RTX 3080 Ti: Windows 10, driver 591.59, the Windows package started with `start.bat` as administrator, mining on suprnova
7601 / 7604 and AriaPool; the same 3-minute API average (4–5 minutes for the points without auto-UV, 31.10.2026). The
memory search of `speed` / `balance` found no gain on its GDDR6X and kept +0.

## Русский

| GPU (лимит мощности) | режим | auto-UV | частоты, которые поставил майнер | inf/s | Вт | inf/s/Вт |
|---|---|---|---|---|---|---|
| RTX 3070 (потолок 200 Вт) | speed (= сток) | нет | — (упирается в потолок 200 Вт) | 39.34 | 199.4 | 0.197 |
| RTX 3070 (потолок 200 Вт) | balance | нет | лок 1500 | 35.29 | 147.2 | 0.240 |
| RTX 3070 (потолок 200 Вт) | eco | нет | лок 1400, память 5001 | 31.88 | 123.6 | 0.258 |
| RTX 3070 (потолок 200 Вт) | speed | да | ядро +120 | 40.02 | 199.4 | 0.201 |
| RTX 3070 (потолок 200 Вт) | balance | да | лок 1500, ядро +165, память +250 | 35.15 | 127.3 | 0.276 |
| RTX 3070 (потолок 200 Вт) | eco | да | лок 1400, память 5001, ядро +195 | 31.52 | 105.2 | 0.300 |
| RTX 4070 Ti (190 Вт) | speed (= сток) | нет | — | 65.28 | 189.3 | 0.345 |
| RTX 4070 Ti (190 Вт) | balance | нет | лок 2250 | 64.14 | 179.2 | 0.358 |
| RTX 4070 Ti (190 Вт) | eco | нет | лок 2100, память 5001 | 52.52 | 144.7 | 0.363 |
| RTX 4070 Ti (190 Вт) | speed | да | ядро +180 | 67.69 | 189.6 | 0.357 |
| RTX 4070 Ti (190 Вт) | balance | да | лок 2250, ядро +150 | 63.89 | 181.8 | 0.351 |
| RTX 4070 Ti (190 Вт) | eco | да | лок 2100, память 5001, ядро +165 | 52.45 | 145.4 | 0.361 |
| RTX 3080 Ti (350 Вт) | speed (= сток) | нет | — | 61.45 | 334.6 | 0.184 |
| RTX 3080 Ti (350 Вт) | balance | нет | лок 1500 | 56.94 | 283.0 | 0.201 |
| RTX 3080 Ti (350 Вт) | eco | нет | лок 1400, память 5001 | 49.43 | 215.2 | 0.230 |
| RTX 3080 Ti (350 Вт) | speed | да | ядро +165 | 64.16 | 333.0 | 0.193 |
| RTX 3080 Ti (350 Вт) | balance | да | лок 1500, ядро +120 | 56.85 | 263.7 | 0.216 |
| RTX 3080 Ti (350 Вт) | eco | да | лок 1400, память 5001, ядро +225 | 49.35 | 209.6 | 0.235 |
| RTX 4070 Laptop (лимит ноутбука) | сток | нет | — | 30.05 | 67.9 | 0.443 |

Что добавляет автоандервольт: **RTX 3070** (лимит мощности 200 Вт — только аварийный потолок): `speed` без лока частоты упирается в потолок, андервольт добавляет +1.7% inf/s при той же мощности; локи частот `balance` / `eco` снижают мощность на 26% / 38% ценой −10% / −19% inf/s, андервольт поверх них даёт +15% / +16% inf/s/Вт, итого к стоку `balance` +40% inf/s/Вт, `eco` **+52% inf/s/Вт**. **RTX 4070 Ti** работает в упоре в лимит
мощности: андервольт даёт +3.7% в `speed`; в `balance` / `eco` выигрыш дают локи частот (до +5% inf/s/Вт при −24% мощности),
андервольт сверху почти ничего не меняет. **RTX 3080 Ti** (Windows): локи частот дают в `balance` −7.5% inf/s при −21% мощности,
в `eco` −20% inf/s при −37% мощности; андервольт поверх них добавляет +7% inf/s/Вт в `balance` и +2.5% в `eco` (оба
остановились на «полу напряжения»), итого к стоку `balance` +17% inf/s/Вт, `eco` **+28% inf/s/Вт**. `speed`: в таблице +4.4%
inf/s при той же мощности, но сравнение самого подбора на одном промпте блока дало +0.6% — остальное промпт.

Как мерили: релиз 0.4.0, Linux, драйвер 580.178, майнинг на AriaPool; каждое значение — среднее по API майнера за 3 минуты
после того, как автоандервольт закончил подбор (по одному прогону на точку, 31.10.2026). Промпт текущего блока меняет
скорость до ±2–3%, разница меньше этого — шум. RTX 3070: перемерено 01.11.2026 с лимитом мощности, поднятым до 200 Вт, — лимит больше не срезает режимы с локом (3070 мы не нагружаем выше ~200 Вт: охлаждение может не справиться; мощность задают лок частоты и оффсет ядра, лимит — только аварийный потолок); все шесть точек на одной карте, андервольт подобран заново, пик 76 °C. Запас андервольта у карт одной модели разный: на другой RTX 3070 подбор нашёл +210…+300 по ядру вместо +165…+195. RTX 4070 Laptop: один прогон на стоковых частотах (на этой машине нет прав администратора, поэтому режимы
не мерились); ноутбук упирался в тепловой предел 88 °C, скорость гуляла в пределах 28–31 inf/s. На вашей карте, с вашим
охлаждением цифры будут немного другими.
RTX 3080 Ti: Windows 10, драйвер 591.59, Windows-пакет, запуск `start.bat` от администратора, майнинг на suprnova 7601 / 7604
и AriaPool; то же среднее API за 3 минуты (4–5 минут для точек без auto-UV, 31.10.2026). Подбор памяти в `speed` / `balance`
на её GDDR6X прироста не нашёл и оставил +0.
