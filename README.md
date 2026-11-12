# FreeForGemVela (ffgv) 0.4.6

Native GPU miner for **VELA** (Proof-of-Inference, integer sd-turbo) on NVIDIA RTX 30 / 40 / 50 and, new in 0.4.4 (Windows first),
AMD Radeon RX 6800 / 6800 XT / 6900 XT / 6950 XT (Navi 21, Windows). HiveOS and Windows packages. Dev fee **1%**. Русская версия — [README.ru.md](README.ru.md).

- Every share is computed bit-exact to the VELA node's consensus code and re-checked before it is sent.
- Built-in auto-undervolt checked by consensus canaries (an undervolted GPU on VELA first computes a *wrong* result
  without crashing, so the miner tests every setting byte for byte against known results).
- Ready modes `speed`, `balance`, `eco`; `--auto-lock` picks the core clock lock per GPU itself; hang and slowdown
  watchdogs; pool failover with the return to the primary pool; stratum over TLS; API with Prometheus metrics; your GPU
  settings put back after every kind of stop; Windows autostart; a notice when a new version is out.

## Download

Release page: https://github.com/pepsykolya/FreeForGemVela/releases/tag/v0.4.6

| package | file |
|---|---|
| HiveOS (custom miner) | https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.6/ffgv-hive-0.4.6.tar.gz |
| Linux x86_64 | https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.6/ffgv-0.4.6-linux-x86_64.tar.gz |
| Windows x64 | https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.6/ffgv-0.4.6-windows-x64.zip |
| checksums | https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.6/SHA256SUMS |

The miner binary is `ffgv` (`ffgv.exe` on Windows).

## Speed and power

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
| CMP 50HX (225 W), 0.4.3 engine, bench | speed (= stock) | no | — | 34.5 | 219 | 0.157 |
| CMP 50HX (225 W), 0.4.3 engine, bench | 1650 MHz | yes | lock 1650, core +240 | 35.1 | 183 | 0.192 |
| CMP 50HX (225 W), 0.4.3 engine, bench | balance | yes | lock 1500, core +300 | 32.6 | 151 | 0.216 |
| CMP 50HX (225 W), 0.4.3 engine, bench | eco | yes | lock 1350, core +300 | 29.6 | 134 | 0.220 |

The power limit is only a ceiling here (RTX 3070 200 W, RTX 4070 Ti 235 W): the mode sets the clocks, the undervolt the
voltage. **RTX 3070:** `balance` with the undervolt mines at 122 W, `eco` at 100 W (+11% inf/s/W for −9% inf/s against
`balance`); a HiveOS rig of four RTX 3070 in `balance` made 142.1 inf/s at 464 W. **RTX 4070 Ti** with the full 235 W:
`speed` +3.1% inf/s from the undervolt at the same power; the clock locks of `balance` / `eco` cut the power by 24% / 40%
for −9% / −26% inf/s (+19% / +23% inf/s/W), the undervolt on top of a lock changes little. **RTX 3080 Ti** (Windows, 0.4.0
engine — 0.4.2 is ~3–4% faster at the same clocks): the clock locks give `balance` −7.5% inf/s at −21% power and `eco` −20%
inf/s at −37% power; the undervolt on top adds +7% inf/s/W in `balance` and +2.5% in `eco`.

**CMP 50HX** (Turing; the offset works through NVML, no edge found up to +420): unlocked it hits its 225 W limit at 34.5 inf/s
(the clock settles near 1635 MHz); `balance` (lock 1500, +300) is −5% inf/s for −31% power (+37% inf/s per W), `eco` (lock 1350,
+300) +40% inf/s per W. The CMP rows are offline engine benchmark runs (batch 16, 04.11.2026) on a rig with the CMP unlock driver,
not mining; without that driver these cards run about 11 times slower (MANUAL §6, `--cmp-driver`).

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

## Requirements

- NVIDIA RTX 30 (sm_86), RTX 40 (sm_89) or RTX 50 (sm_120); 6 GB VRAM or more (8 GB recommended). New in 0.4.3: Turing
  (sm_75), the mining card CMP 50HX (tested, own presets); RTX 20 loads the same code, no presets.
