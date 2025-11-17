# Raspberry Pi USB-C Network Gadget

> This configuration transforms the Raspberry Pi into a USB-C network device. Upon connection to an iPad or computer, the host device recognizes a 'USB Ethernet' adapter and automatically obtains an IP address assigned by the Raspberry Pi. This enables access to the Raspberry Pi for SSH, SFTP, and Web services. If necessary, the Raspberry Pi can also use Network Address Translation (NAT) to reverse-share the host device's network connection, achieving bidirectional communication
>
> Currently, testing confirms support for the Raspberry Pi 4 and 5. This functionality is available in Raspberry Pi OS (Raspbian) 12 and Ubuntu 24.04.

## 🚀Quick Start
---

### 1. Install dnsmasq
##### Run the following commands to update the package list and install dnsmasq:
```bash
sudo apt update
sudo apt install dnsmasq
```


### 2. Modify System Configuration
##### Modify the kernel command line parameters:
```bash
sudo vim /boot/firmware/cmdline.txt
```
##### Append the following text to the end of the existing single line:
```bash
modules-load=dwc2
```
**Note**: Ensure all content remains on a ***single line***.

##### Next, modify the modules file to load the necessary kernel modules upon boot:
```bash
sudo vim /etc/modules
```
##### Add the following two lines at the end:
```bash
dwc2
libcomposite
```


### 3. Create the USB Gadget Initialization Script
##### First, verify or load the necessary kernel module:
```bash
cd /sys/kernel/config/
# Check for the presence of the usb_gadget directory.
# If usb_gadget directory is NOT present, execute the following:
sudo modprobe libcomposite
```
##### Create and populate the script file:
```bash
cd /usr/local/bin/
sudo nano usb_gadget.sh
```
##### Copy the contents of the project's ***usb_gadget.sh*** file into this new file, and save it.

##### Add execution permissions to the script:
```bash
sudo chmod +x /usr/local/bin/usb_gadget.sh
```


### 4. Create and Enable the Startup Service
##### Create the systemd service file:
```bash
cd /etc/systemd/system/
sudo nano usb-gadget.service
```
##### Copy the contents of the project's ***usb-gadget.service*** file into this new file, and save it.

##### Load the new service unit, enable it to start on boot, and start it immediately:
```bash
sudo systemctl daemon-reload
sudo systemctl enable usb-gadget.service
sudo systemctl start usb-gadget.service
```


### 5. Configure DHCP Service
##### Create the DHCP configuration file for the USB Ethernet interface:
```bash
cd /etc/dnsmasq.d/
sudo nano usb0.conf
```
##### Copy the contents of the project's ***usb0.conf*** file into this new file, and save it.

##### Restart the dnsmasq service to apply the new configuration:
```bash
sudo systemctl restart dnsmasq
```
