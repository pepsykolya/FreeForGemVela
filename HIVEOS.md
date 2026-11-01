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
{"name":"ffgv VELA suprnova","isFavorite":false,"items":[{"coin":"VELA","pool_ssl":false,"pool_urls":["stratum+ssl://vela.suprnova.cc:7604"],"dpool_ssl":false,"miner":"custom","miner_alt":"ffgv-hive","miner_config":{"url":"stratum+ssl://vela.suprnova.cc:7604 http://159.69.194.46:3349","algo":"vela","pass":"x","miner":"ffgv-hive","template":"%WAL%.%WORKER_NAME%","install_url":"https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.2/ffgv-hive-0.4.2.tar.gz","user_config":"--mode balance"},"pool_geo":[]}]}
```

3. Pick your `VELA` wallet in the red-marked field (the import carries no wallet), **Create flight sheet**, apply it to the rig.

If HiveOS refuses the import, use the manual way — the result is the same.

### Flight sheet: manual way

Coin `VELA`, Wallet: yours, Pool: *Configure in miner*, Miner: **Custom** → *Setup Miner Config*:

| Field | Value |
|---|---|
| Miner name | `ffgv-hive` (filled in automatically from the URL) |
| Installation URL | `https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.2/ffgv-hive-0.4.2.tar.gz` |
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
`--no-update-check` (otherwise the version column shows `new X` when a newer release is out), per-GPU lists without spaces
(`--lock-cclock 1500,1400`). **Updating:** HiveOS caches archives by file name — use the new Installation URL of each release.

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
| Installation URL | `https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.2/ffgv-hive-0.4.2.tar.gz` |
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
(иначе в колонке версии появится `new X`, когда выйдет новая версия), списки по картам без пробелов (`--lock-cclock 1500,1400`).
**Обновление:** HiveOS кэширует архивы по имени файла — берите новый Installation URL каждого релиза.
