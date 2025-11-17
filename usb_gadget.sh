#!/bin/bash
# RaspberryPi USB-C Gadget ECM network auto-configuration script

# Mount configfs
mountpoint -q /sys/kernel/config || sudo mount -t configfs none /sys/kernel/config

cd /sys/kernel/config/usb_gadget/

# Create Gadget
mkdir -p g1
cd g1

echo 0x1d6b > idVendor     # Linux Foundation
echo 0x0104 > idProduct    # Gadget CDC Ethernet

# USB Strings
mkdir -p strings/0x409
echo "RPiUsb001a" > strings/0x409/serialnumber      # Meaningless serial number, change it when you have multiple devices
echo "RaspberryPi" > strings/0x409/manufacturer 
echo "PI USB Ethernet" > strings/0x409/product     # This is what shows on iPad/Mac/PC

# Create configuration
mkdir -p configs/c.1
mkdir -p functions/ecm.usb0
ln -s functions/ecm.usb0 configs/c.1/

# Start Gadget
ls /sys/class/udc > UDC

# Configure USB interface IP
ip addr add 10.10.0.1/24 dev usb0
ip link set usb0 up

# Optional: NAT internet sharing (via wlan0)
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

# Optional: Restart dnsmasq to let iPad automatically obtain IP
systemctl restart dnsmasq