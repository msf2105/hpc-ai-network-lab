#!/bin/bash
# setup-jump.sh - run inside Jump-Monitor
set -e
ip addr add 192.168.100.100/24 dev eth0 2>/dev/null || true
ip link set eth0 up
ip route add default via 192.168.100.254 2>/dev/null || true
echo "nameserver 8.8.8.8" > /etc/resolv.conf
sed -i 's|mirrors.tuna.tsinghua.edu.cn|archive.ubuntu.com|g' /etc/apt/sources.list 2>/dev/null || true
apt-get update -q
apt-get install -y curl wget net-tools nmap tcpdump iperf3 python3
echo "Jump-Monitor 192.168.100.100 ready."
