#!/bin/bash
# deploy-configs.sh - run on EVE-NG HOST after placing the .unl
# Usage: sudo bash deploy-configs.sh
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_PATH=$(find /opt/unetlab/labs -name "hpc-ai-network-lab.unl" 2>/dev/null | head -1)
if [[ -z "$LAB_PATH" ]]; then
    echo "ERROR: hpc-ai-network-lab.unl not found under /opt/unetlab/labs"; exit 1
fi
LAB_FOLDER=$(dirname "$LAB_PATH")
echo "Lab folder: $LAB_FOLDER"
declare -A MAP=([2]="configs/Spine-1.txt" [3]="configs/Spine-2.txt" [4]="configs/Leaf-1.txt" [5]="configs/Leaf-2.txt")
for NODE_ID in "${!MAP[@]}"; do
    SRC="$SCRIPT_DIR/${MAP[$NODE_ID]}"
    DEST="$LAB_FOLDER/$NODE_ID"
    [[ ! -f "$SRC" ]] && echo "  SKIP node $NODE_ID" && continue
    mkdir -p "$DEST"
    cp "$SRC" "$DEST/startup-config"
    echo "  Node $NODE_ID -> $DEST/startup-config [OK]"
done
sudo /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
echo "Done."
