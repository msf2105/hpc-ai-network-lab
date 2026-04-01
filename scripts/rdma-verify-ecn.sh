#!/bin/bash
# rdma-verify-ecn.sh
# Verify ECN CE marking on RDMA traffic while benchmark runs.
# Usage: bash rdma-verify-ecn.sh [interface] [duration_seconds]
IFACE=${1:-eth0}
SECS=${2:-15}
echo "=== ECN verification on $IFACE for ${SECS}s ==="
echo "Run rdma-benchmark.sh in another terminal first."
echo ""
echo "Capturing ECN CE-marked packets (ip[1] & 0x03 != 0):"
timeout $SECS tcpdump -i $IFACE -nn -v 'ip and (ip[1] & 0x03 != 0)' 2>/dev/null | head -50
echo ""
echo "=== Leaf switch verification commands ==="
echo "  show policy-map interface GigabitEthernet0/2"
echo "  show class-map CM-RDMA"
