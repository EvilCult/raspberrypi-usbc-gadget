#!/usr/bin/env bash
set -e

# Check root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (use: sudo bash setup.sh)" >&2
    exit 1
fi

echo "[0] Disable systemd-resolved DNS stub listener..."
if systemctl is-active --quiet systemd-resolved; then
    if ! grep -q "^DNSStubListener=no" /etc/systemd/resolved.conf; then
        sed -i 's/^#\?DNSStubListener=.*/DNSStubListener=no/' /etc/systemd/resolved.conf
        # If the line doesn't exist, append it
        grep -q "^DNSStubListener=no" /etc/systemd/resolved.conf || \
            echo "DNSStubListener=no" >> /etc/systemd/resolved.conf
        systemctl restart systemd-resolved
        echo "Disabled DNS stub listener"
    else
        echo "Already disabled, skipping"
    fi
else
    echo "systemd-resolved not active, skipping"
fi

echo "[1] Install dnsmasq..."
apt update -y
apt install -y dnsmasq

echo "[2] Modify /boot/firmware/cmdline.txt..."
CMDLINE="/boot/firmware/cmdline.txt"
if ! grep -q "modules-load=dwc2" "$CMDLINE"; then
    echo "Appending modules-load=dwc2..."
    sed -i 's/$/ modules-load=dwc2/' "$CMDLINE"
else
    echo "Already exists, skipping"
fi

echo "[3] Modify /etc/modules..."
MODULES="/etc/modules"
grep -qxF "dwc2" "$MODULES" || echo "dwc2" >> "$MODULES"
grep -qxF "libcomposite" "$MODULES" || echo "libcomposite" >> "$MODULES"

echo "[4] Create usb_gadget.sh..."
mkdir -p /usr/local/bin
curl -sSL https://github.com/EvilCult/raspberrypi-usbc-gadget/raw/refs/heads/main/usb_gadget.sh -o /usr/local/bin/usb_gadget.sh
[ -s /usr/local/bin/usb_gadget.sh ] || { echo "Error: Failed to download usb_gadget.sh"; exit 1; }
chmod +x /usr/local/bin/usb_gadget.sh

echo "[5] Create systemd service..."
curl -sSL https://github.com/EvilCult/raspberrypi-usbc-gadget/raw/refs/heads/main/usb-gadget.service -o /etc/systemd/system/usb-gadget.service
[ -s /etc/systemd/system/usb-gadget.service ] || { echo "Error: Failed to download usb-gadget.service"; exit 1; }
systemctl daemon-reload
systemctl enable usb-gadget.service
systemctl start usb-gadget.service

echo "[6] Configure dnsmasq (usb0.conf)..."
mkdir -p /etc/dnsmasq.d
curl -sSL https://github.com/EvilCult/raspberrypi-usbc-gadget/raw/refs/heads/main/usb0.conf -o /etc/dnsmasq.d/usb0.conf
[ -s /etc/dnsmasq.d/usb0.conf ] || { echo "Error: Failed to download usb0.conf"; exit 1; }
systemctl restart dnsmasq

echo "Done! Please reboot!"