# FreeForGemVela (ffgv) — changelog

Speeds are inferences per second (inf/s, 1 inference = 1 share attempt). Unless stated otherwise: RTX 3070 at power
limit 135 W, RTX 4070 Ti at 190 W, stock clocks, offline benchmark with the consensus check (test vector + canaries
byte for byte equal to the VELA node's own CPU code). Each engine round was measured as an A/B against the build
before it on the same cards, so the steps below are exact; the series of different rounds used slightly different
bench scripts (±1%).

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
