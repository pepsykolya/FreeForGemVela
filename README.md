# FreeForGemVela (ffgv) 0.4.1

Native GPU miner for **VELA** (Proof-of-Inference, integer sd-turbo) on NVIDIA RTX 30 / 40 / 50.
HiveOS and Windows packages. Dev fee **1%**. Русская версия — [README.ru.md](README.ru.md).

- Every share is computed bit-exact to the VELA node's consensus code and re-checked before it is sent.
- Built-in auto-undervolt checked by consensus canaries (an undervolted GPU on VELA first computes a *wrong* result
  without crashing, so the miner tests every setting byte for byte against known results).
- Ready modes `speed`, `balance`, `eco`; hang watchdog; pool failover; stratum over TLS; JSON API.

## Download

Release page: https://github.com/pepsykolya/FreeForGemVela/releases/tag/v0.4.1

| package | file |
|---|---|
| HiveOS (custom miner) | https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.1/ffgv-hive-0.4.1.tar.gz |
| Linux x86_64 | https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.1/ffgv-0.4.1-linux-x86_64.tar.gz |
| Windows x64 | https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.0/ffgv-0.4.0-windows-x64.zip |
| checksums | https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.1/SHA256SUMS |

The miner binary is `ffgv` (`ffgv.exe` on Windows).

## Speed and power

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

Full step-by-step guide for beginners (wallet, Windows, HiveOS, Linux, pools, modes, troubleshooting): **[MANUAL.md](MANUAL.md)** ·
HiveOS flight sheet (with a ready one to import): [HIVEOS.md](HIVEOS.md) · changes: [CHANGELOG.md](CHANGELOG.md).

## Requirements

- NVIDIA RTX 30 (sm_86), RTX 40 (sm_89) or RTX 50 (sm_120); 6 GB VRAM or more (8 GB recommended).
- NVIDIA driver with CUDA 12 support (R525 or newer; RTX 50 needs R570 or newer). Tested on 580.178 (Linux) and 576.57 (Windows).
  Memory offset (`--moffset`, auto-undervolt of memory) needs R555 or newer.
- Linux x86_64 (HiveOS or any glibc distribution) or Windows 10/11 x64.
- Clock control and undervolt need root (HiveOS runs miners as root) or "Run as administrator" on Windows.
- The model `sd-turbo-int.poisd` (1.19 GB, 1 187 585 285 bytes). The start scripts download it once and check it:
  - https://huggingface.co/valereseach/vela-sd-turbo-int-v2/resolve/main/sd-turbo-int.poisd (official)
  - https://dl.ariabrain.com/vela-dl/sd-turbo-int.poisd (mirror)
  - sha256 `ba38ab96b3398e22ea631d8a457350f91833e57463199d063663308513651f36`

## HiveOS

Flight sheet: Coin **VELA** (add a custom coin if it is not in the list), your wallet, Pool **Configure in miner**,
Miner **Custom** → Setup Miner Config:

| field | value |
|---|---|
| Miner name | `ffgv-hive` (filled in from the URL) |
| Installation URL | `https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.1/ffgv-hive-0.4.1.tar.gz` |
| Hash algorithm | `vela` |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | see the pool examples below (several, space separated = failover) |
| Pass | `x` (or empty) |
| Extra config arguments | e.g. `--mode balance` |

On the first start `h-run.sh` downloads the model into `/hive/miners/custom/vela-model` (one copy per rig) and checks
its sha256. Undervolt profiles and crash records are kept in `/hive-config/ffgv` (they survive miner updates).
The miner's clock settings win over the HiveOS OC profile while it runs, and the original values are put back on stop.
`--mode speed` / `balance` also lift a memory lock of the OC profile (SASEUL / Pearl profiles lock the memory to 810 MHz,
which costs VELA ~75% of its speed); `--lock-mclock` sets your own lock instead. The first start tunes the undervolt
(30 MHz steps, 15 MHz near the edge), about 5–10 minutes with mining going on; later starts only re-check the profile.
The HiveOS dashboard reads speed, temperatures, fans, accepted/rejected shares from the miner's API (`h-stats.sh`, port 4078).

## Windows

