#!/bin/bash
# Test GPS receiver output

DEVICE="${1:-/dev/ttyUSB0}"
TIMEOUT=10

echo "Testing GPS on $DEVICE..."

if [ ! -e "$DEVICE" ]; then
    echo "ERROR: Device $DEVICE does not exist"
    exit 1
fi

if [ ! -r "$DEVICE" ]; then
    echo "ERROR: No read permission on $DEVICE"
    echo "Run: sudo usermod -a -G dialout $USER"
    exit 1
fi

# Read from device for TIMEOUT seconds
timeout $TIMEOUT cat "$DEVICE" > /tmp/gps-test.log 2>&1

# Check for NMEA sentences
if grep -q '$G.GGA' /tmp/gps-test.log; then
    echo "Found NMEA sentences: OK"
else
    echo "ERROR: No NMEA sentences found"
    exit 1
fi

# Check for RTCM3 (binary marker - 0xD3 byte)
if grep -qP '\xD3' /tmp/gps-test.log; then
    echo "Found RTCM3 frames: OK"
else
    echo "WARNING: No RTCM3 frames detected"
fi

# Parse fix quality from GGA sentence
QUALITY=$(grep '$G.GGA' /tmp/gps-test.log | tail -1 | cut -d',' -f7)
case "$QUALITY" in
    0) echo "Fix quality: 0 (no fix)" ;;
    1) echo "Fix quality: 1 (GPS single)" ;;
    2) echo "Fix quality: 2 (DGPS)" ;;
    4) echo "Fix quality: 4 (RTK fixed)" ;;
    5) echo "Fix quality: 5 (RTK float)" ;;
    *) echo "Fix quality: unknown ($QUALITY)" ;;
esac

echo "GPS receiver output verified"
rm /tmp/gps-test.log
