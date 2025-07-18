#!/bin/bash

# Configuration
PROJECT_DIR="/home/vion/workspace_vion/thesis_ppv/dc_motor_tracker"
PI_USER="thesisppv"
PI_IP="192.168.193.241"
PI_PROJECT_DIR="/home/thesisppv/workspace_thesis/thesis_ppv/dc_motor_tracker"

set -e  # Exit on any error

echo "Building Flutter app..."
cd "$PROJECT_DIR"
flutterpi_tool build --arch=arm64 --cpu=pi3 --release

echo "Syncing to Raspberry Pi..."
rsync -a --info=progress2 ./build/flutter_assets/ "$PI_USER@$PI_IP:$PI_PROJECT_DIR"

echo "Deployment complete!"
echo "To run: ssh $PI_USER@$PI_IP 'flutter-pi --release $PI_PROJECT_DIR/'"

# Optional: Run immediately
read -p "Run now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ssh "$PI_USER@$PI_IP" "flutter-pi --release $PI_PROJECT_DIR/"
fi