- NVIDIA driver with CUDA 12 support (R525 or newer; RTX 50 needs R570 or newer). Tested on 580.178 (Linux) and 576.57 (Windows).
  Memory offset (`--moffset`, auto-undervolt of memory) needs R555 or newer.
- Linux x86_64 (HiveOS or any glibc distribution) or Windows 10/11 x64.
- Clock control and undervolt need root (HiveOS runs miners as root) or "Run as administrator" on Windows.
- The model `sd-turbo-int.poisd` (1.19 GB, 1 187 585 285 bytes). The start scripts download it once and check it:
  - https://huggingface.co/valereseach/vela-sd-turbo-int-v2/resolve/main/sd-turbo-int.poisd (official)
  - https://dl.ariabrain.com/vela-dl/sd-turbo-int.poisd (mirror)
  - sha256 `ba38ab96b3398e22ea631d8a457350f91833e57463199d063663308513651f36`

## AMD Radeon (new in 0.4.4)

The same miner, the same pools and the same consensus check run on AMD Radeon cards through a second GPU engine, `velagpu_amd.dll`
(OpenCL). It is bit-exact with the node like the CUDA engine: the test vector and all 56 consensus canaries are byte for byte the node's
results on the RX 6800 XT (the miner checks them at every start), and every share is recomputed before it is sent.

- **Needs:** a Radeon of the Navi 21 family (gfx1030: RX 6800, 6800 XT, 6900 XT, 6950 XT; no other Radeon is supported in 0.4.4; measured on one card: RX 6800 XT 16 GB, gfx1030, Adrenalin 25.5.1), Windows 10/11 x64,
  the Adrenalin driver (its OpenCL is all the engine uses: no HIP / ROCm SDK, no CUDA, nothing else to install). 8 GB of VRAM or
  more is recommended: the model takes 1.25 GB and each attempt of the batch about 0.26 GB (batch 16 needs ~5.8 GB, batch 8 ~3.7 GB);
  with `--batch 0` (default) the miner takes the largest of 16 / 8 / 4 / 2 / 1 that fits the free VRAM and warns when a given batch does not.
  Clock and voltage settings may need "Run as administrator" (the tests ran from an administrator session).
