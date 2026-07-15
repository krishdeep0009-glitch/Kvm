Center #!/bin/bash

# Clear the screen and show branding
clear
echo "======================================"
echo "      MADE BY CLOWNER KVM INSTALLER   "
echo "======================================"
echo "1) Install VM"
echo "0) Exit"
echo "--------------------------------------"
read -p "Type your choice: " MAIN_CHOICE

if [ "$MAIN_CHOICE" = "1" ]; then
    # Clean up old running instances
    echo "Cleaning up old QEMU processes..."
    sudo killall -9 qemu-system-x86_64 2>/dev/null
    
    # Set up directory
    mkdir -p ~/native-kvm
    cd ~/native-kvm
    
    # Ask user for custom resources
    echo ""
    read -p "Enter RAM size (e.g., 4G, 16G, 64G): " USER_RAM
    read -p "Enter number of CPU cores (e.g., 4, 16, 32): " USER_CORES
    read -p "Enter Disk size with unit (e.g., 500G, 1T): " USER_DISK
    echo ""
    
    # Configure the storage drive
    echo "Configuring environment..."
    if [ -f primary_disk.qcow2 ]; then 
        rm -f primary_disk.qcow2
    fi
    qemu-img create -f qcow2 primary_disk.qcow2 "$USER_DISK"
    
    # Wait for the download to finish if it's still running
    echo "Checking Ubuntu ISO download status..."
    while fuser ubuntu-24.04.4-live-server-amd64.iso >/dev/null 2>&1; do 
        sleep 2
    done
    
    # Launch the emulator
    echo "Starting VM with $USER_RAM RAM, $USER_CORES Cores, and $USER_DISK Disk..."
    sudo qemu-system-x86_64 \
      -m "$USER_RAM" \
      -smp "$USER_CORES" \
      -cpu EPYC \
      -drive file=primary_disk.qcow2,if=virtio,format=qcow2 \
      -cdrom ubuntu-24.04.4-live-server-amd64.iso \
      -boot d \
      -net nic,model=virtio -net user,hostfwd=tcp::8006-:8006 \
      -nographic \
      -vnc :1 &
      
    echo ""
    echo "=== Success! VM is booting ==="
    echo "Connect using a VNC Viewer at: Your_VPS_IP:5901"
else
    echo "Exiting installer. Goodbye!"
    exit 0
fi
