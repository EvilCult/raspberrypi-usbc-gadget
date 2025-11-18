#!/usr/bin/env bash
set -e

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
chmod +x /usr/local/bin/usb_gadget.sh

echo "[5] Create systemd service..."
curl -sSL https://github.com/EvilCult/raspberrypi-usbc-gadget/raw/refs/heads/main/usb-gadget.service -o /etc/systemd/system/usb-gadget.service
systemctl daemon-reload
systemctl enable usb-gadget.service
systemctl restart usb-gadget.service

echo "[6] Configure dnsmasq (usb0.conf)..."
mkdir -p /etc/dnsmasq.d
curl -sSL https://github.com/EvilCult/raspberrypi-usbc-gadget/raw/refs/heads/main/usb0.conf -o /etc/dnsmasq.d/usb0.conf
systemctl restart dnsmasq

echo "Done! Please reboot!"