- **Files next to `ffgv.exe`:** `velagpu_amd.dll` (the engine), `amduv.exe` (sets and restores the clock cap, the core voltage and the power
  limit of the card through the driver's ADLX; our program), `adlx_mon.exe` (reads power, clock and temperature; our program).
  Without `amduv.exe` the card is mined as it is (no settings); without `adlx_mon.exe` there is no power reading, so eco / balance searches
  are off (a preset and fixed values still work).
- **Cards are found by name and architecture, not by index.** An integrated Radeon of a Ryzen is not used (`--amd-igpu` lists it, too slow
  to be worth it). `--devices` numbers the NVIDIA cards first and then the AMD cards (PCI bus order inside each vendor), so an NVIDIA-only
  rig is numbered exactly as before; `--devices amd0,nv1` counts inside one vendor. `--no-amd` / `--no-nvidia` leave a vendor out.
  A package without `velagpu_amd.dll` is the NVIDIA package of 0.4.3 (its CUDA engine is not touched).
- **Measured, RX 6800 XT (batch 16, Windows; whole engine, 4000 inferences per point, every x0 compared with the CPU hash; W = ASIC (chip)
  power from the driver, not the whole card or the wall):**

  | clock cap / voltage | inf/s | W | inf/s/W | wrong x0 of 4000 |
  |---|---|---|---|---|
  | 2324 MHz / 1150 mV (stock) | 23.22 | 271.8 | 0.085 | 0 |
  | 2324 MHz / 1050 mV (931 mV really) | 23.38 | 230.2 | 0.102 | 0 |
  | 2250 MHz / 881 mV | 22.77 | 202.8 | 0.112 | **35** (the first at the 138th) |
  | 2200 MHz / 881 mV | 22.39 | 200.0 | 0.112 | 0 |
  | 2150 MHz / 881 mV | 21.98 | 198.1 | 0.111 | 0 |

  881 mV is the lowest voltage the driver accepts. Note the 2250 MHz row: its canary rounds before and after the run passed 56/56.
- **Undervolting a Radeon is a risk, and the miner treats it as one.** Past its edge a card does not stop: it computes WRONG results without
  any sign (the pool then rejects the shares), and further past it the video driver HANGS - on the test card 2324 MHz at a voltage slider of
  1000 mV (881-887 mV really) broke every result and killed the OpenCL queue; only a restart of the video driver (Win+Ctrl+Shift+B) or of the
  PC brings such a card back. The step between the clean 1050 mV and the hanging 1000 mV was one step. Hence: every approach to an edge starts on the
  safe side in small steps; every step is checked first by consensus canaries back to back, then the point you end on is confirmed for at least **150 s
  and 4000 verified inferences** (about 4-5 minutes on a 6800 XT: the canary runs at ~16 verified inferences per second); the miner NEVER goes on to
  the next step after an error; the card's values are written only after yours are saved, and on every exit they are put back. If the video driver
  hangs, the miner puts your settings back, says so ("the video driver hung ... Win+Ctrl+Shift+B"), remembers the value as a failure in `amd-uv.json`
  and never tries it (or anything more aggressive) again; `--uv-reset-all` forgets that. A short canary is not enough to call a setting safe, and a
  setting that was clean on one card may be wrong on another: use the ready modes only on the card they were measured on.
- **Modes (`--mode`):**

  | mode | RX 6800 XT | what the miner does |
  |---|---|---|
  | `eco` | 2150 MHz / 881 mV | 100 MHz below the first failure (2250); the long check, then mining: 21.98 inf/s at 198 W |
  | `balance` | from 2324 MHz / 1100 mV, down in 25 mV steps, floor 1050 mV | each step checked, the first error stops the descent (back to the last good step), the long check on the last good one; the clean end of the descent (2324 / 1050) gave 23.38 inf/s at 230 W |
  | `speed` | 2324 MHz / 1150 mV (stock) | the card is power-limited at ~270 W there: no faster point exists |

  No preset exists for other cards: `--mode` and `--auto-uv` search them. A failed check of a preset steps the clock back (50 MHz; at last a
  search). Results are saved per card (`amd-uv.json` next to `uv.json`); later starts do a 20 s quick check of a confirmed result. While
  mining a canary runs every 120 s: a failure steps the clock back 25 MHz and checks again; two in a row give your settings back.
  `--auto-uv` (and `--auto-lock`) search: the clock cap is raised from 1900 MHz in 50 MHz steps (25 MHz inside a failing interval) at the lowest
  voltage until the canary fails; the result stays one margin step below the edge and goes through the long check. The voltage is never lowered by
  the search and never raised past the edge. `--auto-lock` takes the best inf/s per W within `--auto-lock-max-loss` % of the fastest
  (`--auto-lock-goal speed`: the fastest).
- **Own values:** `--lock-cclock MHz` is the clock cap of a Radeon, `--amd-volt mV`, `--amd-pl PERCENT` (lists per GPU like the other
  options; on a rig with NVIDIA and AMD cards a single `--lock-cclock` value is for the NVIDIA cards only). `--lock-mclock`, `--moffset`, `--pl`
  (watts) and `--uv-offset` are NVIDIA options and are ignored on a Radeon (logged). Your own voltage is yours to judge: the miner checks it
  but cannot make an unsafe value safe.
- **Your settings are always put back:** `amduv.exe` writes the card's values only after it saved yours to a file; on every exit
  (Ctrl+C, a stop, an error, a hang) they are restored; a small guard process restores them if the miner process dies or is killed;
  if the whole process tree is killed (`taskkill /T`, Task Scheduler's Stop) the next start of `ffgv` (or of `amduv.exe`) puts them back.
- **Limits of this release:** Windows first. The Linux / HiveOS AMD code (the same engine, settings through amdgpu `sysfs`) is written
  but was never run on a Linux Radeon: do not rely on it. One setting session at a time (the driver's ADLX): several identical Radeons
  cannot be told apart by it, so they are mined as they are (different models are tuned). The numbers above are one card
  (RX 6800 XT); the other Navi 21 cards (RX 6800, 6900 XT, 6950 XT) run the same kernels with no preset (not measured); other Radeon generations (RX 6700 and below, RDNA3, RDNA4) are not supported in 0.4.4: the engine carries precompiled kernels for gfx1030 only, and the miner says so.

## HiveOS

Flight sheet: Coin **VELA** (add a custom coin if it is not in the list), your wallet, Pool **Configure in miner**,
Miner **Custom** → Setup Miner Config:

| field | value |
|---|---|
| Miner name | `ffgv-hive` (filled in from the URL) |
| Installation URL | `https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.6/ffgv-hive-0.4.6.tar.gz` |
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
If HiveOS applies its OC again while the miner runs (an OC change in the web UI), the miner sets its own locks, the lifted
memory lock and its power limit again within ~10 s. `miner stop` first lets the GPUs finish their batch, then puts the OC
profile's values back. The HiveOS dashboard reads speed, temperatures, fans, accepted/rejected shares from the miner's API
(`h-stats.sh`, port 4078); the version column shows the rig's inf/s/W and `need update!!` when a newer release is out.

## Windows

1. Unpack `ffgv-0.4.6-windows-x64.zip` to a folder without spaces, e.g. `C:\FreeForGemVela`.
2. Right-click `start.bat` → Edit: set `WALLET` to **your** address (the example address is the developer's), `POOL`, `WORKER`,
   optionally `MODE=balance`.
3. Run `start.bat` (as administrator if you use `MODE`, `AUTO_UV` or clock settings). The first start downloads the model
   (1.19 GB, sha256 checked). The window is the log; Ctrl+C (or closing the window) stops the miner and puts your GPU
   settings back.
4. Optional: `install-autostart.bat` starts `start.bat` at every logon (asks for Administrator once; `remove-autostart.bat`
   undoes it). `AUTO_LOCK=1`, `TEMP_LIMIT=80` (laptops) and `API=4078` are set in `start.bat` too.

See `README-WINDOWS.txt` in the package for every field.

## Pools

```
# suprnova, stratum over TCP / over TLS (encrypted)
ffgv --pool stratum+tcp://vela.suprnova.cc:7601 --user vela1YOURADDRESS.rig1
ffgv --pool stratum+ssl://vela.suprnova.cc:7604 --user vela1YOURADDRESS.rig1
# solo through your own synced VELA node (RPC)
ffgv --pool http://RPCUSER:RPCPASS@127.0.0.1:19732 --user vela1YOURADDRESS
# AriaPool
ffgv --pool http://159.69.194.46:3349 --user vela1YOURADDRESS.rig1
# failover: the first pool is primary, the next ones are backups
ffgv --pool stratum+ssl://vela.suprnova.cc:7604 --pool http://159.69.194.46:3349 --user vela1YOURADDRESS.rig1 --mode balance
```

HiveOS Pool URL for the same: `stratum+ssl://vela.suprnova.cc:7604`, `stratum+tcp://vela.suprnova.cc:7601`, `http://159.69.194.46:3349`,
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

**New in 0.4.3:** the steps of an interrupted auto-undervolt are kept (a stop, or the fault of another GPU of the process, no
longer sends the tuning back to the start, and only the GPU with the Xid gets its step written as failed); a start offset that
fails is checked once more before the miner goes down; a GPU that cannot be opened is waited for (1, 5, 15 min) before the
miner exits; CMP 50HX presets (`--mode`, `--auto-uv` start +210, `--auto-lock` 1650/1500/1350); `--cmp-driver` (HiveOS, opt-in: installs the CMP unlock driver).

`--auto-lock` (new in 0.4.2) picks the core clock lock per GPU: it mines at several locks (by default 7 locks 100 MHz
apart, from 1800 on RTX 30 and 2700 on RTX 40 / 50, nothing above the card's maximum), each at its own auto-undervolt
profile, measures inf/s and watts for 2 minutes, and keeps the best inf/s per W within `--auto-lock-max-loss` % (10) of
the fastest lock (`--auto-lock-goal speed`: the fastest). Each lock counts only after a canary round after its
measurement passed. Lower locks are skipped once one falls below the cut. The first sweep takes about 10–15 minutes per
lock while the GPU keeps mining; the result is saved and applied at once on later starts (`--auto-lock-reset` sweeps again).
A GPU with its own `--lock-cclock` value is not swept.

Watchdogs: a GPU that finishes no batch for 40 s is hung (`--watchdog-hang`): the miner lowers what it tried, restores your
settings and exits with code 3 so that HiveOS / `start.bat` restart it. A GPU that runs below 30% of its own speed for
3 minutes (`--watchdog-drop`, `--watchdog-minutes`) gets a fresh worker (a tuned offset first goes 30 MHz down); hardware
throttling or a slowdown of most GPUs at once is only logged; `--no-watchdog` turns that off.

## Other options

```
--devices 0,1          GPUs to use (nvidia-smi / PCI order)        --batch N, --lanes N   (0 = auto; auto = 2 lanes on an RTX 3070, an RTX 4070 Ti and a CMP 50HX, else 1; --lanes 1 = off)
--lane-sync auto|on|off  2+ lanes of a card start every batch together (auto = on where it helps: RTX 3070, 3070 Laptop); MANUAL §4b
--lock-cclock MHz      --lock-mclock MHz   --moffset MHz   --pl W   (one value for all GPUs or a list per GPU)
--uv-offset MHz        fixed core offset (checked the same way)    --uv-min / --uv-max / --uv-step MHz (per GPU too)
--auto-lock            pick the core lock per GPU (see above)      --auto-lock-range 1300-1800[:100] | L,L,...
--temp-limit C         keep the GPU at or below C by idle gaps (laptops); --temp-stop C2 hard stop
--failback-minutes N   on a backup pool, check the primary every N min (10, 0 = off)
--noshare-minutes M    no accepted share for max(M, 10 share intervals): reconnect, then the next pool (15)
--minutes M            stop after M minutes (settings put back)    --dry-run   print what is set per GPU, change nothing
--selftest             engine check: test vector + 56 canaries     --bench 400   offline speed test
--api [HOST:]PORT      read-only API (see below)                   --no-update-check   --no-color   --version   --help
```

Lists: one value for all GPUs, or one per GPU in `--devices` order; `x`, `-` or empty = leave that GPU alone; a shorter
list repeats its last value (the HiveOS rule); `x` in a `--uv-min` / `--uv-max` / `--uv-step` list = no auto-undervolt on
that GPU. At the start one line per GPU says what the miner sets on it.

## API

`--api 4078` (or `--api-port 4078`; another address: `--api 0.0.0.0:4078`, then firewall it) — read-only, no passwords
in it: `/summary` (the rig), `/gpus` (per GPU: inf/s, W, temperature, fan, clocks, offsets, auto-undervolt, auto-lock,
temperature limit, watchdog), `/metrics` (Prometheus). `http://127.0.0.1:4078/` returns the JSON HiveOS reads:
`version`, `engine`, `uptime`, `mode`, `pool`, `difficulty`, `total_inf_s`, `accepted`, `rejected`, `stale`, and `gpus[]` with
`gpu`, `bus`, `name`, `inf_s`, `attempts`, `found`, `accepted`, `rejected`, `integrity_errors`, `canary_errors`, `alive`, `error`,
`power_w`, `temp_c`, `core_mhz`, `mem_mhz`, `core_offset`, `mem_offset`, `uv` (auto-undervolt state).
HiveOS units: 1 "hash" = 1 inference.

## Dev fee

1% of mining time: one 60 s slot every 100 minutes, mined to `vela1q8n67wrnsz0f5g4f6qwvmz6radx9jy6uujd64eh`.
During the slot the miner works for the fee login on the same pool (solo: blocks found in the slot pay to that address)
and then returns to your login. The log shows each slot.

## What is in the package

`ffgv` / `ffgv.exe` (host program), `libvelagpu.so` / `velagpu.dll` (GPU engine, binary only; the Windows AMD package adds `velagpu_amd.dll`,
`amduv.exe`, `adlx_mon.exe`), start scripts
(HiveOS `h-*.sh` or Windows `start.bat` / `start.ps1`), README, MANUAL, CHANGELOG, LICENSE, NOTICE. The model is not in the
package. Licence: free to use and redistribute unmodified; the 1% dev fee must stay intact (see LICENSE); third-party components: NOTICE.
