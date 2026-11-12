# FreeForGemVela (ffgv) on HiveOS

[English](#english) · [Русский](#русский)

## English

### Pools

| Pool | Pool URL in the flight sheet | Notes |
|---|---|---|
| suprnova (TLS) | `stratum+ssl://vela.suprnova.cc:7604` | vardiff, encrypted; PPLNS, 1% fee, payouts from 0.01 VELA |
| suprnova (TCP) | `stratum+tcp://vela.suprnova.cc:7601` | vardiff; `:7602` fixed 2048, `:7603` fixed 16384 |
| AriaPool | `http://159.69.194.46:3349` | vardiff on the pool side |
| solo (your node) | `http://RPCUSER:RPCPASS@NODE_IP:19732` | see `solo/vela.conf.example` and MANUAL §8 |

Several URLs separated by spaces = failover (the first is the primary).

### Flight sheet: quick way (Import from Clipboard)

1. **Wallets** → add a wallet: coin `VELA` (type the name if HiveOS does not know the coin), your `vela1...` address.
2. **Flight Sheets** → **Import from Clipboard** and paste:

```json
{"name":"ffgv VELA suprnova","isFavorite":false,"items":[{"coin":"VELA","pool_ssl":false,"pool_urls":["stratum+ssl://vela.suprnova.cc:7604"],"dpool_ssl":false,"miner":"custom","miner_alt":"ffgv-hive","miner_config":{"url":"stratum+ssl://vela.suprnova.cc:7604 http://159.69.194.46:3349","algo":"vela","pass":"x","miner":"ffgv-hive","template":"%WAL%.%WORKER_NAME%","install_url":"https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.6/ffgv-hive-0.4.6.tar.gz","user_config":"--mode balance"},"pool_geo":[]}]}
```

3. Pick your `VELA` wallet in the red-marked field (the import carries no wallet), **Create flight sheet**, apply it to the rig.

If HiveOS refuses the import, use the manual way — the result is the same.

### Flight sheet: manual way

Coin `VELA`, Wallet: yours, Pool: *Configure in miner*, Miner: **Custom** → *Setup Miner Config*:

| Field | Value |
|---|---|
| Miner name | `ffgv-hive` (filled in automatically from the URL) |
| Installation URL | `https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.6/ffgv-hive-0.4.6.tar.gz` |
| Hash algorithm | `vela` |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | `stratum+ssl://vela.suprnova.cc:7604` (or another pool from the table) |
| Pass | `x` |
| Extra config arguments | `--mode balance` (or `speed`, `eco`, empty; `--devices 0,2`, ...) |

The first start downloads the model (1.19 GB, sha256 checked) into `/hive/miners/custom/vela-model`.
Log: `miner log`, or `/var/log/miner/ffgv-hive/ffgv-hive.log`. The dashboard shows inf/s per GPU (1 "hash" = 1 inference),
temperatures, fans, accepted / rejected shares. Undervolt profiles: `/hive-config/ffgv`.

**OC profile:** with `--mode` the miner sets clocks and the undervolt itself and puts them back when it stops. Keep the
HiveOS OC profile for fans / power limit only; do not set a core offset there at the same time. A memory clock lock of the
profile (810 MHz in SASEUL / Pearl profiles) is lifted by `--mode speed` / `balance` while mining. If you change the OC
in the web UI while the miner runs, the miner sets its own locks / power limit again within ~10 s; `miner stop` lets the
GPUs finish their batch, then puts the profile's values back. Details: MANUAL §6, §10.

**More in Extra config arguments (0.4.2):** `--auto-lock` (the miner picks the core lock per GPU, saved in
`/hive-config/ffgv`), `--api 4078` with `/summary`, `/gpus`, `/metrics` (h-stats keeps working either way),
`--no-update-check` (otherwise the version column shows `need update!!` when a newer release is out), per-GPU lists without spaces
(`--lock-cclock 1500,1400`). **Updating:** HiveOS caches archives by file name — use the new Installation URL of each release.

**Lanes (0.4.6):** a CMP 50HX, an RTX 3070 and an RTX 4070 Ti get 2 lanes by themselves (CMP 50HX: +3.4..+4% measured on one 5-card rig, if at least 900 MiB of the
rig's RAM is free; otherwise the card stays on 1 lane and the log says why). **To switch that off, put `--lanes 1` into Extra config arguments**, e.g.
`--mode balance --lanes 1`; the same field takes `--lanes 2` for other cards and `--lane-sync on|off`. Do not edit `wallet.conf` on the rig for it: HiveOS
writes that file again from the flight sheet at every reboot and every flight sheet push. A new or copied flight sheet needs the flag again. Each extra lane
takes 1.5-2.5 GB of VRAM; `--lanes 2` with a 0.4.5 package is slower, not faster (the second lane of 0.4.5 is an incomplete copy). The CMP numbers come from
one rig, which rebooted by itself twice while separate test processes ran two lanes on one card (cause not found; the miner on 2 lanes ran for hours without
trouble): if your rig starts to reboot with 0.4.6, add `--lanes 1` and tell us. Table and numbers: MANUAL §4b.

**CMP cards (0.4.3):** under the stock NVIDIA driver a CMP card (CMP 50HX and the family) makes about a tenth of its speed.
To let the miner install the CMP unlock driver, add `--cmp-unlock-driver` to Extra config arguments (the miner does not
get it). It checks, installs only if the driver is not in place yet, and **reboots the rig**; a rig that already has it is left
alone. It replaces the NVIDIA driver of the whole rig: read MANUAL §6 (CMP cards) first. By hand: `sudo ./ffgv --cmp-driver`.

## Русский

### Пулы

| Пул | Pool URL в полётном листе | Примечание |
|---|---|---|
| suprnova (TLS) | `stratum+ssl://vela.suprnova.cc:7604` | vardiff, шифрование; PPLNS, комиссия 1%, выплаты от 0.01 VELA |
| suprnova (TCP) | `stratum+tcp://vela.suprnova.cc:7601` | vardiff; `:7602` фиксированная 2048, `:7603` фиксированная 16384 |
| AriaPool | `http://159.69.194.46:3349` | vardiff на стороне пула |
| соло (своя нода) | `http://RPCUSER:RPCPASS@IP_НОДЫ:19732` | см. `solo/vela.conf.example` и MANUAL §8 |

Несколько URL через пробел — резервные пулы (первый основной).

### Полётный лист: быстрый способ (Import from Clipboard)

1. **Wallets** → добавьте кошелёк: монета `VELA` (впишите, если HiveOS её не знает), ваш адрес `vela1...`.
2. **Flight Sheets** → **Import from Clipboard** и вставьте JSON из английского раздела выше.
3. Выберите свой кошелёк `VELA` в поле, отмеченном красным (импорт кошелёк не переносит), **Create flight sheet**, примените к ригу.

Если HiveOS не принимает импорт — заполните вручную, результат тот же.

### Полётный лист: вручную

Coin `VELA`, Wallet: ваш, Pool: *Configure in miner*, Miner: **Custom** → *Setup Miner Config*:

| Поле | Значение |
|---|---|
| Miner name | `ffgv-hive` (подставится сам из URL) |
| Installation URL | `https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.6/ffgv-hive-0.4.6.tar.gz` |
| Hash algorithm | `vela` |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | `stratum+ssl://vela.suprnova.cc:7604` (или другой пул из таблицы) |
| Pass | `x` |
| Extra config arguments | `--mode balance` (или `speed`, `eco`, пусто; `--devices 0,2`, ...) |

Первый запуск скачивает модель (1.19 ГБ, с проверкой sha256) в `/hive/miners/custom/vela-model`.
Лог: `miner log` или `/var/log/miner/ffgv-hive/ffgv-hive.log`. Панель показывает inf/s по картам (1 «хеш» = 1 инференция),
температуры, вентиляторы, принятые и отклонённые шары. Профили андервольта: `/hive-config/ffgv`.

**OC-профиль:** с `--mode` майнер сам ставит частоты и андервольт и возвращает их при остановке (`speed` / `balance`
снимают и лок памяти профиля, например 810 МГц от SASEUL / Pearl). OC-профиль HiveOS
оставьте только для вентиляторов / лимита мощности; офсет ядра в нём одновременно не задавайте. Если сменить OC в
веб-панели во время работы майнера, он за ~10 с вернёт свои локи / лимит мощности; `miner stop` даёт картам доделать
батч, затем возвращает значения профиля. Подробнее: MANUAL §6, §10.

**Ещё в Extra config arguments (0.4.2):** `--auto-lock` (майнер сам выбирает лок ядра по картам, сохраняется в
`/hive-config/ffgv`), `--api 4078` с `/summary`, `/gpus`, `/metrics` (h-stats работает в любом случае), `--no-update-check`
(иначе в колонке версии появится `need update!!`, когда выйдет новая версия), списки по картам без пробелов (`--lock-cclock 1500,1400`).
**Обновление:** HiveOS кэширует архивы по имени файла — берите новый Installation URL каждого релиза.

**Лейны (0.4.6):** CMP 50HX, RTX 3070 и RTX 4070 Ti получают 2 лейны сами (CMP 50HX: +3.4..+4% по замерам на одном риге из 5 карт, если свободно не меньше
900 МиБ ОЗУ рига; иначе карта остаётся на одной лейне, причина — в логе). **Чтобы это выключить, впишите `--lanes 1` в Extra config arguments**, например
`--mode balance --lanes 1`; в то же поле вписываются `--lanes 2` для других карт и `--lane-sync on|off` (синхронный запуск лейн). Не правьте ради этого
`wallet.conf` на риге: HiveOS перезаписывает его из полётного листа при каждой перезагрузке и каждый раз, когда лист применяется заново. В новый или
скопированный полётный лист флаг нужно вписать заново. Каждая дополнительная лейна занимает 1.5-2.5 ГБ видеопамяти; с пакетом 0.4.5 `--lanes 2` работает
медленнее, а не быстрее (вторая лейна в 0.4.5 — неполная копия движка). Цифры по CMP получены на одном риге, который дважды сам перезагрузился, когда
отдельные тестовые процессы гоняли две лейны на одной карте (причина не установлена; сам майнер на двух лейнах часами работал без сбоев): если с 0.4.6
ваш риг начнёт перезагружаться, добавьте `--lanes 1` и сообщите нам. Таблица и цифры: MANUAL §4б.

**Карты CMP (0.4.3):** под штатным драйвером NVIDIA карта CMP (CMP 50HX и семейство) даёт около десятой части скорости.
Чтобы майнер сам поставил драйвер-разблокировку CMP, добавьте `--cmp-unlock-driver` в Extra config arguments (майнеру оно
не передаётся). Он проверяет, ставит драйвер только если его ещё нет, и **перезагружает риг**; риг, где драйвер уже стоит,
не трогается. Это заменяет драйвер NVIDIA на всём риге: сначала прочитайте MANUAL §6 (карты CMP). Вручную: `sudo ./ffgv --cmp-driver`.