1. Unpack `ffgv-0.4.0-windows-x64.zip` to a folder without spaces, e.g. `C:\FreeForGemVela`.
2. Right-click `start.bat` → Edit: set `WALLET` to **your** address (the example address is the developer's), `POOL`, `WORKER`,
   optionally `MODE=balance`.
3. Run `start.bat` (as administrator if you use `MODE`, `AUTO_UV` or clock settings). The first start downloads the model
   (1.19 GB, sha256 checked). The window is the log; Ctrl+C stops the miner and puts your GPU settings back.

See `README-WINDOWS.txt` in the package for every field.

## Pools

```
# AriaPool
ffgv --pool http://159.69.194.46:3349 --user vela1YOURADDRESS.rig1
# suprnova, stratum over TCP / over TLS (encrypted)
ffgv --pool stratum+tcp://vela.suprnova.cc:7601 --user vela1YOURADDRESS.rig1
ffgv --pool stratum+ssl://vela.suprnova.cc:7604 --user vela1YOURADDRESS.rig1
# solo through your own synced VELA node (RPC)
ffgv --pool http://RPCUSER:RPCPASS@127.0.0.1:19732 --user vela1YOURADDRESS
# failover: the first pool is primary, the next ones are backups
ffgv --pool stratum+ssl://vela.suprnova.cc:7604 --pool http://159.69.194.46:3349 --user vela1YOURADDRESS.rig1 --mode balance
```

HiveOS Pool URL for the same: `http://159.69.194.46:3349`, `stratum+tcp://vela.suprnova.cc:7601`, `stratum+ssl://vela.suprnova.cc:7604`,
`http://RPCUSER:RPCPASS@NODE_IP:19732`. suprnova also accepts `--suggest-diff D` (start share difficulty).

## Modes and auto-undervolt

| mode | RTX 30 | RTX 40 |
|---|---|---|
| `speed` | no clock lock, memory up to +750 | no clock lock |
| `balance` | core lock 1500, memory up to +1000 | core lock 2250 |
| `eco` | core lock 1400, memory locked at 5001 | core lock 2100, memory locked at 5001 |

Every mode turns on the auto-undervolt. RTX 50 and other cards have no preset: clocks stay as they are, only the
undervolt is tuned. Your own `--lock-cclock`, `--lock-mclock`, `--moffset`, `--pl`, `--uv-offset` win over the preset.

`--auto-uv` alone tunes the core offset at the clocks you set. How it works: the core offset is raised in steps; each
step runs consensus canaries (known inferences checked byte for byte) every 5 s while mining continues. The first failed
canary or a hang is the edge; the miner keeps a margin below it, confirms for 150 s, then tunes memory the same way (in
the modes). The result is saved per GPU and per clock setting (`uv.json`); next starts take about 30 s to re-check it.
While mining, a canary runs every 120 s; a failure lowers the offset by 30 MHz. A GPU that hangs for 40 s is caught: the
miner lowers what it tried, restores your settings and exits with code 3 so that HiveOS / `start.bat` restart it.
`--uv-reset` forgets the profile of the current clocks, `--uv-reset-all` forgets all.

## Other options

```
--devices 0,1          GPUs to use (nvidia-smi / PCI order)        --batch N, --lanes N   (0 = auto)
--lock-cclock MHz      --lock-mclock MHz   --moffset MHz   --pl W   (one value or a list per GPU, '-' = leave)
--uv-offset MHz        fixed core offset (checked the same way)    --uv-min / --uv-max MHz
--selftest             engine check: test vector + 56 canaries     --bench 400   offline speed test
--api-port PORT        JSON stats on 127.0.0.1 (--api-bind ADDR)  --no-color   --version   --help
```

## API

`--api-port 4078` → `http://127.0.0.1:4078/` returns JSON:
`version`, `engine`, `uptime`, `mode`, `pool`, `difficulty`, `total_inf_s`, `accepted`, `rejected`, `stale`, and `gpus[]` with
`gpu`, `bus`, `name`, `inf_s`, `attempts`, `found`, `accepted`, `rejected`, `integrity_errors`, `canary_errors`, `alive`, `error`,
`power_w`, `temp_c`, `core_mhz`, `mem_mhz`, `core_offset`, `mem_offset`, `uv` (auto-undervolt state).
HiveOS units: 1 "hash" = 1 inference.

## Dev fee

1% of mining time: one 60 s slot every 100 minutes, mined to `vela1q8n67wrnsz0f5g4f6qwvmz6radx9jy6uujd64eh`.
During the slot the miner works for the fee login on the same pool (solo: blocks found in the slot pay to that address)
and then returns to your login. The log shows each slot.

## What is in the package

`ffgv` / `ffgv.exe` (host program), `libvelagpu.so` / `velagpu.dll` (GPU engine, binary only), start scripts
(HiveOS `h-*.sh` or Windows `start.bat` / `start.ps1`), README, MANUAL, CHANGELOG, LICENSE, NOTICE. The model is not in the
package. Licence: free to use and redistribute unmodified; the 1% dev fee must stay intact (see LICENSE); third-party components: NOTICE.
