FreeForGemVela (ffgv) for Windows - GPU miner for VELA (Proof-of-Inference)
===========================================================================

1. Unpack the whole folder to a path without spaces, e.g. C:\FreeForGemVela
2. Right-click start.bat -> Edit: put YOUR vela1... address into WALLET, choose POOL (several = failover), WORKER.
3. Double-click start.bat. The first start downloads the model sd-turbo-int.poisd (1.19 GB, checked by sha256).
   The console window is the log (no log files). Ctrl+C stops the miner; your GPU settings are put back.

Needs: NVIDIA RTX 30 series or newer, 6+ GB VRAM (8 GB recommended), a recent NVIDIA driver.
Dev fee: 1% of the mining time (one 60 s slot every 100 minutes).

Ready modes: MODE=speed | balance | eco (clock presets per GPU family + the undervolt auto-tuner for them; your
LOCK_* / MOFFSET / PL values win over the preset). balance: about the speed for less power; eco: the least power.
Undervolt (MODE, AUTO_UV=1 / UV_OFFSET) and clocks (LOCK_CCLOCK, LOCK_MCLOCK, MOFFSET, PL) need "Run as administrator".
A GPU that hangs (no result for 40 s, e.g. memory pushed too far) is caught: the miner lowers what it tried and restarts.
On VELA a GPU that is pushed too far does not crash first - it computes a slightly different result, and the pool
rejects the share. So the miner checks every setting with consensus test inferences (known results, byte for byte),
keeps checking while mining, and steps the offset back 30 MHz when a check fails. Saved results (per GPU and per core
clock lock) are in uv.json next to ffgv.exe; --uv-reset in EXTRA forgets the one of the current clocks.

Stats as JSON: add --api-port 4078 to EXTRA and open http://127.0.0.1:4078/
