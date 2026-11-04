#!/usr/bin/env bash
# FreeForGem-VELA — see LICENSE
cd "$(dirname "$0")"
. ./h-manifest.conf
[[ -f $CUSTOM_CONFIG_FILENAME ]] || { echo "No config file $CUSTOM_CONFIG_FILENAME"; exit 1; }
mkdir -p "$(dirname "$CUSTOM_LOG_BASENAME")"
# undervolt profiles, GPU fault records and the crash-recovery files live in /hive-config (survive miner updates and reboots)
[[ -d /hive-config ]] && export FFGV_STATE_DIR=${FFGV_STATE_DIR:-/hive-config/ffgv}
# GPU numbering in PCI bus order, the same as nvidia-smi and the HiveOS dashboard
export CUDA_DEVICE_ORDER=PCI_BUS_ID
[[ -z ${NO_COLOR:-} ]] && export FFG_COLOR=${FFG_COLOR:-1}

CFG="$(< "$CUSTOM_CONFIG_FILENAME")"

# Optional: install the CMP-unlock NVIDIA driver before mining when the flight sheet asks for it.
# NVIDIA CMP mining cards (50HX and the like) compute at about 1/32 under the stock driver; the unlock
# driver lifts that. To turn it on, add  --cmp-unlock-driver  to the flight-sheet field
# "Extra config arguments" (CUSTOM_USER_CONFIG); the same word without the dashes works too. It is NOT passed
# to the miner (it would stop with "unknown option"). `ffgv --cmp-driver`
# is idempotent and opt-in: on a rig that is not yet unlocked it verifies the pinned driver by SHA-256,
# installs it with the stock HiveOS nvidia-driver-update and reboots (mining starts on the next boot);
# on a rig already on the unlock driver, or without a CMP card / without root, it changes nothing and we
# keep mining on the current driver.
if [[ " $CFG " == *" --cmp-unlock-driver "* || " $CFG " == *" cmp-unlock-driver "* ]]; then
  CFG=" ${CFG} "
  CFG="${CFG// --cmp-unlock-driver / }"; CFG="${CFG// cmp-unlock-driver / }"   # drop the token from the miner arguments
  CFG="${CFG// --cmp-unlock-driver / }"; CFG="${CFG// cmp-unlock-driver / }"   # (twice: a repeated token shares its space)
  echo "ffgv: --cmp-unlock-driver requested — checking/installing the CMP-unlock driver"
  ./ffgv --cmp-driver || echo "ffgv: --cmp-driver returned $? — keeping the current driver, mining continues"
fi

# the model (1.19 GB, not in the package): one copy per rig in /hive/miners/custom/vela-model, checked by sha256
MODEL_DIR=/hive/miners/custom/vela-model
MODEL=$MODEL_DIR/sd-turbo-int.poisd
MODEL_SHA=ba38ab96b3398e22ea631d8a457350f91833e57463199d063663308513651f36
MODEL_URLS="https://huggingface.co/valereseach/vela-sd-turbo-int-v2/resolve/main/sd-turbo-int.poisd https://dl.ariabrain.com/vela-dl/sd-turbo-int.poisd"
mkdir -p "$MODEL_DIR"
if [[ ! -f $MODEL.ok ]] || [[ ! -f $MODEL ]]; then
  ok=0
  if [[ -f $MODEL ]] && [[ $(sha256sum "$MODEL" | cut -c1-64) == $MODEL_SHA ]]; then ok=1; fi
  for u in $MODEL_URLS; do
    [[ $ok == 1 ]] && break
    echo "ffgv: downloading the model (1.19 GB) from $u"
    rm -f "$MODEL.part"
    if wget -q --show-progress -O "$MODEL.part" "$u" && [[ $(sha256sum "$MODEL.part" | cut -c1-64) == $MODEL_SHA ]]; then
      mv -f "$MODEL.part" "$MODEL"; ok=1
    else
      echo "ffgv: download from $u failed or sha256 differs"
    fi
  done
  [[ $ok == 1 ]] || { echo "ffgv: no model - put sd-turbo-int.poisd (sha256 $MODEL_SHA) into $MODEL_DIR"; sleep 60; exit 1; }
  touch "$MODEL.ok"
fi

# tee -i: `miner stop` sends SIGINT to the whole pipeline; tee must outlive the miner so that its shutdown (the owner's
# offsets/clocks put back) is logged
./ffgv --model "$MODEL" --api-port "$FFGV_API_PORT" $CFG 2>&1 | tee -i --append "${CUSTOM_LOG_BASENAME}.log"
