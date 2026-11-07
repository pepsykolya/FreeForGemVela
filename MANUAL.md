# FreeForGemVela (ffgv) 0.4.5 — user manual

A step-by-step guide for people who have never mined VELA before. Русская версия — [MANUAL.ru.md](MANUAL.ru.md).

Contents: 1. The coin · 2. A wallet · 3. What you need · 4. Speed and power · 5. Windows · 6. HiveOS · 7. Linux without HiveOS ·
8. Pools · 9. Failover, start difficulty, API · 10. Modes and auto-undervolt · 11. Dev fee · 12. Troubleshooting

---

## 1. The coin

**VELA** is a Proof-of-Inference blockchain built on Bitcoin Core. Every mining attempt runs a deterministic text-to-image
model (stabilityai/sd-turbo turned into a bit-exact integer program); the block header commits to the model output, and
every node re-runs the model to check a block. One attempt = one *inference*, so speed is measured in inferences per
second (inf/s) and difficulty in inferences.

| | |
|---|---|
| block time | 5 minutes |
| block reward | rises linearly from 10 to 25 VELA over the first 25 920 blocks (90 days), then 25 VELA |
| halving | every 420 000 blocks, the first one at height 427 776 |
| total supply | 20 999 982.45 VELA |
| developer fund | 10% of the block subsidy for the first 420 768 blocks (part of the supply, not extra) |
| premine | none (the genesis block pays 0) |
| addresses | `vela1...` |

Official sources: website and docs https://velaresearch.ai/ and https://velaresearch.ai/docs/ ·
whitepaper https://velaresearch.ai/whitepaper/vela-whitepaper.pdf · explorer https://explorer.velaresearch.ai/ ·
node source and releases https://git.velaresearch.ai/velaresearch/vela · Discord https://discord.gg/VcTU8h3pv7 ·
X https://x.com/velaresearch_ai · bitcointalk https://bitcointalk.org/index.php?topic=5595944

## 2. A wallet

You need a VELA address (`vela1...`) to mine to. Pick one of two ways.

### 2a. Web wallet (simplest)

https://wallet.velaresearch.ai/ — the official browser wallet.

1. Open it, choose **Create wallet**, then **Generate recovery phrase**.
2. **Write the recovery phrase down on paper**, in order. Confirm it when asked.
3. Set a password. It unlocks the wallet in *this* browser only; the keys are encrypted and stay in the browser
   ("your keys never leave it").
4. Copy your receiving address (`vela1...`) — this is what you put into the miner.

If the browser data is cleared or you change computers, use **Restore with recovery phrase**. Without the phrase the
coins are lost — the password alone cannot restore anything.

### 2b. Your own node (velad / vela-cli)

Download a `-mainnet-` release from https://git.velaresearch.ai/velaresearch/vela/releases and start the node
(`velad -daemon`, or the Qt wallet `vela-qt`). Data directory: `~/.vela` on Linux, `%LOCALAPPDATA%\Vela` on Windows. Then:

```
vela-cli createwallet "main"                       # creates and loads a wallet
vela-cli -rpcwallet=main getnewaddress             # -> vela1...  (put this into the miner)
vela-cli -rpcwallet=main encryptwallet "a long passphrase"   # optional, recommended
vela-cli -rpcwallet=main backupwallet /path/to/backup/vela-main-2026-10-31.dat
vela-cli -rpcwallet=main getbalance
```

The wallet file is `wallets/main/wallet.dat` inside the data directory. Back it up with `backupwallet` after creating it
(and again after you encrypt it), and keep copies **off the computer**: a USB stick in a drawer, a second disk, an
encrypted archive. Restore with `vela-cli restorewallet "main" /path/to/backup.dat`.

### Keep your keys to yourself

- Nobody — not a pool, not a "support" person in Discord, not the miner developer — ever needs your recovery phrase,
  `wallet.dat` or passphrase. Anyone who has them owns your coins.
- The miner only needs your **address**. An address is public; you can share it freely.
- Do not store the phrase in a screenshot, a chat or a cloud note.

## 3. What you need

- NVIDIA RTX 30 (sm_86), RTX 40 (sm_89) or RTX 50 (sm_120), 6 GB VRAM or more (8 GB recommended). **New in 0.4.3:** Turing
  (sm_75) — the mining card **CMP 50HX** (tested, with its own presets); RTX 20 cards load the same code but have no presets.
