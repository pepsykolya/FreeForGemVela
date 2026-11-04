# FreeForGemVela (ffgv) — changelog

Speeds are inferences per second (inf/s, 1 inference = 1 share attempt). Unless stated otherwise: RTX 3070 at power
limit 135 W, RTX 4070 Ti at 190 W, stock clocks, offline benchmark with the consensus check (test vector + canaries
byte for byte equal to the VELA node's own CPU code). Each engine round was measured as an A/B against the build
before it on the same cards, so the steps below are exact; the series of different rounds used slightly different
bench scripts (±1%).

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
