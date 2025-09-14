#!/bin/bash
# =========================================
# Script: Auto Setup Swap RAM
# OS Support: Ubuntu 20.04-25.04 & Debian 11-12
# Author: Ari Setiawan
# =========================================

clear
echo -e "\033[1;32m=== Auto Setup Swap RAM ===\033[0m"
echo

# Cek apakah ada swap aktif
if swapon --show | grep -q "/swapfile"; then
    echo -e "\033[1;33mSwap sudah aktif di /swapfile.\033[0m"
    swapon --show
    exit 0
fi

# Kalau file ada tapi belum aktif
if [ -f /swapfile ]; then
    echo -e "\033[1;33mFile /swapfile ditemukan tapi belum aktif, mengaktifkan...\033[0m"
    chmod 600 /swapfile
    mkswap /swapfile >/dev/null 2>&1
    swapon /swapfile
    if ! grep -q "/swapfile" /etc/fstab; then
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi
    echo -e "\033[1;32mSwap berhasil diaktifkan!\033[0m"
    swapon --show
    exit 0
fi

# Minta ukuran swap
read -p "Masukkan ukuran swap (contoh: 1G atau 2048M): " SWAP_SIZE

# Buat swapfile baru
echo -e "\nMembuat swap file sebesar $SWAP_SIZE ..."
fallocate -l $SWAP_SIZE /swapfile

# Set izin file
chmod 600 /swapfile

# Format swap
mkswap /swapfile

# Aktifkan swap
swapon /swapfile

# Tambahkan ke fstab biar permanen
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Optimasi swappiness dan cache pressure
SYSCTL_CONF="/etc/sysctl.conf"
if ! grep -q "vm.swappiness" $SYSCTL_CONF; then
    echo "vm.swappiness=10" >> $SYSCTL_CONF
fi
if ! grep -q "vm.vfs_cache_pressure" $SYSCTL_CONF; then
    echo "vm.vfs_cache_pressure=50" >> $SYSCTL_CONF
fi
sysctl -p >/dev/null

echo -e "\n\033[1;32mSwap berhasil dibuat dan diaktifkan!\033[0m"
echo "---------------------------------"
swapon --show
free -h
echo "---------------------------------"