- NVIDIA driver R525 or newer (RTX 50: R570 or newer). The memory offset needs R555 or newer.
  Tested on 580.178 (Linux) and 576.57 (Windows).
- Windows 10/11 x64, HiveOS, or a 64-bit Linux with glibc.
- **AMD (new in 0.4.4, Windows first):** a Radeon RX 6800 / 6800 XT / 6900 XT / 6950 XT (Navi 21) with the Adrenalin driver instead of the NVIDIA driver - see section 4a.
- Clock control and undervolt need administrator rights (Windows) or root (Linux; HiveOS already runs miners as root).
- About 1.2 GB of disk for the model `sd-turbo-int.poisd`. If the file is not there at the start, `ffgv` itself downloads it from
  https://huggingface.co/valereseach/vela-sd-turbo-int-v2 (mirror: https://dl.ariabrain.com/vela-dl/sd-turbo-int.poisd),
  continues a broken download and checks sha256 `ba38ab96b3398e22ea631d8a457350f91833e57463199d063663308513651f36` before it uses the file (0.4.4; the start scripts and
  HiveOS did it before). `--no-model-download` turns it off.

## 4. Speed and power

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

**CMP 50HX** (Turing, the offset works through NVML, no edge found up to +420): unlocked it runs into its 225 W limit at 34.5 inf/s
(the clock settles near 1635 MHz); `balance` (lock 1500, +300) is −5% inf/s for −31% power, +37% inf/s per W; `eco` (lock 1350,
+300) +40% inf/s per W. The CMP rows are offline engine benchmark runs (batch 16, 04.11.2026) with a lock/offset controller on a
rig with the CMP unlock driver, not mining runs; the offsets are the points where the canaries pass (test vector byte for byte).
Without the unlock driver the same card makes about 11 times less (§6, CMP cards).

How it was measured: release 0.4.2, Linux, driver 580.178, mining on AriaPool; each value is the average of the miner's
API over 3 minutes after the auto-undervolt had settled (one run per point, 01.11.2026; the undervolt profiles tuned from
scratch). The prompt of the current block changes the speed by up to ±2–3%, so differences below that are noise. The
RTX 3070 rows without the undervolt and `speed` were not measured again for 0.4.2. RTX 4070 Laptop: one run of 0.4.0 at
stock clocks at its 88 °C thermal limit (28–31 inf/s). Your card, cooling and silicon will give somewhat different numbers.
RTX 3080 Ti: Windows 10, driver 591.59, the Windows package started with `start.bat` as administrator, mining on suprnova
7601 / 7604 and AriaPool; the same 3-minute API average (4–5 minutes for the points without auto-UV, 31.10.2026). The
memory search of `speed` / `balance` found no gain on its GDDR6X and kept +0.

### 4a. AMD Radeon (new in 0.4.4)

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

## 5. Windows

1. Download `ffgv-0.4.5-windows-x64.zip` and check its SHA256 against the release page
   (PowerShell: `Get-FileHash .\ffgv-0.4.5-windows-x64.zip`).
2. Unpack it to a folder **without spaces or non-English letters**, e.g. `C:\FreeForGemVela`.
3. Right-click `start.bat` → **Edit** and set:
   - `WALLET` — **your** address. The example address in the file is the developer's; the script warns you if you keep it.
   - `POOL` — one pool, or several separated by commas (the first is used, the others are backups), see section 8.
   - `WORKER` — a name for this computer (default: the computer name).
   - `MODE` — `balance` is a good start (`speed`, `eco`, or empty = your clocks as they are).
4. Save, then right-click `start.bat` → **Run as administrator** (needed for `MODE`, `AUTO_UV` and clock settings; without
   them a normal start is enough).
5. The first start downloads the model (1.19 GB) and checks it. Then you will see the stats line every 30 s:
   `[ 120s] GPU0 34.40 inf/s 121W +180 m+0 | total 34.40 inf/s, 121 W, 0.2846 inf/s/W | A 36 R 0`
   (`+180` = core offset, `m+0` = memory offset, A / R = accepted / rejected shares).

The window is the log. **Ctrl+C** (or closing the window) stops the miner and puts your clocks back. If the miner exits
(an error, a hang), the script restarts it after 15 s. All fields are explained in `README-WINDOWS.txt` and in `start.bat`
itself (`AUTO_LOCK=1`, `TEMP_LIMIT=80`, `API=4078` are there too).

