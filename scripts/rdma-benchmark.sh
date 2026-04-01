#!/bin/bash
# rdma-benchmark.sh
# Full RDMA benchmark suite: write BW, send BW, read BW, write latency.
#
# Compute-1 (server): bash rdma-benchmark.sh server
# Compute-2 (client): bash rdma-benchmark.sh client
MODE=${1:-server}
SERVER_IP="10.100.0.1"
DEV="rxe0"

echo "=== RDMA Benchmark Suite ==="
echo "Device: $DEV | Mode: $MODE"
echo ""

run_bw() {
    local T=$1 D=$2
    echo "--- $D ---"
    if [[ "$MODE" == "server" ]]; then
        $T -d $DEV -i 1 -F --report_gbits
    else
        sleep 1; $T -d $DEV -i 1 -F --report_gbits $SERVER_IP
    fi
    echo ""
}

run_bw ib_write_bw "Write BW (GPU-Direct RDMA / gradient sync)"
run_bw ib_send_bw  "Send BW (MPI Allreduce pattern)"
run_bw ib_read_bw  "Read BW (parameter server pull)"

echo "--- Write Latency (gradient sync critical path) ---"
if [[ "$MODE" == "server" ]]; then
    ib_write_lat -d $DEV -i 1 -F
else
    sleep 1; ib_write_lat -d $DEV -i 1 -F $SERVER_IP
fi
