#requires -Version 5.1
# FreeForGem-VELA -- see LICENSE
# Checks the setup (wallet, pools, GPUs / VRAM, the model file: downloaded once and checked by sha256), then runs ffgv.exe
# (one process drives all selected GPUs) with its output in this window, and restarts it 15 s after any exit.
# No log files: the console window is the log.
[CmdletBinding()]
param(
    [string]$Wallet, [string]$Pool = 'stratum+tcp://vela.suprnova.cc:7601', [string]$Worker = $env:COMPUTERNAME,
    [string]$Devices = '', [string]$AutoUv = '', [string]$UvOffset = '', [string]$UvMax = '', [string]$UvMin = '',
    [string]$LockCclock = '', [string]$LockMclock = '', [string]$Moffset = '', [string]$Pl = '', [string]$Mode = '', [string]$AutoLock = '', [string]$TempLimit = '', [string]$Api = '', [string]$Extra = '', [string]$Password = ''
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Set-Location -LiteralPath $root
function Fail([string]$message) { Write-Host "ERROR: $message" -ForegroundColor Red; exit 1 }
$DevWallet = 'vela1q8n67wrnsz0f5g4f6qwvmz6radx9jy6uujd64eh'
$ModelName = 'sd-turbo-int.poisd'
$ModelSha = 'ba38ab96b3398e22ea631d8a457350f91833e57463199d063663308513651f36'
$ModelSize = 1187585285
$ModelUrls = @('https://huggingface.co/valereseach/vela-sd-turbo-int-v2/resolve/main/sd-turbo-int.poisd',
               'https://dl.ariabrain.com/vela-dl/sd-turbo-int.poisd')

if ($root -match '\s|[^\x00-\x7F]') {
    Write-Host "WARNING: the folder path contains spaces or non-English letters: $root" -ForegroundColor Yellow
    Write-Host "         If the miner fails to start, move the folder to e.g. C:\FreeForGemVela" -ForegroundColor Yellow
}
if (-not (Test-Path -LiteralPath (Join-Path $root 'ffgv.exe'))) { Fail 'ffgv.exe is missing - unpack the whole archive again.' }
if (-not (Test-Path -LiteralPath (Join-Path $root 'velagpu.dll'))) { Fail 'velagpu.dll (the GPU engine) is missing - unpack the whole archive again.' }

# wallet / worker / pools
if ([string]::IsNullOrWhiteSpace($Wallet)) {
    Write-Host 'WALLET is empty. Right-click start.bat -> Edit, and set WALLET to your VELA address (vela1...).'
    $Wallet = (Read-Host 'Or paste the wallet address now').Trim()
}
$Wallet = ($Wallet -replace '\s', '')
if ($Wallet -cnotmatch '^vela1[02-9ac-hj-np-z]{20,90}$') { Fail 'WALLET does not look like a VELA address (vela1..., lower case).' }
if ($Wallet -ceq $DevWallet) {
    Write-Host '************************************************************************' -ForegroundColor Yellow
    Write-Host ' WALLET is still the developer address from the example: you are mining' -ForegroundColor Yellow
    Write-Host ' to the developer, not to yourself. Right-click start.bat -> Edit and put' -ForegroundColor Yellow
    Write-Host ' YOUR vela1... address into WALLET. Starting in 15 s (Ctrl+C to stop)...' -ForegroundColor Yellow
    Write-Host '************************************************************************' -ForegroundColor Yellow
    Start-Sleep -Seconds 15
}
if ($Worker -cnotmatch '^[A-Za-z0-9._-]{1,64}$') { Fail 'WORKER: letters, numbers, dots, underscores and hyphens only.' }
$pools = @($Pool.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($pools.Count -eq 0) { Fail 'POOL is empty.' }
foreach ($p in $pools) {
    if ($p -cnotmatch '^(http://([^@/\s]+@)?[A-Za-z0-9._-]+:[0-9]{1,5}/?|((stratum\+(tcp|ssl|tls)|stratums)://)?[A-Za-z0-9._-]+:[0-9]{1,5})$') {
        Fail "POOL '$p' must look like http://HOST:PORT (AriaPool / solo node) or stratum+tcp:// / stratum+ssl://HOST:PORT (suprnova)."
    }
}

# GPUs and VRAM (the model + a batch of 8 need about 6.5 GB; with less the miner runs smaller batches)
$smi = Get-Command nvidia-smi.exe -ErrorAction SilentlyContinue
$smiPath = if ($smi) { $smi.Source } elseif (Test-Path 'C:\Windows\System32\nvidia-smi.exe') { 'C:\Windows\System32\nvidia-smi.exe' } else { $null }
if ($smiPath) {
    $rows = & $smiPath --query-gpu=index,name,memory.total,driver_version --format=csv,noheader,nounits 2>$null
    if (-not $rows) { Fail 'nvidia-smi found no NVIDIA GPU (is the driver installed?).' }
    $sel = if ($Devices) { @($Devices.Split(',') | ForEach-Object { $_.Trim() }) } else { $null }
    foreach ($r in @($rows)) {
        $f = @($r.Split(',') | ForEach-Object { $_.Trim() })
        if ($sel -and ($sel -notcontains $f[0])) { continue }
        $mib = [int]$f[2]
        $col = if ($mib -lt 6000) { 'Yellow' } else { 'Gray' }
        Write-Host ("GPU{0}: {1}, {2} MiB VRAM, driver {3}" -f $f[0], $f[1], $mib, $f[3]) -ForegroundColor $col
        if ($mib -lt 6000) { Write-Host '  WARNING: less than 6 GB VRAM - the model may not fit; add --batch 2 to EXTRA if loading fails' -ForegroundColor Yellow }
        if ($f[1] -notmatch 'RTX (30|40|50)|RTX A|RTX PRO|CMP (70|90|170)') { Write-Host '  WARNING: RTX 30 series or newer is needed' -ForegroundColor Yellow }
    }
} else {
    Write-Host 'WARNING: nvidia-smi.exe not found; the GPU check is skipped' -ForegroundColor Yellow
}

# the model: downloaded once, checked by sha256 (a marker remembers the check: size + time of the file)
$model = Join-Path $root $ModelName
$mark = "$model.ok"
function Sha256File([string]$path) {
    $sha = [Security.Cryptography.SHA256]::Create(); $fs = [IO.File]::OpenRead($path)
    try { return ([BitConverter]::ToString($sha.ComputeHash($fs))).Replace('-', '').ToLower() } finally { $fs.Dispose(); $sha.Dispose() }
}
function ModelOk {
    if (-not (Test-Path -LiteralPath $model)) { return $false }
    $fi = Get-Item -LiteralPath $model
    if ($fi.Length -ne $ModelSize) { return $false }
    $stamp = "$($fi.Length) $($fi.LastWriteTimeUtc.Ticks)"
    if ((Test-Path -LiteralPath $mark) -and ((Get-Content -LiteralPath $mark -Raw).Trim() -eq $stamp)) { return $true }
    Write-Host "checking $ModelName (sha256)..."
    if ((Sha256File $model) -ne $ModelSha) { return $false }
    Set-Content -LiteralPath $mark -Value $stamp
    return $true
}
if (-not (ModelOk)) {
    $part = "$model.part"
    $done = $false
    foreach ($u in $ModelUrls) {
        Write-Host "downloading the model $ModelName (1.19 GB) from $u ..."
        Remove-Item -LiteralPath $part -ErrorAction SilentlyContinue
        $curl = Get-Command curl.exe -ErrorAction SilentlyContinue
        try {
            if ($curl) { & $curl.Source -L --fail --retry 3 -o $part $u; if ($LASTEXITCODE -ne 0) { throw "curl exit code $LASTEXITCODE" } }
            else { $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri $u -OutFile $part -UseBasicParsing }
            if ((Sha256File $part) -ne $ModelSha) { throw 'sha256 differs' }
            Move-Item -LiteralPath $part -Destination $model -Force
            $done = ModelOk
        } catch { Write-Host "  failed: $_" -ForegroundColor Yellow }
        if ($done) { break }
    }
    if (-not $done) { Fail "no model: download $ModelName (sha256 $ModelSha) by hand into $root" }
}

# arguments
$a = @()
foreach ($p in $pools) { $a += @('--pool', $p) }
$a += @('--user', "$Wallet.$Worker", '--model', $model)
if ($Password) { $a += @('--pass', $Password) }
if ($Devices) { $a += @('--devices', $Devices) }
$needAdmin = $false
if ($Mode) { $a += @('--mode', $Mode); $needAdmin = $true }
if ($AutoUv -eq '1') { $a += '--auto-uv'; $needAdmin = $true }
if ($UvOffset) { $a += @('--uv-offset', $UvOffset); $needAdmin = $true }
if ($UvMax) { $a += @('--uv-max', $UvMax) }
if ($UvMin) { $a += @('--uv-min', $UvMin) }
if ($LockCclock) { $a += @('--lock-cclock', $LockCclock); $needAdmin = $true }
if ($LockMclock) { $a += @('--lock-mclock', $LockMclock); $needAdmin = $true }
if ($Moffset) { $a += @('--moffset', $Moffset); $needAdmin = $true }
if ($Pl) { $a += @('--pl', $Pl); $needAdmin = $true }
if ($AutoLock -eq '1') { $a += '--auto-lock'; $needAdmin = $true }
if ($TempLimit) { $a += @('--temp-limit', $TempLimit) }
if ($Api) { $a += @('--api', $Api) }
if ($Extra) { $a += $Extra.Split(' ', [StringSplitOptions]::RemoveEmptyEntries) }
if ($needAdmin) {
    $id = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $id.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host 'WARNING: undervolt / clock settings need Administrator rights: right-click start.bat -> Run as administrator. Mining without them.' -ForegroundColor Yellow
    }
}
$env:CUDA_DEVICE_ORDER = 'PCI_BUS_ID'
$exe = Join-Path $root 'ffgv.exe'
# one-shot flags (--uv-reset / --uv-reset-all / --auto-lock-reset) only for the first start of this window
$oneShot = @('--uv-reset', '--uv-reset-all', '--auto-lock-reset')
while ($true) {
    Write-Host ('starting: ffgv.exe ' + (($a | ForEach-Object { if ($_ -match '\s') { "`"$_`"" } else { $_ } }) -join ' '))
    & $exe @a
    $code = $LASTEXITCODE
    if ($code -eq 2) { Fail 'the miner did not accept its arguments (see above): fix start.bat' }
    $a = @($a | Where-Object { $oneShot -notcontains $_ })
    Write-Host "ffgv.exe exited (code $code); restarting in 15 s (Ctrl+C to stop)" -ForegroundColor Yellow
    Start-Sleep -Seconds 15
}