**Start with Windows:** double-click `install-autostart.bat` once (Windows asks for Administrator). It creates a Task
Scheduler task that runs `start.bat` at your logon (30 s after it), in a visible window, with administrator rights (so
`MODE` / `AUTO_UV` work without a prompt), also on battery, without the 72 h limit. `remove-autostart.bat` removes it.
Do not also put `start.bat` into the Startup folder (two miners).

**New version notice:** about a minute after the start and then every ~12 hours the miner asks GitHub for the latest
release; if there is a newer one, the log says so (nothing is downloaded or installed). `--no-update-check` turns it off.

## 6. HiveOS

A ready flight sheet to paste with *Import from Clipboard* is in [HIVEOS.md](HIVEOS.md). Step by step by hand:

1. **Wallets** → Add wallet: coin `VELA` (type it if it is not in the list), your `vela1...` address.
2. **Flight Sheets** → new flight sheet:
   - Coin: `VELA`; Wallet: the one you added; Pool: **Configure in miner**; Miner: **Custom**.
   - Click **Setup Miner Config** and fill in:

| field | value |
|---|---|
| Miner name | `ffgv-hive` (filled in automatically after the URL) |
| Installation URL | `https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.5/ffgv-hive-0.4.5.tar.gz` |
| Hash algorithm | `vela` |
| Wallet and worker template | `%WAL%.%WORKER_NAME%` |
| Pool URL | e.g. `stratum+ssl://vela.suprnova.cc:7604` — several separated by spaces = backups |
| Pass | `x` |
| Extra config arguments | e.g. `--mode balance` |

3. **Apply Changes**, then apply the flight sheet to your rig.
4. On the first start the rig downloads the model into `/hive/miners/custom/vela-model` (once per rig, sha256 checked).
   If the rig has no internet access to Hugging Face, copy `sd-turbo-int.poisd` there by hand.
5. The dashboard shows speed per GPU (1 "hash" = 1 inference), temperatures, fans and accepted / rejected shares.
   Miner log: `miner log` in the HiveOS shell, or `/var/log/miner/ffgv-hive/ffgv-hive.log`.

Notes:
- Undervolt profiles and crash records live in `/hive-config/ffgv` and survive miner updates and reboots.
- With `--mode` or `--auto-uv` the miner sets the core offset itself and puts it back when it stops. You can keep a HiveOS
  OC profile for fans and power limit; **do not set a core clock offset there** at the same time (the miner would undo it
  while it runs anyway).
- `--mode speed` / `balance` lift a memory clock lock of the HiveOS OC profile while mining (SASEUL / Pearl profiles lock
  the memory to 810 MHz: an RTX 3070 then makes ~8 inf/s instead of ~35) and put it back on stop. `--lock-mclock MHz`
  sets your own lock instead; `--mode eco` locks the memory to 5001 MHz itself.
- If HiveOS applies its OC again while the miner runs (you change the OC in the web UI), the miner sets its own locks, the
  lifted memory lock and its power limit again within ~10 s. `miner stop` first lets the GPUs finish their batch, then puts
  the OC profile's values back.
- The dashboard's version column shows the rig's efficiency (`0.4.3 0.3012 inf/s/W`) and `need update!!` when a newer
  release is out (the miner checks GitHub every ~12 h; `--no-update-check` in Extra config turns it off).
- Lists in Extra config (per GPU) are written without spaces: `--lock-cclock 1500,1400`.

### CMP cards: the unlock driver (0.4.3)

NVIDIA CMP mining cards (CMP 50HX and the family) work at a small part of their speed under the stock NVIDIA driver: the same
engine, the same card, 1500 MHz, batch 16 made 2.4 inf/s with a stock driver and 27.4 inf/s with a driver that unlocks the card's
compute (the stock driver limits the arithmetic of the CMP chip; the engine does not change). The miner can install such a driver
on HiveOS, **only when you ask for it**:

- once, by hand: `sudo ./ffgv --cmp-driver` in the miner folder (`/hive/miners/custom/ffgv-hive`); or
- on every start, from the flight sheet: add `--cmp-unlock-driver` to Extra config arguments (the miner does not get it).
  A rig that already has the driver is left alone; a rig without a CMP card is left alone.

