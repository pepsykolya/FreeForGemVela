# FreeForGemVela (ffgv) — changelog

Speeds are inferences per second (inf/s, 1 inference = 1 share attempt). Unless stated otherwise: RTX 3070 at power
limit 135 W, RTX 4070 Ti at 190 W, stock clocks, offline benchmark with the consensus check (test vector + canaries
byte for byte equal to the VELA node's own CPU code). Each engine round was measured as an A/B against the build
before it on the same cards, so the steps below are exact; the series of different rounds used slightly different
bench scripts (±1%).

## 0.4.6 — 2026-11-12

Two lanes where they pay off, a larger batch on the RTX 3080 Ti, a full fix of the second lane of the engine, and the guards around it. The math of the
kernels is that of 0.4.5 except conv_out (bit-exact: test vector, canary 56/56 on every lane, 40 seeds against the node's CPU code); the AMD engine is
byte for byte that of 0.4.4 / 0.4.5. What it gives, measured on the miner's own inf/s (API / log), not on pool hashrate:

| card | 0.4.5 default | 0.4.6 default | change |
|---|---|---|---|
| RTX 3070 (desktop) | 1 lane x batch 8 | 2 lanes x batch 8, lane sync on | **+5.4%** offline, +5.3..+6.4% on the pool (2 h and 6 h), J/inf -0.9..0% |
| RTX 3070 Laptop | 1 lane x batch 8 | 2 lanes x batch 8, lane sync on | **+5.1%** on the pool (30 min), J/inf -0.4% (one laptop) |
| CMP 50HX | 1 lane x batch 16 | 2 lanes x batch 8 | **+4.05%** on a 5-card HiveOS rig (3.3 h on the pool), J/inf -1.2% (one rig, see the notes) |
| RTX 3080 Ti | 1 lane x batch 8 | 1 lane x batch 20 | **+10.2%** on the pool (3 h 20 min ABBA), J/inf -3.8% |
| every card (conv_out) | | | +0.3% (RTX 3070, 4070 Ti; not on sm_75) |
| RTX 4070 Ti | 1 lane x batch 6 | 2 lanes x batch 6, lane sync off | **+2.37%** on the pool (ABBA, 4 pairs), J/inf +1.78% (worse), see the notes |
| other laptops, AMD, others | | unchanged (1 lane) | `--lanes 2` by hand, see below |

- **Two lanes by default on the RTX 3070 (desktop and laptop), the RTX 4070 Ti and the CMP 50HX** (`--lanes 0`, the default). A lane is one stream of batches on the GPU; the
  second one fills the idle tails of the waves of the first. The choice is a table of measured cards (`host/src/lanes.rs`: card name, SM, free VRAM, free host
  RAM): RTX 3070 2 x batch 8 with 6.6 GB VRAM free (+5.4%, VRAM 3.3 -> 5.9 GB); RTX 3070 Laptop 2 x batch 8 with 6.6 GB VRAM free at the start (+5.1% on the
  pool, J/inf -0.4%, VRAM 3.1 -> 5.6 GB of 8; with an external display or another program on the card it stays on 1 lane); CMP 50HX 2 x batch 8 with 7.5 GB
  VRAM and 900 MiB host RAM free (+4.05% against 1 x batch 16 on 5 cards, VRAM 4.3 -> 5.4 GB per card; the rig's lowest free RAM went 1559 -> 1238 MiB, so
  below 900 MiB the second lane is not started and a WARNING says why; at the start a card waits up to 180 s, logged, for the other cards' model loads to
  give the memory back). RTX 4070 Ti 2 x batch 6 with 7 GB VRAM free (+2.37% inf/s against 1 x batch 6, ABBA on the pool with auto-uv, but J/inf +1.78%: a small gain that costs a little energy per inference; a card whose VRAM is shared with an LLM stays on 1 lane). One lane stays on: RTX 3080 Ti (+0.5%, batch 20 instead, next item), other
  laptops, AMD and every card not in the table. **`--lanes N` always wins**: `--lanes 1` (or `--no-lanes`) switches the lanes off and gives the behaviour
  of 0.4.5 (`GPU0: lanes: 1 (--lanes 1)` in the log), `--lanes 2` = two lanes on any card; both also in HiveOS Extra config and in `start.bat` EXTRA. With
  `--lanes 2` by hand on a CMP 50HX the miner only warns when less than 900 MiB of RAM is free. The log shows the decision (`GPU0: lanes auto: 2 lanes (...)` / `auto: 1 lane (why)`); `lanes`, `lane_stops`, `lane_hangs`,
  `lane_integrity_errors` and `job_latency_ms` are in the API per GPU. `--lanes 2` without `--batch` uses batch 8 per lane (6 on Ada). Do not use
  `--lanes 2` with 0.4.5: its second lane is the incomplete copy fixed below.
- **Lane sync (`--lane-sync auto|on|off`).** Two lanes of an RTX 3070 can fall into antiphase (the second lane starts half a batch after the first); then both run
  as slowly as one lane, and that state lasted until the next canary round moved them: 12-19% of the time on the pool, -5.5% while it lasted (one cause of the
  "phases at the speed of one lane" seen in testing). The lanes of a card now start every batch together (a barrier with at most 500 ms wait; a lane back from a
  canary round rejoins; a lane that stops is not waited for): without it 9.6-47% of 5-second windows in antiphase under frequent canary rounds, with it 0 of 584.
  The barrier does not help every card, so `auto` (the default) uses a table of measured cards, for automatic lanes and for `--lanes N` by hand: on for the RTX 3070
  and the RTX 3070 Laptop (there 2 lanes without it are exactly as fast as 1); off for the CMP 50HX (the phase it forces is ~1% slower there: -1.5%), the RTX 3080 Ti
  (it runs two lanes one after the other anyway: -0.7%), the RTX 4070 Ti (neutral) and every card not measured. `on` = every card with 2+ lanes, `off` = never. The log
  names the decision and the reason (`GPU0: lane sync: on (RTX 3070: antiphase measured, ...)`). Only the moment a batch is launched changes, never what is computed.
- **RTX 3080 Ti: automatic batch 20 on one lane** (was 8). Measured on a 3080 Ti (80 SM, core lock 1470 MHz, memory 9251 MHz): offline batch 8 58.91 inf/s, batch 16
  62.75, **batch 20 64.88 (+10.2%, J/inf -2.4%)**, batch 32 65.00 (needs 8.7 GB); on the pool with auto-uv 58.51 -> 64.51 inf/s (+10.2%, J/inf -3.8%, 0 rejected).
  Batch 20 takes about 6.7 GB of the card (the miner 5.4 GB plus the desktop); with less than 6.5 GB free the usual batch 8 is used. A table in `host/src/lanes.rs`
  (`BATCH_RULES`) holds the rule; only this card is in it: the RTX 3090, 3080, 4080, 4090 and every other card keep their default batch until somebody measures them
  (a bigger batch was no gain on the 3070 and the 4070 Ti). `--batch N` always wins. A new job is picked up after one batch (about 0.3 s instead of 0.15 s).
- **Engine: the second lane was not a full copy.** The clone of an engine (`vg_clone`) did not take over six fields derived from the model file: the second lane ran
  on slower fallback kernels on sm_80+ (it lost 5% on a 3080 Ti) and on sm_75 (CMP 50HX) it failed the self-test
  with a MISMATCH. Fixed. A lane that fails to start gives its memory back. Lanes of one card run at equal stream priority (the low-priority lane starved: 61 / 14
  passes against 37 / 38); `VG_LANE_PRIO=1` restores the old priorities.
- **The clone check is complete.** Before a lane mines, `vg_clone_check` compares EVERY data member of the engine that is not private to a lane (112 of 151, the other 39
  are the lane's own; a list in the engine source), including the weight maps entry by entry; a build test fails when a member is added to the engine without a class
  in that list. Besides that the miner compares the kernel path of a pass of 1, an odd number and the work batch on both engines (`vg_kernel_path`: the pass is captured
  into a CUDA graph that is thrown away unrun, its kernels / grids / blocks / shared memory are hashed; 6-17 ms). Every extra lane also passes the test vector and the
  whole 56-case consensus canary. Any difference is an INTEGRITY refusal of that lane (`lane kernel path = lane 0's` in the log otherwise).
- **A second lane never stops a GPU from mining**, with automatic lanes and with `--lanes N` by hand. It is started only after the first lane passed the self-test
  and ran all its graphs; it needs the VRAM read live from the driver (and host RAM where the table asks for it in auto). If any check fails (self-test, canary,
  clone check, kernel path, memory), or the lane runs out of memory while mining, a WARNING with the reason is logged, `lane_stops` counts it and the GPU mines on
  with the lanes that passed (not tried again in this process). When that leaves one lane and one lane has a bigger default batch (CMP 50HX 16, RTX 3080 Ti 20)
  and no `--batch` is given, the card is opened again with 1 lane at that batch (one more model load), so it is not slower than 0.4.5. An extra lane that sees
  3 INTEGRITY errors stops alone.
- **Hang detector for the extra lanes (`--lane-hang-secs`).** An extra lane whose GPU call (a pass, the integrity re-run, a new prompt) does not return for
  `max(30 s, 20 x the median pass time of that lane)` (at most 5 min unless the flag is higher; `--lane-hang-secs S`, 0 = off, else at least 10) is
  stopped ALONE: a WARNING in the log, `lane_stops` and `lane_hangs` in the API, `lanes` one less, no second lane again in this process; lane 0 and the
  other lanes mine on. Nobody waits for the stuck thread: the stop of the miner does not wait for it, the weights it shares are not freed under it, a worker
  restart becomes a restart of the whole miner (exit 3, settings put back first), and the process ends by the hard exit. The timer is on the host side (two atomic
  stores per pass, a monitor thread twice a second; nothing added to the engine's wait); a suspended machine gives no verdict. Lane 0 keeps the old rule:
  `--watchdog-hang` (40 s), the miner restarts.
- **Auto-undervolt sees the INTEGRITY errors of the extra lanes.** The lanes of a card share its clocks and voltage, but only lane 0's errors reached the tuner: on an
  RTX 4070 Ti an error of lane 1 at the offset being tried did not fail that step, and the profile was saved there (one step below an Xid). Now an error of any lane
  runs a canary round at once and fails the step being tuned (search, check, confirmation, memory search); while mining on a tuned offset it steps back 30 MHz, as
  an error of lane 0 does. It never stops the GPU and is no crash record: on a fixed `--uv-offset` or at the lowest offset lane 0's canary decides alone, and the
  clone stops itself after 3 errors (the reason the clone's errors had been kept away from the tuner in testing: a broken clone must not take the GPU down).
- **An out-of-memory is nobody's fault.** A worker that dies of a CUDA out-of-memory (another program took the card's memory, a lane did not fit) is no
  longer a "GPU fault": no crash record, no lower undervolt offset at the next start, no one-hour exclusion of the GPU. The miner logs a WARNING;
  when every GPU died that way it waits 60 s before it exits (HiveOS / start.ps1 restart it), so there is no hot restart loop. The API shows `lanes` 0
  while a worker is not mining.
- **Hard-fork / model-change monitor.** The VELA docs announce an early hard fork (model registry, model slot and cost exponent in the block
  header, payload v3); no mainnet height is published (checked 10.11.2026). This miner builds a 112-byte header and PoI v2 for one model; after a
  fork it would have computed for nothing until the 15-minute no-share watchdog. Now: a node (solo) is asked every 10 min (every minute when a switch
  is scheduled) for `getpoiinfo` (schedule, `model_switch_height`, `next_version`, `difficulty_multiplier`, loaded models), its tip header size and
  version; every template (node / AriaPool) and every stratum subscribe / notify is checked for the PoI version, model hash, `x0_size`, `vocab_size`
  and for fields this miner does not know. A scheduled switch gives a warning every 10 min with the block count; when the block being mined needs another
  version / model / header, mining is PAUSED (GPUs idle, no 15-minute blind run) with a message that names the reason and the release page, and it resumes
  by itself if the check passes again. `fork` in the API (`/summary`, `/`: state ok / notice / warning / paused, `need_update`, next activation,
  messages), `ffgv_fork_state` in `/metrics`, `fork-alert` file next to the miner (HiveOS shows `FORK: UPDATE MINER (paused)!!` / `FORK soon: update!!`).
  With several pools a pool that needs a newer miner is left like a failing one.
- **Adaptive canary period.** The consensus canary round (8 cases, ~0.54 s on an RTX 3070, measured) ran every 120 s = 0.45% of the time. While every round is
  clean and the offsets / lock / power knobs stay as they are, the period grows 120 s (10 rounds) -> 240 s -> 480 s -> 600 s; a failed round or INTEGRITY
  ERROR, any tuning phase, a changed setting (pulled forward to 5 s) or a card that warmed up by 6 degrees starts over at 120 s. `--canary-max S` (600; 0 = the
  old fixed period). The first rounds and every 30th are logged with their duration. `--bench` now also prints the canary round time.
- **Stratum: a share leaves within 25 ms** (the socket read timeout was 250 ms; shares were sent only after it expired: 50-236 ms measured with a mock pool, now below 30 ms).
- **RPC pools: tip poll every 1 s on a public pool** (was 2 s; a local node stays at 0.5 s), `--poll-ms MS` sets it (0.5 s possible).
- Engine: conv_out (N = 4) on the 64 x 64 tile instead of 64 x 320 (`VG_COUT64=0` = old), +0.3% on the 3070 and the 4070 Ti, bit-exact (test vector,
  40 seeds, canary); not on sm_75. Engine tag v0.1s5.
- Nonce ranges are reserved per possible lane, so GPUs of one rig with different lane counts never search the same nonces.

Honest notes:
- The CMP 50HX numbers are from one rig (5 cards, 3.3 h), the RTX 3080 Ti numbers from one card and one day, the 3070 numbers from two cards of one machine,
  the RTX 3070 Laptop numbers from one laptop (15-30-minute pool runs); the lane sync results come from 15-30-minute pool runs per card with canary rounds every
  20 s (a stress test). Your card may differ: `--lanes 1` / `--lanes 2` and `--lane-sync on|off` let you compare.
- The CMP 50HX rig that was measured rebooted by itself twice during the tests (a hard reset, cause not found), both times while a separate test process ran
  two lanes on one card; the miner itself ran on 2 lanes on all five cards for hours without trouble. If your rig starts to reboot with 0.4.6, add `--lanes 1`
  (HiveOS: Extra config) and tell us.
- Two lanes cost VRAM (1.5-2.5 GB per lane) and pick up a new job about 0.2 s later; with `--lanes N` given by hand there is no memory guard besides a warning
  (an out-of-memory then stops that lane alone).
- A clone that hangs while it is being started (self-test / canary / kernel path, before it mines) is not covered by the lane hang detector; the open watchdog of
  the card handles it as before (warnings, the miner ends after an hour).
- With 1 lane the nonce range of a GPU is half that of 0.4.5 (a slot is kept for a second lane): harmless, a job never comes near its end at tens of inferences per second.
- RTX 4070 Ti on 2 lanes: the gain is small (+2.37%, one pair only +1.86%) and J/inf is +1.78% worse. At the very edge of the undervolt (core offset +300 / +330 MHz) a second lane once ended with an Xid 31 / a hang in a test; auto-uv steps back on a lane error and the lane hang detector stops a stuck lane alone, but if you see `lane_stops` or Xid messages on this card put `--lanes 1` (or `--no-lanes`) into the arguments.

## 0.4.5 — 2026-11-07

- **New-version notice in HiveOS now reads `need update!!`** (owner's decision 06.11.2026, for all our miners): the version column shows
  `0.4.4 0.2023 inf/s/W, need update!!` instead of `, new 0.4.5`. The log line still names the new version and the release URL.

- **Solo: submitting a block no longer stops the polling for a new one.** `submitblock` now runs in its own thread. Before, the poll
  loop waited for the node's answer, and a node verifies a block with an inference on its CPU (seconds): a solo miner saw new jobs
  15–17 s late (log: tip at 21:16:28, `inconclusive` reject at :44, new job at :45), all GPUs worked on the old block meanwhile. Also: a node
  of your own (loopback / private network / Tailscale 100.64.0.0/10 / `.local`) is polled every 0.5 s instead of 2 s (public pools stay at 2 s); a submit that
  takes over 2 s is logged (`submitblock took N s`); a share that went stale while it waited in the queue is not sent.
- **Node RPC over a kept (HTTP keep-alive) connection** instead of a new TCP connection per call. A poll is now one round trip; on a lossy
  VPN (a rig on another site, 17% packet loss to the node) one lost SYN used to cost 1–2 s per call. A connection the node closed in the
  meantime is replaced by a new one (not after a timeout, so a block is never sent twice).
- **suprnova is now the first pool in all examples** (README, MANUAL, HIVEOS, `--help`); AriaPool is still supported and listed after it.

## 0.4.4 — 2026-11-05

- **The miner downloads the model itself.** When the `--model` file is not there at the start, `ffgv` downloads `sd-turbo-int.poisd`
  (1.19 GB) from Hugging Face (mirror: dl.ariabrain.com), continues a broken download at the next try (HTTP Range), and checks the
  sha256 before it puts the file in place: a half-loaded or a wrong file is never taken for the model. A lock file keeps two miners
  that start together from writing the same file. Nothing is touched when the model is there. `--no-model-download` turns it off.
  Before, only the Windows start scripts and the HiveOS `h-run.sh` did it; a plain Linux server or a container had to download the
  file by hand. Built into the miner (its own HTTPS client, no curl / wget needed).
- **AMD Radeon cards (Navi 21: RX 6800 / 6800 XT / 6900 XT / 6950 XT), Windows only in this release.** A second GPU engine, `velagpu_amd.dll` (OpenCL of the Adrenalin driver; no
  HIP / ROCm SDK, no CUDA, nothing to install), loaded next to the CUDA engine through the same C API: the test vector and all 56 consensus canaries
  are byte for byte the node's results on an RX 6800 XT (checked by the miner at every start). The CUDA engine and its SASS are not touched;
  a package without `velagpu_amd.dll` is the NVIDIA package of 0.4.3 and behaves the same. RX 6800 XT, batch 16, Windows, chip (ASIC) power, 4000 inferences
  per point with every x0 compared with the CPU hash: stock 2324 MHz / 1150 mV 23.22 inf/s at 271.8 W (0.085 inf/s/W); 2324 / 1050 23.38 inf/s at 230.2 W (0.102);
  2200 / 881 22.39 inf/s at 200.0 W; **2150 / 881 (`--mode eco`) 21.98 inf/s at 198.1 W (0.111: -5% speed, -27% power, +30% inf/s per W)**; 2250 / 881 gave **35 wrong x0
  of 4000** (and passed 56/56 canaries before and after).
  - **Kernels are precompiled.** `velagpu_amd.dll` carries the GPU kernels as binaries of the driver's own compiler for gfx1030 (Navi 21) and no kernel
    source text; the driver does not compile anything at the start, which is also why other Radeon chips (RX 6700 and below, the integrated Radeon of a
    Ryzen, RDNA3 / RDNA4) are not supported in 0.4.4: the miner finds no kernels for them and says so. The CUDA engine is byte for byte the engine of 0.4.3.
  - **One list of GPUs.** NVIDIA cards first (CUDA order = PCI bus order, as before), then AMD cards (PCI bus order). `--devices` takes these
    numbers, or `nvN` / `amdN` inside one vendor; `--no-amd`, `--no-nvidia`, `--amd-igpu` (the integrated Radeon of a Ryzen is never a default).
    A Radeon is found by name and architecture, not by index.
  - **VRAM and batch.** The model takes 1.25 GB and each attempt of the batch ~0.26 GB (2.0 GB at batch 8, 4.1 GB at batch 16): `--batch 0` takes
    the largest of 16 / 8 / 4 / 2 / 1 that fits the free VRAM (16 on 8 GB and 16 GB cards, 8 on 6 GB, 4 on 4 GB); a given batch that does
    not fit is warned about; a card under 3 GB is refused.
  - **Undervolting a Radeon is a risk (documented in README / MANUAL).** Past its edge the card computes wrong results silently, and further past it the video
    driver hangs (2324 MHz at 1000 mV hung the test card; only a driver reset (Win+Ctrl+Shift+B) or a reboot cures it). So every approach starts on the safe side in
    small steps, every step is checked first by canaries back to back, the point you end on is confirmed for >= 150 s and >= 4000 verified inferences, and the
    miner never takes a step after an error. On a hang it puts the owner's settings back, says "the video driver hung ... Win+Ctrl+Shift+B" and remembers the value
    (and anything more aggressive) as a failure in `amd-uv.json`.
  - **Card settings for AMD** (`--mode`, `--auto-uv`, `--auto-lock`, `--lock-cclock` = clock cap, `--amd-volt`, `--amd-pl`): our `amduv.exe` (ADLX, as a
    separate process) sets the clock cap, the core voltage and the power limit; `adlx_mon.exe` reads power / clock / temperature (never together with
    `amduv`: one ADLX session at a time). Presets for the RX 6800 XT: `eco` 2150 MHz / 881 mV; `balance` from 2324 / 1100 down in 25 mV steps (floor 1050), each step checked,
    the first error stops it; `speed` the stock 2324 / 1150 (power-limited at ~270 W: nothing faster exists). 2400 / 1100 is not a preset (not measured on VELA).
    `--auto-uv` raises the clock cap at the lowest voltage until the canary fails and stays one margin below the edge; the voltage is never lowered by a search
    and never raised past the edge. Results are saved per card in `amd-uv.json`; later starts check them in 20 s; a canary failure while mining steps the clock back
    25 MHz, two in a row give the owner's settings back.
  - **Always put back.** The owner's values are saved to a file before the first write and restored on every exit; a small guard process restores them if
    the miner is killed or crashes; after a killed process tree the next start of `ffgv` restores them (marker `amd-restore-<pid>.json`, like `clocks-restore`).
  - **Limits.** Windows first: the Linux / HiveOS AMD code (the same engine, settings through amdgpu `sysfs`) is written from the kernel documentation and
    was never run on a Linux Radeon. Several identical Radeons cannot be told apart by ADLX: they are mined as they are. Only the RX 6800 XT is measured (the other Navi 21 cards run the same kernels, not measured). Not verified: Linux / HiveOS on a Radeon (the Linux and HiveOS packages of 0.4.4
    do not contain the AMD engine), the auto-undervolt (`--mode balance`, `--auto-uv`, `--auto-lock`) steps on other copies of the card, other drivers than Adrenalin 25.5.1.

## 0.4.3 — 2026-11-04

**Engine — Turing only (CMP 50HX):** the first Turing (sm_75) support and its speed-up. The code of RTX 30 / 40 / 50 (sm_86 / sm_89 /
sm_120) is not changed: 220 of 220 functions of the 0.4.2 engine are byte for byte identical in SASS (sm_86), the new Turing kernels
are empty stubs there. CMP 50HX, batch 16, core lock 1500 MHz, the same card: **22.8 → 31.3 inf/s (+37%)** at 124 → 163 W
(inf/s per W 0.18 → 0.20). Results are byte for byte the node's consensus (test vector, 40 seeds at batch 8 and 16).

| part | what changed on Turing |
|---|---|
| attention | 8-warp blocks in the statistics and P·V kernels; P·V in two 6-warp blocks per SM (12 warps) with single K/V buffers; a packed 32-bit exponent table |
| GEMM | a 128×128 tile for the wide layers, row finishing off, the deferred shared stores kept behind the first MMAs, the next `ldmatrix` after two column groups |
| loading | the model is mapped (no second copy in RAM), automatic batch 16 |

Host: brings the auto-undervolt of FreeForGem 1.7.6 and the plan of 1.7.7 (decision of 02.11.2026) to VELA. Every step is still
decided by the consensus canaries.

- **A tuning that is cut short is not lost:** a stop (Ctrl+C, SIGTERM, HiveOS `miner stop` / config change, `--minutes`) or
  the fault of another GPU that ends the process saves the steps that passed (`uv.json`, `trying` with `foreign` and the
  edge found); the next start goes on from two steps below the last good one instead of the baseline. Before, a stop forgot it.
- **A fault counts only for the GPU with the Xid:** the step that the other GPUs of the process were trying (they stop with
  the CUDA fault, but did nothing wrong) is no longer written as their edge; the same for a hang of one GPU.
- **A failing start offset is checked once more** before the baseline goes down 30 MHz (a cold card or a one-off error
  made one PC end at +105 instead of +225 on 01.11.2026 in FreeForGem 1.7.6).
- **A new lock starts from the neighbour lock's profile** (kept from 0.4.1/0.4.2, now logged also for `--auto-lock` sweeps).
- **A GPU that cannot be opened at the start** ("busy or unavailable", "GPU is lost") is waited for (1, 5, 15 min, then every
  15 min) before the miner exits for HiveOS / `start.bat`, instead of hundreds of restarts; nothing is lowered.
- **CMP 50HX (Turing sm_75):** `--mode` presets (speed: unlocked; balance: lock 1500; eco: lock 1350), auto-undervolt start
  +210 / limit +450, `--auto-lock` range 1650 / 1500 / 1350. RTX 30 / RTX 40 presets are unchanged.
- **`--cmp-driver` (HiveOS, opt-in):** installs the CMP unlock driver (NVIDIA Open Kernel Module 610.43.03 build, SHA-256 checked, with
  `nvidia-driver-update --force`, then a reboot); nothing happens without the flag. In the flight sheet: `--cmp-unlock-driver`
  in Extra config arguments. A stock driver makes a CMP card ~11 times slower (2.4 against 27.4 inf/s on the same engine). A rig
  that already has the driver, or has no CMP card, is left alone. See MANUAL §6, HIVEOS.md.
- Build scripts add `sm_75` to the default architectures.
- **Found on a real HiveOS rig (5 x CMP 50HX, 3.8 GB RAM):**
  - the engines load the model one at a time when the free RAM does not hold more (every load reads the 1.2 GB file into RAM;
    five at once swapped for minutes at 0 inf/s). Linux: MemAvailable, Windows: available physical memory;
  - a hang while a GPU is still opening (model load, self-test) is no edge of its undervolt offset: nothing is counted against
    it and every card's tuning is kept (a GPU that cannot be opened twice in a row is left out for an hour instead);
  - a stop at any moment (also before mining began: the model still loads, a pool is not reached, a start error) keeps the tuning
    of every GPU; a process killed (SIGKILL, OOM killer, power) before a step ran its first inference does not make that step an
    edge; a profile that was never measured (`0.00 inf/s @ 0 W`, the limit left by a crash) stays "unchecked".

## 0.4.2 — 2026-11-01

Engine: **+3.7% inf/s** on the RTX 3070 and the RTX 4070 Ti (bench 400 at a fixed clock, the same host, old / new / old /
new: RTX 3070 at a 1500 MHz lock 35.26 → 36.57 inf/s, RTX 4070 Ti at 2250 MHz 64.08 → 66.42). Results are byte for byte
the node's consensus (test vector, 40 consensus seeds, canary 56/56 on both cards, the same x0 as 0.4.1).

| engine | what changed |
|---|---|
| altO | cross-attention: the last, partial key block (77 prompt tokens) also on the fast int32 path; the row bound without FP64; a 32-bit P·V epilogue; one load of the key tiles for both sweeps |
| altP | GroupNorm chain: the statistics in one pass with 32-bit arithmetic; the per-pixel maxima before the slot convolutions from a certified float bracket with an exact fallback |

Both rounds passed an independent audit (proofs re-derived; CPU and GPU stands at the boundary; a shadow run on real
tensors with 0 differences) and ran in production before the release.

Host — the feature set shared by our miners (FreeForGemSaseul 0.5.4, FreeForGem 1.7.5), adapted to VELA: the undervolt
edge on VELA is quiet (a slightly wrong x0, not a crash), so every decision below that touches clocks is still taken by
the consensus canaries byte for byte, and no safety margin is smaller than in 0.4.1.

- **Settings go back after every kind of stop, GPU work first:** Ctrl+C, SIGTERM / SIGHUP (HiveOS `miner stop`), a second
  Ctrl+C, the Windows console window closing (within the ~5 s Windows allows), the new `--minutes M`, the hang watchdog,
  a GPU fault before the miner restarts itself, an error. The miner first lets every GPU finish its batch (a hung GPU does
  not hold it up), then puts back the core and memory offsets, the clock locks (the HiveOS OC profile's, if any) and the
  power limit. Crash markers are kept per process and per boot: a second ffgv on the same rig, or a marker from before a
  reboot, is never "restored" over.
- **The miner's flags win over the HiveOS OC profile while mining:** if HiveOS (an OC change in the web UI) or another tool
  changes a lock, the memory lock that `--mode` lifted, or the power limit, the miner sets its own again (also without
  auto-UV; at most 4 times an hour per GPU) and the canary re-checks the GPU. A GPU crash right after such an outside
  change is not counted against its undervolt.
- **`--auto-lock`:** the miner picks the core clock lock per GPU: it mines at several locks (each tuned by auto-UV and
  checked by the canaries), measures inf/s and watts, and keeps the most efficient lock within `--auto-lock-max-loss` %
  (10) of the top speed (`--auto-lock-goal speed`: the fastest). A point counts only after a canary round after its
  measurement passed. Saved per GPU / driver / memory setting: the next start applies it at once. `--auto-lock-range`,
  `--auto-lock-reset`. Windows: `AUTO_LOCK=1` in start.bat.
- **Slowdown watchdog:** a GPU below 30% of its own speed for 3 minutes (no Xid, no error) gets a fresh worker; on a tuned
  offset the offset first goes 30 MHz down. `--watchdog-drop`, `--watchdog-minutes`, `--watchdog-hang` (the hang limit,
  40 s), `--no-watchdog`. A slowdown under hardware throttling, or of most GPUs at once (the rig), is only logged.
- **Back to the primary pool:** while a backup pool is used, the primary is checked on a separate connection every
  `--failback-minutes` (10); after 2 good checks the miner goes back (0.4.1 switched back blindly after 10 min). New
  **no-accepted-shares watchdog**: no accepted share for max(15 min, 10 share intervals), only rejects for 5 min, or no
  job for 5 min → reconnect, then the next pool (`--noshare-minutes`, `--reject-minutes`; never in solo or the fee minute).
- **`--temp-limit C`** (laptops): keeps the GPU at or below C by idle gaps (`--temp-stop`); the lock of a canary-checked
  offset is never lowered. Windows: `TEMP_LIMIT=80`.
- **Per-GPU lists, one rule for all options:** `x` / `-` / empty = leave that GPU alone, a shorter list repeats its last
  value (as HiveOS does), `--uv-step` per GPU, `x` in a `--uv-min` / `--uv-max` / `--uv-step` list = no auto-UV on that
  GPU; one start-up line per GPU with what is set on it; `--dry-run` prints those lines and changes nothing.
- **API:** `--api [HOST:]PORT` adds `/summary`, `/gpus` and `/metrics` (Prometheus) to the JSON at `/` that HiveOS reads
  (unchanged). Read-only, never a password, Host-header check (`--api-hosts`), no CORS (the `/` JSON no longer sends
  `Access-Control-Allow-Origin: *`). Windows: `API=4078`.
- **New-version notice:** about every 12 h one request to the GitHub release page; a newer release is logged and shown
  in HiveOS next to the version (`0.4.2 0.301 inf/s/W, new 0.4.3`). Nothing is downloaded or installed;
  `--no-update-check`, `--check-update`.
- **Windows autostart:** `install-autostart.bat` (asks for Administrator once) starts start.bat at your logon;
  `remove-autostart.bat` undoes it.
- uvfast completed: a profile that ended on the voltage floor is not used as the start of a lower lock.
- The core-lock warning no longer speaks of "the single --lock-cclock" when the lock comes from `--mode`.
- The start-up line of each GPU shows its memory clock and memory offset too.

## 0.4.1 — 2026-11-01 (Linux / HiveOS hotfix)

- **HiveOS / older Linux:** the 0.4.0 Linux and HiveOS packages did not start on HiveOS ("cannot load the GPU engine
  (libvelagpu.so: cannot open shared object file)"): the engine library had been built on Ubuntu 24.04 and needed
  glibc 2.38 / libstdc++ GLIBCXX_3.4.32. 0.4.1 builds the engine and the miner on Ubuntu 20.04: they need glibc 2.31 or
  newer (HiveOS on Ubuntu 20.04 and 22.04, Ubuntu 20.04–24.04, Debian 11+), libstdc++ is linked into the engine.
- **Clear engine load error:** if the engine cannot be loaded, the miner now shows the error of every place it tried,
  the copy next to the binary first (e.g. "GLIBC_2.38 not found"), instead of only the last one.
- **HiveOS memory lock:** `--mode speed` / `balance` lift a memory clock lock of the HiveOS OC profile while mining and
  put it back on stop (a SASEUL / Pearl flight sheet before VELA leaves the memory locked to 810 MHz: RTX 3070 ~8 inf/s
  instead of ~35, seen on a HiveOS rig while testing 0.4.1). `--lock-mclock` given by you still wins.
- **Faster auto-undervolt** (from FreeForGemSaseul 0.5.4): 30 MHz steps, 15 MHz only inside the interval where a step
  failed (the same 15 MHz result in about half the steps); the voltage-floor stop scales with the step; a new clock lock
  starts 30 MHz below the profile of a higher lock. Every step is still decided by the consensus canaries, the margin and
  the 150 s confirmation are unchanged. `--uv-coarse MHz` (default 2 x `--uv-step`; 15 = the old climb).
- The engine is the same source as 0.4.0 (ac81eae), compiled with CUDA 12.8 instead of 12.9: results are byte for byte
  the same (test vector, canaries, 40 consensus seeds) and the speed is the same. Windows package unchanged (0.4.0).

## 0.4.0 — 2026-10-31

Engine (GPU library) — all rounds since the 0.3.0 host, one line per merged round:

| engine | what changed | RTX 3070 | RTX 4070 Ti |
|---|---|---|---|
| 78c88b7 (start of the 0.3.0 host) | 32-bit GEMM epilogues and normalizations | 27.84 | 54.41 |
| e87d2e8 | 3×3 convolutions from "pixel slots" instead of im2col; attention on 3 CTA/SM; to_q+to_k in one GEMM | 30.44 (+9.3%) | 57.93 (+6.5%) |
| 7e6aec6 | timeline: fewer element-wise passes; 17-bit outputs of GEGLU and attention (int16 + rounding bit) | 31.02 (+2.1%)¹ | 59.76 (+4.3%)¹ |
| c0a08b3 | attention math: max pass on high bytes (Cauchy–Schwarz bound), keys grouped by exponent | 32.09 (+2.1%)² | 60.63 (+2.0%)² |
| 896625d | LayerNorm rows and raw-int32 quantization (RAWQ) | 31.66³ | 60.95³ |
| c560d98 | GEMM: 64×128 tiles from 4 warps, convolutions N=320 as 64×320 tiles; host: 1 lane, batch 6 on Ada | 32.78 (+3.5%)⁴ | 64.00 (+6.1%)⁴ |
| **ac81eae (0.4.0)** | GEMM: residual loaded before the C stores, 64×320 / 64×256 tiles for slot convolutions; GEGLU walked in M groups when the weights exceed L2/2 | **33.78 (+3.9%)⁵** | **65.44 (+2.1%)⁵** |

Total since the start of the 0.3.0 host: **RTX 3070 27.84 → 33.78 inf/s (+21%), RTX 4070 Ti 54.41 → 65.44 (+20%)**.

¹ against the then production engine 5cc5a00 (30.38 / 57.30). ² against its own base 31.41 / 59.46.
³ deployment bench of 896625d (host bench, a different series). ⁴ host A/B against 896625d (31.66 / 60.33).
⁵ host A/B against c560d98 (32.50 / 64.09), 3 rounds.

What the auto-undervolt and the modes add on top of that, measured on this release: see the speed and power table in
README.md / MANUAL.md.

Every engine change is exact: x0 is byte for byte the node's consensus result. Each merged round was audited on
sm_86 and sm_89: hundreds of seeds against the node's CPU code, flag matrices, 1000 graph replays, compute-sanitizer
(sync/mem/racecheck) clean.

Host and packaging:
- **Failover fix:** the return to the primary pool after 10 minutes on a backup looped (stratum: about 2 reconnects a second;
  AriaPool / solo: an idle loop without mining). Fixed.
- AriaPool / solo: shares of a previous session are dropped, shares of an old block count as stale (S), not rejected.
- The node RPC password is hidden in the log and in the API; a wrong RPC login now says "401 Unauthorized" plainly.
- Windows `start.bat` / `start.ps1` accept `stratum+ssl://` pools (TLS was refused by the start script).
- `--version` (`-V`) prints the version and exits.
- The version comes from `host/Cargo.toml` only (stratum user agent `FreeForGemVela/0.4.0`, API `version`, HiveOS manifest).
- Packages now carry README (EN and RU), CHANGELOG, LICENSE and NOTICE (third-party licenses: CUTLASS, CUDA runtime, Rust crates).

## 0.3.0 — host (2026-10-30; not released as a package, ran in production on 0.3.0 + the engines above)

- **Modes `--mode speed|balance|eco`**: clock presets per GPU family plus the auto-undervolt.
  RTX 30: speed = no clock lock + memory up to +750; balance = core lock 1500 + memory up to +1000; eco = core lock 1400 + memory locked at 5001.
  RTX 40: speed = no lock; balance = lock 2250; eco = lock 2100 + memory locked at 5001. RTX 50 and others: no preset (clocks as they are, auto-undervolt only).
  `--lock-cclock`, `--lock-mclock`, `--moffset`, `--pl`, `--uv-offset` given by the owner win over the preset.
- **Auto-undervolt of core and memory**: the core offset is searched first, then the memory offset (`--auto-mem`, `--mem-max`,
  `--mem-step` 250; automatic in the modes). The edge is the first failed consensus canary **or a hang**; the result is
  the smallest memory offset within 1% of the best speed and at least one step below the edge, then a 150 s confirmation.
  Profiles per GPU UUID and clock key in `uv.json`; with a saved profile the start takes 30 s (quick check).
  After a crash the search resumes two steps below the last good offset; a clean stop in the middle of tuning is not taken as an edge.
- **Hang watchdog**: a GPU that has not returned a batch or a canary for 40 s is reported as `HUNG`; the profile is lowered
  (memory one step, otherwise core −30 MHz), the owner's clocks and offsets are put back, and the process exits with code 3
  (HiveOS, systemd and `start.ps1` restart it). Without auto-undervolt the event goes to `gpu-faults.json` (2 in a row: the GPU is off for an hour).
- **Stratum over TLS**: `stratum+ssl://` (also `stratum+tls://`, `stratums://`) via rustls with the Mozilla roots built in
  (no system certificates needed on HiveOS or Windows); certificate chain and host name are checked. suprnova port 7604.
- **`--suggest-diff D`**: sends `mining.suggest_difficulty` after login (suprnova accepts it, then its vardiff takes over).
- **Stale shares**: a share found on a block that has already changed is not sent; pool answers with code 21 count as stale (S), not rejected.
  Stats line `A x R y S z`, API field `stale`.
- **Canary 56**: the consensus canary grew from 40 to 56 cases (+8 on a 73-token prompt, +8 on a one-token prompt);
  every canary round runs batch 1, an odd batch and the working batch. `--selftest` = test vector + 56/56.
- **Lanes and batch**: automatic default is 1 lane everywhere, batch 6 on Ada (sm_89+) and 8 on sm_86
  (RTX 4070 Ti +5.1% against the earlier 2 lanes × batch 4). `--lanes N` and `--batch N` still override.
- Memory offset shown in the stats line (`m+500`); the owner's memory offset is read and put back on exit and after a crash.

## 0.2.0 — 2026-10-30 (packages 0.2.0r58 HiveOS / 0.2.0r57 Windows, not published)

- Auto-undervolt (`--auto-uv`) driven by the consensus canary: on VELA an undervolted GPU first computes a wrong x0
  without any Xid, so the check is byte for byte against the node's results, not "no crash".
- Clock control: `--lock-cclock`, `--lock-mclock`, `--moffset`, `--pl`; put back on exit and after a crash. Xid handling with self-restart.
- suprnova stratum (vela/1.1), failover between several `--pool`, solo through the node's RPC.
- JSON API (`--api-port`), HiveOS package with `h-stats.sh`, Windows package with `start.bat` / `start.ps1`.
- Engine 9c0c27d: RTX 3070 24.9 inf/s, RTX 4070 Ti 49.0 inf/s (stock).
