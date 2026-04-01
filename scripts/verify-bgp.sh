#!/bin/bash
# verify-bgp.sh
# BGP state check across all fabric nodes from Jump-Monitor.
# Usage: bash verify-bgp.sh
S1="192.168.100.1"; S2="192.168.100.2"
L1="192.168.100.11"; L2="192.168.100.12"

ssh_cmd() {
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes \
        cisco@$1 "$2" 2>/dev/null || echo "  [unreachable - is node up?]"
}

echo "=================================================="
echo " HPC/AI Lab BGP Verification"
echo "=================================================="
echo ""

for N in "Spine-1:$S1" "Spine-2:$S2" "Leaf-1:$L1" "Leaf-2:$L2"; do
    NAME="${N%%:*}"; IP="${N##*:}"
    echo "--- $NAME ($IP) ---"
    ssh_cmd $IP "show bgp summary | begin Neighbor"
    echo ""
done

echo "=== ECMP verification ==="
echo "Leaf-1 paths to Spine-1 loopback (expect 2 paths):"
ssh_cmd $L1 "show ip bgp 10.255.0.1/32 | include paths"
echo ""
echo "Spine-1 paths to Leaf-1 loopback (expect 2 paths):"
ssh_cmd $S1 "show ip bgp 10.255.1.1/32 | include paths"