What it does: checks that this is HiveOS (`nvidia-driver-update`), that it runs as root and that a CMP card is on the PCI bus;
if the unlock driver (NVIDIA Open Kernel Module 610.43.03 with the CMP unlock) is not installed yet, it downloads that driver to
disk, checks its SHA-256 against the value fixed in the miner (another file is deleted, nothing is installed), installs it with
HiveOS's own `nvidia-driver-update --force` and **reboots the rig**; HiveOS starts the miner again after the boot. The log lines
begin with `--cmp-driver:`. `FFGV_CMP_DRIVER_NO_REBOOT=1` installs without the reboot, `FFGV_CMP_DRIVER_FORCE=1` installs again
even when the driver is in place.

Before you use it: it replaces the NVIDIA kernel driver of the whole rig (every GPU program uses it afterwards); Secure Boot
must be off; this is a third-party build of the driver, not NVIDIA's, you use it at your own risk; if the power fails during the
installation the rig can start without a working driver, so do it when you can reach the rig. To go back, install another
driver version with `nvidia-driver-update` and reboot. The speed table and the CMP presets of §4 / §10 are for the rig with this driver.

## 7. Linux without HiveOS

```
tar xzf ffgv-0.4.1-linux-x86_64.tar.gz
cd ffgv-0.4.1
./ffgv --selftest                # engine check: test vector + 56 consensus canaries; the first start downloads the model (1.19 GB,
                                 # sha256 checked) next to ffgv when it is not there (by hand: wget the Hugging Face link, sha256sum ba38ab96...1f36)
sudo CUDA_DEVICE_ORDER=PCI_BUS_ID ./ffgv --pool stratum+ssl://vela.suprnova.cc:7604 \
     --user vela1YOURADDRESS.rig1 --mode balance --api-port 4078
```

`libvelagpu.so` must stay next to `ffgv`. `sudo` is only needed for clocks and undervolt (`--mode`, `--auto-uv`,
`--lock-*`, `--pl`); without them run as a normal user. Profiles are kept in `uv.json` next to the binary
(or in `$FFGV_STATE_DIR`).

A systemd service (`/etc/systemd/system/ffgv.service`), restarted after an exit:

```
[Unit]
Description=FreeForGemVela
After=network-online.target

[Service]
WorkingDirectory=/opt/ffgv-0.4.1
Environment=CUDA_DEVICE_ORDER=PCI_BUS_ID
ExecStart=/opt/ffgv-0.4.1/ffgv --pool stratum+ssl://vela.suprnova.cc:7604 --pool http://159.69.194.46:3349 --user vela1YOURADDRESS.rig1 --model /opt/ffgv-0.4.1/sd-turbo-int.poisd --mode balance --api-port 4078 --no-color
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
```

`sudo systemctl enable --now ffgv`, log: `journalctl -u ffgv -f`.

## 8. Pools

Replace `vela1YOURADDRESS` with your address and `rig1` with a worker name.

Two pools are live on VELA mainnet (velaresearch.ai/docs): AriaPool and suprnova. Checked with ffgv on 2026-10-31:

| pool : port | protocol | share difficulty | checked |
|---|---|---|---|
| suprnova `stratum+tcp://vela.suprnova.cc:7601` | stratum | vardiff, starts at 2048 (aims at ~30 s per share) | yes, 0 rejected |
| suprnova `stratum+tcp://vela.suprnova.cc:7602` | stratum | fixed 2048 | yes, 0 rejected |
| suprnova `stratum+tcp://vela.suprnova.cc:7603` | stratum | fixed 16384 (for big rigs) | yes, 0 rejected |
| suprnova `stratum+ssl://vela.suprnova.cc:7604` | stratum over TLS | vardiff, as 7601 | yes (Linux and Windows), 0 rejected |
| solo, your node `http://USER:PASS@127.0.0.1:19732` | node RPC (getblocktemplate) | network difficulty | template and block assembly checked |
| AriaPool `http://159.69.194.46:3349` | HTTP JSON-RPC | vardiff on the pool side (new worker starts at 8000) | yes, 0 rejected |

**AriaPool** — https://pool.ariabrain.com/vela.html

```
ffgv --pool http://159.69.194.46:3349 --user vela1YOURADDRESS.rig1
```

**suprnova** — https://vela.suprnova.cc/ (PPLNS, fee 1%, payouts from 0.01 VELA)

```
ffgv --pool stratum+tcp://vela.suprnova.cc:7601 --user vela1YOURADDRESS.rig1      # vardiff
ffgv --pool stratum+ssl://vela.suprnova.cc:7604 --user vela1YOURADDRESS.rig1      # the same over TLS (encrypted)
```

