#!/bin/bash
# =========================================
# Script: Auto Setup Swap RAM (/swapfile only)
# OS Support: Ubuntu 20.04-25.04 & Debian 11-12
# Author: Ari Setiawan
# =========================================

clear
echo -e "\033[1;32m=== Auto Setup Swap RAM (/swapfile only) ===\033[0m"
echo

# Hapus semua swap lama (swapfile1, swapfile2, dll)
swapoff -a
sed -i '/swapfile/d' /etc/fstab
rm -f /swapfile*

# Kalau sudah ada /swapfile aktif, stop
if swapon --show | awk '{print $1}' | grep -qw "/swapfile"; then
    echo -e "\033[1;33mSwap sudah aktif di /swapfile.\033[0m"
    swapon --show | grep "/swapfile"
    exit 0
fi

# Kalau belum ada, bikin baru
read -p "Masukkan ukuran swap (contoh: 1G atau 2048M): " SWAP_SIZE

echo -e "\nMembuat swap file sebesar $SWAP_SIZE di /swapfile ..."
fallocate -l $SWAP_SIZE /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Tambahkan ke fstab biar permanen
if ! grep -qw "/swapfile" /etc/fstab; then
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Optimasi swappiness dan cache pressure
SYSCTL_CONF="/etc/sysctl.conf"
grep -q "vm.swappiness" $SYSCTL_CONF && \
    sed -i 's/^vm.swappiness.*/vm.swappiness=10/' $SYSCTL_CONF || \
    echo "vm.swappiness=10" >> $SYSCTL_CONF

grep -q "vm.vfs_cache_pressure" $SYSCTL_CONF && \
    sed -i 's/^vm.vfs_cache_pressure.*/vm.vfs_cache_pressure=50/' $SYSCTL_CONF || \
    echo "vm.vfs_cache_pressure=50" >> $SYSCTL_CONF

sysctl -p >/dev/null

echo -e "\n\033[1;32mSwap berhasil dibuat dan diaktifkan di /swapfile!\033[0m"
echo "---------------------------------"
swapon --show | grep "/swapfile"
free -h
echo "---------------------------------"
