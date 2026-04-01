#!/bin/bash
# setup-compute.sh - run inside Compute-1 or Compute-2
# Usage: sudo bash setup-compute.sh <1|2>
set -e
NODE_NUM=${1:?Usage: $0 <1|2>}
if   [[ "$NODE_NUM" == "1" ]]; then
    FABRIC_IP="10.1.1.1"; ROCE_IP="10.100.0.1"; MGMT_IP="192.168.100.21"; GW="10.1.1.0"
elif [[ "$NODE_NUM" == "2" ]]; then
    FABRIC_IP="10.1.2.1"; ROCE_IP="10.100.0.2"; MGMT_IP="192.168.100.22"; GW="10.1.2.0"
else echo "Node must be 1 or 2"; exit 1; fi

echo "=== Compute-${NODE_NUM} setup ==="
ip addr add ${FABRIC_IP}/31 dev eth0 2>/dev/null || true; ip link set eth0 up
ip addr add ${ROCE_IP}/24  dev eth1 2>/dev/null || true; ip link set eth1 up
ip addr add ${MGMT_IP}/24  dev eth2 2>/dev/null || true; ip link set eth2 up
ip route add default via 192.168.100.254 2>/dev/null || true
echo "nameserver 8.8.8.8" > /etc/resolv.conf
sed -i 's|mirrors.tuna.tsinghua.edu.cn|archive.ubuntu.com|g' /etc/apt/sources.list 2>/dev/null || true

apt-get update -q
apt-get install -y rdma-core ibverbs-utils perftest iproute2 tcpdump iperf3

modprobe rdma_rxe
echo "rdma_rxe" >> /etc/modules-load.d/roce.conf
rdma link add rxe0 type rxe netdev eth1 2>/dev/null || true

tc qdisc del dev eth1 root 2>/dev/null || true
tc qdisc add dev eth1 root handle 1: prio bands 3 priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
tc filter add dev eth1 parent 1: protocol ip prio 1 u32 \
    match ip protocol 17 0xff match ip dport 4791 0xffff \
    action dsfield set 0x28

cat > /etc/rc.local << 'EOF'
#!/bin/bash
modprobe rdma_rxe; sleep 2
rdma link add rxe0 type rxe netdev eth1 2>/dev/null || true
exit 0
EOF
chmod +x /etc/rc.local

echo "=== Done ===" ; rdma link show