Ports 7602 and 7603 are fixed difficulty 2048 and 16384 (`stratum+tcp://vela.suprnova.cc:7602`, `...:7603`). Other suprnova servers: `stratum-eu2.suprnova.cc`,
`stratum-ord.suprnova.cc`, `stratum-hkg.suprnova.cc` (same ports).

**Solo on your own node.** The node must be fully synced and accept RPC. In `vela.conf` (also in `solo/vela.conf.example`):

```
server=1
rpcuser=miner
rpcpassword=A_LONG_RANDOM_PASSWORD
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
```

```
ffgv --pool http://miner:A_LONG_RANDOM_PASSWORD@127.0.0.1:19732 --user vela1YOURADDRESS
```

19732 is the mainnet RPC port. The block reward goes to the address in `--user`. Solo pays only when *you* find a block.

HiveOS Pool URL for each: `stratum+ssl://vela.suprnova.cc:7604`, `stratum+tcp://vela.suprnova.cc:7601`,
`http://159.69.194.46:3349`, `http://miner:PASSWORD@NODE_IP:19732` (with the node's `rpcbind`/`rpcallowip`
opened to the rig's network).

## 9. Failover, start difficulty, API

**Failover.** Give several pools: `--pool A --pool B` (or `--pool A,B`; in HiveOS separate them with spaces, in
`start.bat` with commas). When a pool is unreachable or drops the connection, the miner moves to the next pool within
about 15–20 s. While it mines on a backup, the primary is checked every `--failback-minutes` (10) on a separate
connection (nothing is submitted there); after 2 good checks 60 s apart the miner goes back to it. Pools of different kinds
can be mixed.

**No accepted shares.** Connected and mining, but the pool accepts nothing: no accepted share for max(`--noshare-minutes`
(15), 10 × the expected share interval), only rejects for `--reject-minutes` (5), or no job for 5 minutes → the miner
reconnects; if it happens again on the new connection, it moves to the next pool. Not in solo, not in the dev fee minute,
and not when the GPUs found no share at all (that is a GPU problem: a warning only). `0` turns either check off.

**`--suggest-diff D`** (stratum pools): asks the pool to start your share difficulty at `D` after login. Useful for a
slow GPU (fewer, rarer shares otherwise) or a big rig. suprnova accepts it, but it sets only the start: the pool's vardiff
adjusts it within a few minutes. For a really fixed difficulty use ports 7602 / 7603. AriaPool has its own vardiff.

**API.** `--api 4078` (the same as `--api-port 4078`) serves a read-only API on `http://127.0.0.1:4078`; `--api 0.0.0.0:4078`
opens it to the network (then firewall it; host names other than IP addresses: `--api-hosts rig1`). No passwords are ever
in it, only GET / HEAD, no CORS:

- `/summary` — version, uptime, pool (url, index in the list, connected, height, share difficulty, failback state),
  wallet / worker, inf/s, W, inf/s per W, shares, dev fee;
- `/gpus` — per GPU: state (`mining`, `auto-uv`, `restarting`, `stopped`), inf/s, W, temperature, fan, clocks, offsets,
  `auto_uv`, `auto_lock`, `temp_limit`, `watchdog`, `throttle`, errors, shares;
- `/metrics` — Prometheus text (`ffgv_hashrate_infs`, `ffgv_gpu_hashrate_infs{gpu,bus,name}`, `ffgv_gpu_power_watts`, ...);
- `/` — the JSON that HiveOS h-stats reads (unchanged since 0.3):

```
{"version":"0.4.1","engine":"vg-...","uptime":1193,"mode":"balance","pool":"http://159.69.194.46:3349",
 "difficulty":4151.3,"total_inf_s":34.93,"accepted":2,"rejected":0,"stale":0,
 "gpus":[{"gpu":0,"bus":"0000:08:00.0","name":"NVIDIA GeForce RTX 3070","inf_s":34.93,"attempts":41208,"found":2,
          "accepted":2,"rejected":0,"integrity_errors":0,"canary_errors":0,"alive":true,"error":null,
          "power_w":122.6,"temp_c":55,"core_mhz":1500,"mem_mhz":6801,"core_offset":180,"mem_offset":0,
          "uv":"profile 1500/mauto1000"}]}
```

`uv` shows the auto-undervolt state: `tuning +165 (up to +300)`, `tuning memory ...`, `confirming +180`,
`checking +180` (quick check of a saved profile), `profile <key>`, `fixed`, `off`.

## 10. Modes and auto-undervolt

| mode | RTX 30 | RTX 40 | aim |
|---|---|---|---|
| `speed` | no core lock, memory up to +750 | no core lock | the most inf/s |
| `balance` | core lock 1500 MHz, memory up to +1000 | core lock 2250 MHz | nearly the speed for less power |
| `eco` | core lock 1400 MHz, memory locked at 5001 MHz | core lock 2100 MHz, memory locked at 5001 MHz | the least power |

**CMP 50HX (0.4.3):** `speed` no lock; `balance` lock 1500 MHz; `eco` lock 1350 MHz (memory as it is); the auto-undervolt starts
at +210 and searches up to +450. RTX 20 and other Turing cards have no preset.

Every mode turns the auto-undervolt on. RTX 50 and other cards (RTX 20) have no preset yet: their clocks stay as they are and only
the undervolt is tuned. Your own `--lock-cclock`, `--lock-mclock`, `--moffset`, `--pl` or `--uv-offset` win over the preset.
Without a mode, `--auto-uv` tunes the core offset at whatever clocks you set; `--uv-offset 150` sets a fixed offset (still
checked the same way).

**The "silent" edge of undervolting.** On most coins a GPU pushed too far crashes or the driver reports an error. On VELA it
usually does neither: the card keeps running and computes a *slightly wrong* model output (x0). The share is then
rejected by the pool, and you would never see why. ffgv therefore never trusts "no crash": every setting is tested with
consensus canaries — inferences whose correct output is known in advance from the node's own code — and compared byte
for byte. The first canary that does not match marks the edge; the miner steps back below it with a safety margin and
confirms the result for 150 s. While mining, a canary runs every 120 s, and every found share is recomputed before it is
sent; if a canary fails, the offset is lowered by 30 MHz and the profile is saved. A wrong result never reaches the pool.

How a tuning run goes (first start, about 7–10 minutes; mining continues the whole time):
1. 30 s warm-up, then a baseline offset (RTX 30 +120, RTX 40 +150, RTX 50 +240, CMP 50HX +210 MHz). If the start fails the
   canary it is checked once more before the miner goes down 30 MHz (0.4.3: a cold card or a one-off error is no edge).
2. +30 MHz steps of 40 s each, canaries every 5 s, until the first failed canary or a hang; then the 15 MHz point inside
   that last 30 MHz interval (same 15 MHz precision, about half the steps; `--uv-coarse 15` = the old 15 MHz climb). If
   the power stops dropping (two steps in a row save < 0.5 W per 15 MHz), the search stops there. A new clock lock starts
   30 MHz below the profile of the nearest higher lock of the same GPU (when there is one, and it did not end on the voltage
   floor) instead of the baseline offset; this holds for `--auto-lock` sweeps too (the log says which profile it came from).
3. Result = the last good step minus a margin, confirmed for 150 s.
4. In `speed` / `balance` on RTX 30: the memory offset is tuned the same way (+250 MHz steps); it is kept only if it adds
   at least 1% speed.
5. The profile is saved per GPU and per clock setting (`uv.json`). Later starts only re-check it (about 30 s).
6. **The steps that passed are kept (0.4.3).** If the tuning is cut short — a stop (Ctrl+C, `miner stop`, a config change), or a
   fault of *another* GPU that ends the process — the next start goes on from the last good step (two steps below it) with the
   edge it had already found, instead of starting over from the baseline. The step that was in progress is **not** counted as
   that GPU's edge: only the GPU with the Xid / hang gets its step written as failed.

Safety nets: a GPU that stops answering for 40 s (a hang, typically memory pushed too far) is reported as `HUNG`; the
miner lowers what it was trying, puts your clocks back and exits with code 3 so that HiveOS / systemd / `start.bat` start
it again. After a driver error (Xid) the miner restarts itself and lowers the offset of the GPU that reported it (by 30 MHz, or below the step it was trying); the other GPUs of the process keep their tuning. Clocks, offsets and the
power limit you had before are always put back on exit.

`--uv-reset` forgets the profile of the current clocks (once), `--uv-reset-all` forgets all profiles.

### 10a. Automatic core clock lock `--auto-lock` (new in 0.4.2)

ffgv picks the core clock lock of each GPU itself:

    sudo ./ffgv --pool ... --user vela1ADDRESS.rig1 --auto-lock

- It mines at several locks, highest first: by default 7 locks 100 MHz apart from 1800 MHz (RTX 30) or 2700 MHz
  (RTX 40 / 50), nothing above the card's maximum (CMP 50HX, 0.4.3: 1650, 1500, 1350 — the measured points); `--auto-lock-range 1300-1800:100` or `--auto-lock-range 1400,1500,1600`.
- At each lock the auto-undervolt first tunes (or quick-checks) its own profile — a new lock starts 30 MHz below the
  profile of the higher lock — then the GPU mines 45 s to settle and 120 s measured (inf/s from its own attempts, NVML watts,
  median clock). **The point counts only after a canary round after the measurement passed and none failed during it**
  (a failure there: the offset steps back as always and the lock is measured again, at most 3 times).
- Choice: the best inf/s per W among the locks within `--auto-lock-max-loss` % (10) of the fastest one;
  `--auto-lock-goal speed` = the fastest. Once a lock is below that cut, the lower ones are not measured.
- Not valid: the clock did not hold the lock (power / thermal limit), no steady mining. FAILED: the driver refuses the lock,
  no offset passes the canaries there. A lock is marked `crashed` (and never tried again) only when
  THIS GPU failed on it (its own Xid / hang) while mining with an already checked offset (settling, measuring, canary), or
  failed 3 times in a row while auto-uv tuned it, or the miner died 2 starts in a row at it for no known reason. The Xid of
  another GPU, a stop (SIGTERM, a new flight sheet) and an offset step above the edge during auto-uv's tuning (auto-uv records
  that edge and runs lower) do not mark it: the sweep goes on with the same lock.
