# FreeForGemVela (ffgv) 0.4.1 — user manual

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

- NVIDIA RTX 30 (sm_86), RTX 40 (sm_89) or RTX 50 (sm_120), 6 GB VRAM or more (8 GB recommended).
- NVIDIA driver R525 or newer (RTX 50: R570 or newer). The memory offset needs R555 or newer.
  Tested on 580.178 (Linux) and 576.57 (Windows).
- Windows 10/11 x64, HiveOS, or a 64-bit Linux with glibc.
- Clock control and undervolt need administrator rights (Windows) or root (Linux; HiveOS already runs miners as root).
- About 1.2 GB of disk for the model `sd-turbo-int.poisd`. The start scripts download it once from
  https://huggingface.co/valereseach/vela-sd-turbo-int-v2 (mirror: https://dl.ariabrain.com/vela-dl/sd-turbo-int.poisd)
  and check sha256 `ba38ab96b3398e22ea631d8a457350f91833e57463199d063663308513651f36`.

## 4. Speed and power

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

## 5. Windows

1. Download `ffgv-0.4.0-windows-x64.zip` and check its SHA256 against the release page
   (PowerShell: `Get-FileHash .\ffgv-0.4.0-windows-x64.zip`).
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

The window is the log. **Ctrl+C** stops the miner and puts your clocks back. If the miner exits (an error, a hang), the
script restarts it after 15 s. All fields are explained in `README-WINDOWS.txt` and in `start.bat` itself.

## 6. HiveOS

A ready flight sheet to paste with *Import from Clipboard* is in [HIVEOS.md](HIVEOS.md). Step by step by hand:

1. **Wallets** → Add wallet: coin `VELA` (type it if it is not in the list), your `vela1...` address.
2. **Flight Sheets** → new flight sheet:
   - Coin: `VELA`; Wallet: the one you added; Pool: **Configure in miner**; Miner: **Custom**.
   - Click **Setup Miner Config** and fill in:

| field | value |
|---|---|
| Miner name | `ffgv-hive` (filled in automatically after the URL) |
| Installation URL | `https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.1/ffgv-hive-0.4.1.tar.gz` |
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

## 7. Linux without HiveOS

```
tar xzf ffgv-0.4.1-linux-x86_64.tar.gz
cd ffgv-0.4.1
wget https://huggingface.co/valereseach/vela-sd-turbo-int-v2/resolve/main/sd-turbo-int.poisd
sha256sum sd-turbo-int.poisd     # must be ba38ab96...1f36
./ffgv --selftest                # engine check: test vector + 56 consensus canaries
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
| AriaPool `http://159.69.194.46:3349` | HTTP JSON-RPC | vardiff on the pool side (new worker starts at 8000) | yes, 0 rejected |
| suprnova `stratum+tcp://vela.suprnova.cc:7601` | stratum | vardiff, starts at 2048 (aims at ~30 s per share) | yes, 0 rejected |
| suprnova `stratum+tcp://vela.suprnova.cc:7602` | stratum | fixed 2048 | yes, 0 rejected |
| suprnova `stratum+tcp://vela.suprnova.cc:7603` | stratum | fixed 16384 (for big rigs) | yes, 0 rejected |
| suprnova `stratum+ssl://vela.suprnova.cc:7604` | stratum over TLS | vardiff, as 7601 | yes (Linux and Windows), 0 rejected |
| solo, your node `http://USER:PASS@127.0.0.1:19732` | node RPC (getblocktemplate) | network difficulty | template and block assembly checked |

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

HiveOS Pool URL for each: `http://159.69.194.46:3349`, `stratum+tcp://vela.suprnova.cc:7601`,
`stratum+ssl://vela.suprnova.cc:7604`, `http://miner:PASSWORD@NODE_IP:19732` (with the node's `rpcbind`/`rpcallowip`
opened to the rig's network).

## 9. Failover, start difficulty, API

**Failover.** Give several pools: `--pool A --pool B` (or `--pool A,B`; in HiveOS separate them with spaces, in
`start.bat` with commas). When a pool is unreachable or drops the connection, the miner moves to the next pool within
about 15–20 s; after 10 minutes on a backup it tries the primary again. Pools of different kinds can be mixed.

**`--suggest-diff D`** (stratum pools): asks the pool to start your share difficulty at `D` after login. Useful for a
slow GPU (fewer, rarer shares otherwise) or a big rig. suprnova accepts it, but it sets only the start: the pool's vardiff
adjusts it within a few minutes. For a really fixed difficulty use ports 7602 / 7603. AriaPool has its own vardiff.

**API.** `--api-port 4078` serves JSON on `http://127.0.0.1:4078/` (`--api-bind 0.0.0.0` to open it to the network):

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

Every mode turns the auto-undervolt on. RTX 50 and other cards have no preset yet: their clocks stay as they are and only
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
1. 30 s warm-up, then a baseline offset (RTX 30 +120, RTX 40 +150, RTX 50 +240 MHz).
2. +30 MHz steps of 40 s each, canaries every 5 s, until the first failed canary or a hang; then the 15 MHz point inside
   that last 30 MHz interval (same 15 MHz precision, about half the steps; `--uv-coarse 15` = the old 15 MHz climb). If
   the power stops dropping (two steps in a row save < 0.5 W per 15 MHz), the search stops there. A new clock lock starts
   30 MHz below the profile of a higher lock of the same GPU (when there is one) instead of the baseline offset.
3. Result = the last good step minus a margin, confirmed for 150 s.
4. In `speed` / `balance` on RTX 30: the memory offset is tuned the same way (+250 MHz steps); it is kept only if it adds
   at least 1% speed.
5. The profile is saved per GPU and per clock setting (`uv.json`). Later starts only re-check it (about 30 s).

Safety nets: a GPU that stops answering for 40 s (a hang, typically memory pushed too far) is reported as `HUNG`; the
miner lowers what it was trying, puts your clocks back and exits with code 3 so that HiveOS / systemd / `start.bat` start
it again. After a driver error (Xid) the miner restarts itself and lowers the offset (by 30 MHz, or below the step it was trying). Clocks, offsets and the
power limit you had before are always put back on exit.

`--uv-reset` forgets the profile of the current clocks (once), `--uv-reset-all` forgets all profiles.

## 11. Dev fee

1% of mining time: one 60 s slot every 100 minutes at a random moment, mined to
`vela1q8n67wrnsz0f5g4f6qwvmz6radx9jy6uujd64eh`. During the slot the miner works under the fee login on the same pool
(solo: a block found in the slot pays to that address), then returns to your login. Each slot is shown in the log.

## 12. Troubleshooting

| symptom | what to do |
|---|---|
| `no model` / download fails / sha256 differs | Download `sd-turbo-int.poisd` by hand from the Hugging Face link (or the mirror) and put it next to `ffgv` (Windows) or into `/hive/miners/custom/vela-model` (HiveOS). Size must be 1 187 585 285 bytes. |
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

Questions and reports: https://github.com/pepsykolya/FreeForGemVela/issues.
