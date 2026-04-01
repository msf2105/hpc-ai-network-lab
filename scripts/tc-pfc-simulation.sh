#!/bin/bash
# tc-pfc-simulation.sh
# Simulates PFC priority isolation using Linux HTB.
# Hardware PFC (802.1Qbb) requires Arista/Mellanox ASICs.
# Usage: bash tc-pfc-simulation.sh [interface]
IFACE=${1:-eth1}
echo "=== PFC simulation on $IFACE ==="
tc qdisc del dev $IFACE root 2>/dev/null
tc qdisc add dev $IFACE root handle 1: htb default 30
# Priority 3 - RDMA/RoCEv2 (lossless, 60% BW)
tc class add dev $IFACE parent 1: classid 1:10 htb rate 600mbit ceil 900mbit burst 15k prio 1
# Priority 2 - Storage (30% BW)
tc class add dev $IFACE parent 1: classid 1:20 htb rate 300mbit ceil 600mbit burst 15k prio 2
# Priority 0 - Best-effort (remaining)
tc class add dev $IFACE parent 1: classid 1:30 htb rate 100mbit ceil 200mbit burst 15k prio 3
tc qdisc add dev $IFACE parent 1:10 handle 10: sfq perturb 10
tc qdisc add dev $IFACE parent 1:20 handle 20: sfq perturb 10
tc qdisc add dev $IFACE parent 1:30 handle 30: sfq perturb 10
# DSCP AF11 (RDMA) -> high priority
tc filter add dev $IFACE parent 1: protocol ip prio 1 u32 match ip tos 0x28 0xfc flowid 1:10
# DSCP CS2 (storage) -> medium priority
tc filter add dev $IFACE parent 1: protocol ip prio 2 u32 match ip tos 0x40 0xfc flowid 1:20
echo "Done. Priority queue stats:"
tc -s class show dev $IFACE