- The other GPUs mine all the time; all GPUs sweep in parallel; the status line shows `[auto-lock 1700, 2/5: measuring]`.
  The first sweep costs about 10–15 minutes per lock; at the end the log shows a table and the chosen lock (`* chosen`).
- Saved per GPU, driver and memory setting in `autolock.json` (HiveOS: `/hive-config/ffgv`): the next start applies it at
  once. A changed goal / max loss is re-chosen from the saved points; `--auto-lock-reset` sweeps again (the undervolt
  profiles stay). A GPU with its own `--lock-cclock` value is not swept; a `--mode` preset lock is replaced by the sweep.
- Windows: `set AUTO_LOCK=1` in `start.bat` (run as administrator).

### 10b. Watchdogs

- **Hang:** no batch finished for `--watchdog-hang` seconds (40; 180 while a GPU opens): the miner remembers what to lower
  (a tuning step = the edge; a profile 30 MHz lower), puts your settings back and exits with code 3.
- **Slowdown:** a GPU below `--watchdog-drop` % (30) of its own speed (median of its last 10 minutes) for
  `--watchdog-minutes` (3) gets a fresh worker; a tuned offset first goes 30 MHz down (re-checked by the canary). The third
  slowdown within an hour is handled as a hang. Not judged while it tunes, without a job, while `--temp-limit` holds it or
  `--auto-lock` sweeps it; under hardware throttling (thermal, power brake) or when most GPUs slow down at once (the rig)
  it is only logged. `--no-watchdog` turns the slowdown check off. The status line shows `[wd 1s]` after an action.
