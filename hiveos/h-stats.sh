#!/usr/bin/env bash
# FreeForGem-VELA — see LICENSE
# Sourced by the HiveOS agent: sets $khs (total, in thousands of inferences/s) and $stats (JSON) from the miner's JSON API.
# Hashrate unit: 1 "hash" = 1 inference (one attempt; VELA difficulty is counted in inferences).
_ffgv_dir=$(dirname "${BASH_SOURCE[0]}")
. "$_ffgv_dir/h-manifest.conf"
_j=$(curl -s --max-time 2 "http://127.0.0.1:${FFGV_API_PORT}/" 2>/dev/null)
if [[ -z $_j ]] || ! jq -e .gpus >/dev/null 2>&1 <<< "$_j"; then
  khs=0
  stats=null
else
  mapfile -t _fan  < <(nvidia-smi --query-gpu=fan.speed --format=csv,noheader,nounits 2>/dev/null)
  _hs=(); _t=(); _f=(); _b=()
  while read -r d hs t bx; do
    _hs+=("$hs"); _t+=("${t:-0}")
    f=${_fan[$d]:-0}; [[ $f =~ ^[0-9]+$ ]] || f=0; _f+=("$f")
    _b+=("$(( 16#${bx:-0} ))")
  done < <(jq -r '.gpus[] | "\(.gpu) \(.inf_s) \((.temp_c // 0) | floor) \((.bus // "0:0") | split(":")[1])"' <<< "$_j")
  khs=$(jq -r '.total_inf_s / 1000' <<< "$_j")
  _w=$(jq -r '[.gpus[].power_w // 0] | add' <<< "$_j")
  # HiveOS shows this next to the miner version: "0.4.2 0.3010 inf/s/W" (rig efficiency), ", new 0.4.3" when the miner found a newer
  # release on GitHub (update.rs writes update-available next to ffgv; nothing is installed)
  _ver="$(jq -r .version <<< "$_j") $(awk -v t="$(jq -r .total_inf_s <<< "$_j")" -v w="$_w" 'BEGIN{ if (w>0) printf "%.4f inf/s/W", t/w }')"
  _ver=${_ver% }
  _new=; [[ -f $_ffgv_dir/update-available ]] && _new=$(tr -cd '0-9A-Za-z.' < "$_ffgv_dir/update-available" | head -c 20)
  [[ -n $_new ]] && _ver="$_ver, new $_new"
  stats=$(jq -nc \
    --argjson hs "$(printf '%s\n' "${_hs[@]}" | jq -sc .)" \
    --argjson temp "$(printf '%s\n' "${_t[@]}" | jq -sc .)" \
    --argjson fan "$(printf '%s\n' "${_f[@]}" | jq -sc .)" \
    --argjson bus "$(printf '%s\n' "${_b[@]}" | jq -sc .)" \
    --arg ver "$_ver" --arg algo "$CUSTOM_ALGO" \
    --argjson up "$(jq -r .uptime <<< "$_j")" --argjson acc "$(jq -r .accepted <<< "$_j")" --argjson rej "$(jq -r .rejected <<< "$_j")" \
    '{hs: $hs, hs_units: "hs", temp: $temp, fan: $fan, uptime: $up, ver: $ver, ar: [$acc, $rej], algo: $algo, bus_numbers: $bus}')
fi
