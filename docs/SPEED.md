# FreeForGemVela (ffgv) 0.4.0 — speed and power

## English

| GPU (power limit) | mode | auto-UV | clocks the miner set | inf/s | W | inf/s/W |
|---|---|---|---|---|---|---|
| RTX 3070 (135 W) | speed (= stock) | no | — | 34.40 | 134.5 | 0.256 |
| RTX 3070 (135 W) | balance | no | lock 1500 | 34.35 | 134.5 | 0.255 |
| RTX 3070 (135 W) | eco | no | lock 1400, mem 5001 | 31.75 | 120.1 | 0.264 |
| RTX 3070 (135 W) | speed | yes | core +225, mem +500 | 37.44 | 134.6 | 0.278 |
| RTX 3070 (135 W) | balance | yes | lock 1500, core +210, mem +500 | 35.22 | 120.0 | 0.293 |
| RTX 3070 (135 W) | eco | yes | lock 1400, mem 5001, core +300 | 31.43 | 95.9 | 0.328 |
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

What the auto-undervolt adds: **RTX 3070** — `speed` +8.8% inf/s at the same power; `balance` +2.4% inf/s at −11% power
(+15% inf/s/W); `eco` −8.6% inf/s at −29% power (**+28% inf/s/W**). **RTX 4070 Ti** runs at its power limit: the undervolt
adds +3.7% in `speed`; in `balance` / `eco` the gain comes from the clock locks (up to +5% inf/s/W at −24% power), the
undervolt on top changes little. **RTX 3080 Ti** (Windows): the clock locks give `balance` −7.5% inf/s at −21% power and
`eco` −20% inf/s at −37% power; the undervolt on top of them adds +7% inf/s/W in `balance` and +2.5% in `eco` (both stopped
at the voltage floor), so against stock `balance` is +17% inf/s/W and `eco` **+28% inf/s/W**. `speed`: +4.4% inf/s at the
same power in the table, but the tuner's own comparison on one block prompt gave +0.6% — the rest is the prompt.

How it was measured: release 0.4.0, Linux, driver 580.178, mining on AriaPool; each value is the average of the miner's
API over 3 minutes after the auto-undervolt had settled (one run per point, 31.10.2026). The prompt of the current block
changes the speed by up to ±2–3%, so differences below that are noise. RTX 3070 `speed` with auto-UV: measured with the
offsets the tuner found (+225 core, +500 memory) set as fixed offsets — the 14-minute test slot ended a second before the
tuner's final confirmation. RTX 4070 Laptop: one run at stock clocks (no administrator rights on that machine, so the
modes were not measured); the laptop sat at its 88 °C thermal limit, so its speed varied 28–31 inf/s. Your card,
cooling and silicon will give somewhat different numbers.
RTX 3080 Ti: Windows 10, driver 591.59, the Windows package started with `start.bat` as administrator, mining on suprnova
7601 / 7604 and AriaPool; the same 3-minute API average (4–5 minutes for the points without auto-UV, 31.10.2026). The
memory search of `speed` / `balance` found no gain on its GDDR6X and kept +0.

## Русский

| GPU (лимит мощности) | режим | auto-UV | частоты, которые поставил майнер | inf/s | Вт | inf/s/Вт |
|---|---|---|---|---|---|---|
| RTX 3070 (135 Вт) | speed (= сток) | нет | — | 34.40 | 134.5 | 0.256 |
| RTX 3070 (135 Вт) | balance | нет | лок 1500 | 34.35 | 134.5 | 0.255 |
| RTX 3070 (135 Вт) | eco | нет | лок 1400, память 5001 | 31.75 | 120.1 | 0.264 |
| RTX 3070 (135 Вт) | speed | да | ядро +225, память +500 | 37.44 | 134.6 | 0.278 |
| RTX 3070 (135 Вт) | balance | да | лок 1500, ядро +210, память +500 | 35.22 | 120.0 | 0.293 |
| RTX 3070 (135 Вт) | eco | да | лок 1400, память 5001, ядро +300 | 31.43 | 95.9 | 0.328 |
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

Что добавляет автоандервольт: **RTX 3070** — в `speed` +8.8% inf/s при той же мощности; в `balance` +2.4% inf/s при −11%
мощности (+15% inf/s/Вт); в `eco` −8.6% inf/s при −29% мощности (**+28% inf/s/Вт**). **RTX 4070 Ti** работает в упоре в лимит
мощности: андервольт даёт +3.7% в `speed`; в `balance` / `eco` выигрыш дают локи частот (до +5% inf/s/Вт при −24% мощности),
андервольт сверху почти ничего не меняет. **RTX 3080 Ti** (Windows): локи частот дают в `balance` −7.5% inf/s при −21% мощности,
в `eco` −20% inf/s при −37% мощности; андервольт поверх них добавляет +7% inf/s/Вт в `balance` и +2.5% в `eco` (оба
остановились на «полу напряжения»), итого к стоку `balance` +17% inf/s/Вт, `eco` **+28% inf/s/Вт**. `speed`: в таблице +4.4%
inf/s при той же мощности, но сравнение самого подбора на одном промпте блока дало +0.6% — остальное промпт.

Как мерили: релиз 0.4.0, Linux, драйвер 580.178, майнинг на AriaPool; каждое значение — среднее по API майнера за 3 минуты
после того, как автоандервольт закончил подбор (по одному прогону на точку, 31.10.2026). Промпт текущего блока меняет
скорость до ±2–3%, разница меньше этого — шум. RTX 3070 `speed` с auto-UV: замер с офсетами, которые нашёл подбор
(+225 ядро, +500 память), заданными как фиксированные — 14-минутный тестовый слот закончился за секунду до финального
подтверждения. RTX 4070 Laptop: один прогон на стоковых частотах (на этой машине нет прав администратора, поэтому режимы
не мерились); ноутбук упирался в тепловой предел 88 °C, скорость гуляла в пределах 28–31 inf/s. На вашей карте, с вашим
охлаждением цифры будут немного другими.
RTX 3080 Ti: Windows 10, драйвер 591.59, Windows-пакет, запуск `start.bat` от администратора, майнинг на suprnova 7601 / 7604
и AriaPool; то же среднее API за 3 минуты (4–5 минут для точек без auto-UV, 31.10.2026). Подбор памяти в `speed` / `balance`
на её GDDR6X прироста не нашёл и оставил +0.