- **Xid / GPU fault:** the driver's Xid tells which GPU failed; only its offset is lowered at the next start (the miner restarts
  itself on Linux, `start.bat` restarts it on Windows). A CUDA fault stops every GPU of the process, but the others are not at
  fault: their tuning steps are saved as interrupted (0.4.3), not as failed.
- **GPU cannot be opened** ("busy or unavailable", "GPU is lost" at the start, e.g. after the previous miner's fault): not an
  undervolt failure, nothing is lowered. The miner waits 1, then 5, then 15 minutes (every 15 min after) before it exits for
  HiveOS / `start.bat` to start it again, instead of hundreds of restarts a minute. Such a card usually needs a reset or a reboot. A crash within 30 s of HiveOS / another tool changing the clocks is
  not counted against the undervolt.

### 10c. Temperature limit `--temp-limit` (laptops)

`--temp-limit 80` keeps the GPU at or below 80 °C by giving it less work (idle gaps after each batch; no administrator
needed): a controller keeps it in 78–79 °C, starts at 30% and ramps up, full speed again when it is cool. `--temp-stop C2`
(default min(C+10, 90)) stops the GPU until it cools to C−6. The status line shows `[temp-limit 72%]` / `[temp-stop 91 C]`.
The clock lock of an undervolt profile is never lowered (the offset was checked at that lock). Windows: `TEMP_LIMIT=80`.

### 10d. Per-GPU values, `--dry-run`

`--lock-cclock`, `--lock-mclock`, `--moffset`, `--pl`, `--uv-offset`, `--uv-min`, `--uv-max`, `--uv-step`, `--mem-max`,
`--temp-limit` take one value for all GPUs or a list in `--devices` order: `--lock-cclock 1500,1400,x`. `x`, `-` or empty =
leave that GPU alone (clock locks and `--pl` also `0`); a shorter list repeats its last value (the HiveOS rule, logged);
`x` in a `--uv-min` / `--uv-max` / `--uv-step` list = no auto-undervolt on that GPU. At the start one line per GPU says what
the miner sets on it; `--dry-run` prints those lines and exits without changing anything. Lists have no spaces.

### 10e. Stopping

Ctrl+C, closing the window (Windows), SIGTERM, HiveOS `miner stop`, `--minutes M`, a hang or a GPU fault (a tuning in progress is saved, see 10): the miner first
lets every GPU finish its batch, then puts back the core and memory offsets, the clock locks (the HiveOS OC profile's, if
there is one) and the power limit, in that order. If the process is killed hard or the power fails, the next start does it
before anything else. While it runs, the miner's settings win: if HiveOS or another tool changes a lock, the lifted memory
lock or the power limit, the miner sets its own again within ~10 s (at most 4 times an hour per GPU).

## 11. Dev fee

1% of mining time: one 60 s slot every 100 minutes at a random moment, mined to
`vela1q8n67wrnsz0f5g4f6qwvmz6radx9jy6uujd64eh`. During the slot the miner works under the fee login on the same pool
(solo: a block found in the slot pays to that address), then returns to your login. Each slot is shown in the log.

## 12. Troubleshooting

| symptom | what to do |
|---|---|
| `no model` / download fails / sha256 differs | From 0.4.4 `ffgv` downloads a missing model itself (a break is continued at the next start, a wrong file is refused). If the machine cannot reach Hugging Face or the mirror: download `sd-turbo-int.poisd` by hand from the Hugging Face link (or the mirror) and put it next to `ffgv` (Windows) or into `/hive/miners/custom/vela-model` (HiveOS). Size must be 1 187 585 285 bytes. |
| `WALLET is still the developer address` | Put your own `vela1...` address into `start.bat`. |
| `WALLET does not look like a VELA address` | Use the full lower-case `vela1...` address, no spaces. |
| CUDA error at start, `driver version is insufficient` | Update the NVIDIA driver (R525+, RTX 50: R570+). |
| out of memory | 6 GB VRAM is the minimum; close other GPU programs or try `--batch 4`. |
| `--mode` / undervolt does nothing, "permission" messages | Run as administrator (Windows) or with `sudo` (Linux). |
| canary `BAD` keeps repeating, GPU stopped | A manual overclock or HiveOS core offset is too high. Remove it, or let `--mode` / `--auto-uv` manage the core; `--uv-reset` to re-tune. |
| `HUNG` and a restart | Memory or core pushed too far; the miner already lowered it. If it repeats, use `eco` or `--uv-reset`. |
| rejected shares (R) | Usually a manual overclock (see canary above) or a wrong pool login. Stale shares (S) after a new block are normal. |
| 0 shares for a long time | Normal on a slow GPU with a high pool difficulty: one share per `difficulty / inf/s` seconds on average. Try `--suggest-diff` on suprnova. |
| HiveOS dashboard shows 0 | Check `miner log`; the stats come from the miner API on port 4078 — do not override `--api-port` in Extra config. |
| TLS pool does not connect | Port 7604 may be blocked by the network; use 7601. |
| laptop speed drops after a minute | Thermal or power limit of the laptop; `eco` mode helps keep it steady. |
| folder path warning on Windows | Move the folder to e.g. `C:\FreeForGemVela`. |
| want to start over | `--uv-reset-all` once; profiles: `uv.json` (Windows/Linux) or `/hive-config/ffgv` (HiveOS). |
| `watchdog: GPUn SLOW` | The GPU ran far below its own speed; the miner restarted its worker. If it repeats: riser, power, cooling. |
| `auto-lock ... FAILED` | That lock is not usable on this card (refused, or no offset passes); the sweep goes on with the next lock. |
| what did the miner set on each GPU? | `--dry-run` with the same options prints one line per GPU and changes nothing. |

Questions and reports: https://github.com/pepsykolya/FreeForGemVela/issues.
