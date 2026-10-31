@echo off
rem FreeForGem-VELA -- see LICENSE
setlocal EnableExtensions
title FreeForGemVela - VELA miner

rem ================================================================
rem  FreeForGemVela for Windows - EDIT THESE VALUES
rem ================================================================
rem Your VELA wallet address (vela1...). REPLACE the address below with YOUR OWN:
rem as shipped it is the developer's address, and everything you mine would go there.
set "WALLET=vela1q8n67wrnsz0f5g4f6qwvmz6radx9jy6uujd64eh"
rem Pool. One or more, comma separated: the first is used, the others are the failover (backup) pools
rem (the miner switches after a few failed connects and tries the first pool again every 10 minutes).
rem No registration on either pool: the login is your wallet + worker (WALLET.WORKER), the miner builds it.
rem   AriaPool:  http://159.69.194.46:3349
rem              pool.ariabrain.com/vela.html - fee 3%%, PPLNS, payout from 1 VELA; difficulty set by the pool
rem   suprnova:  stratum+tcp://vela.suprnova.cc:7601   (difficulty adjusts to your speed - recommended)
rem              stratum+tcp://vela.suprnova.cc:7602   (fixed difficulty 2048 - one GPU)
rem              stratum+tcp://vela.suprnova.cc:7603   (fixed difficulty 16384 - rigs of many GPUs)
rem              stratum+ssl://vela.suprnova.cc:7604   (like 7601, over TLS, encrypted)
rem              vela.suprnova.cc - fee 1%%, PPLNS (last 5 rounds), payout from 0.01 VELA every 15 minutes
rem              (a found block pays after 101 confirmations, about 8 hours)
rem              start difficulty on 7601/7604 (optional): add  --suggest-diff 4096  to EXTRA below
rem   solo:      http://RPCUSER:RPCPASSWORD@127.0.0.1:19732   (your own synced VELA node; rpcuser / rpcpassword /
rem              rpcport from vela.conf, see solo/vela.conf.example in the repository; the whole block reward is yours)
rem   Examples:  set "POOL=stratum+ssl://vela.suprnova.cc:7604,http://159.69.194.46:3349"
rem              set "POOL=http://159.69.194.46:3349,stratum+tcp://vela.suprnova.cc:7601"
set "POOL=stratum+tcp://vela.suprnova.cc:7601,http://159.69.194.46:3349"
rem Worker (rig) name: letters, numbers, dots, underscores, hyphens
set "WORKER=%COMPUTERNAME%"
rem GPUs to use: empty = all GPUs, or a list like 0,1,3 (indexes from nvidia-smi)
set "DEVICES="
rem Ready mode (Administrator): speed / balance / eco = clock presets per GPU family + the undervolt auto-tuner for them
rem (balance: nearly the speed for less power; eco: the least power). Empty = your clocks as they are. Example: balance
set "MODE="
rem Optional undervolt auto-tuner: finds the core offset per GPU; every step is checked byte for byte against consensus
rem inferences (a wrong result = a rejected share, so this check decides, not a crash). Needs start.bat run as Administrator.
rem To enable it, remove "rem" from the next line:
rem set "AUTO_UV=1"
rem Fixed core offset instead of tuning, MHz (checked the same way). Example: 180  or per GPU: 180,-,150
set "UV_OFFSET="
rem Highest offset the tuner tries / where it starts, MHz (empty = per card type):
set "UV_MAX="
set "UV_MIN="
rem Optional GPU clocks (Administrator; empty = leave as is). One value for all GPUs, or a comma list in DEVICES order.
rem Lock core clock (MHz), e.g. 1500:
set "LOCK_CCLOCK="
rem Lock memory clock (MHz):
set "LOCK_MCLOCK="
rem Memory clock offset (MHz, needs NVIDIA driver 555+):
set "MOFFSET="
rem Power limit (W), e.g. 135:
set "PL="
rem Any other miner options, e.g. --uv-reset (forget the undervolt profile of the clocks now, once) or --api-port 4078
set "EXTRA="
rem Pool password (normally empty)
set "PASSWORD="
rem ================================================================

set "PS=powershell.exe"
where pwsh.exe >nul 2>&1 && set "PS=pwsh.exe"
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0start.ps1" -Wallet "%WALLET%" -Pool "%POOL%" -Worker "%WORKER%" -Devices "%DEVICES%" -AutoUv "%AUTO_UV%" -UvOffset "%UV_OFFSET%" -UvMax "%UV_MAX%" -UvMin "%UV_MIN%" -LockCclock "%LOCK_CCLOCK%" -LockMclock "%LOCK_MCLOCK%" -Moffset "%MOFFSET%" -Pl "%PL%" -Mode "%MODE%" -Extra "%EXTRA%" -Password "%PASSWORD%"
echo.
echo FreeForGemVela stopped (exit code %ERRORLEVEL%).
pause
