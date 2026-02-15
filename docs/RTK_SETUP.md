# RTK Base Station Setup Guide

Step-by-step guide to configure GPS receiver as RTK base station.

## Prerequisites

- u-blox ZED-F9P or compatible RTK GPS module
- Multi-band GNSS antenna with ground plane
- Clear sky view for survey-in
- Serial or USB connection to server

## Hardware Connection

**USB Connection (Recommended):**
1. Connect GPS module to server via USB
2. Module appears as `/dev/ttyUSB0` or `/dev/ttyACM0`
3. Check with: `ls -l /dev/ttyUSB* /dev/ttyACM*`

**UART Connection (Raspberry Pi):**
1. Connect GPS TX → Pi RX (GPIO 15)
2. Connect GPS RX → Pi TX (GPIO 14)
3. Connect GND → GND
4. Enable UART in `/boot/config.txt`: `enable_uart=1`
5. Disable serial console: `sudo raspi-config` → Interfacing → Serial
6. Module appears as `/dev/ttyAMA0` or `/dev/serial0`

## Permissions

Add user to dialout group for serial access:

```bash
sudo usermod -a -G dialout $USER
# Log out and back in for group change to take effect
```

## GPS Module Configuration

### Using u-center (Windows)

1. Download u-center from u-blox website
2. Connect GPS module via USB
3. Open u-center, select COM port, 115200 baud
4. Configure base station mode:
   - View → Messages View
   - UBX → CFG → TMODE3
   - Mode: Survey-in
   - Minimum duration: 300 seconds
   - Position accuracy limit: 2.0 meters
   - Send
5. Enable RTCM3 output:
   - UBX → CFG → MSG
   - Enable RTCM3 messages: 1005, 1077, 1087, 1097, 1127, 1230
   - Output on UART1 at 1Hz
   - Send each
6. Save configuration:
   - UBX → CFG → CFG
   - Save current configuration
   - Send

### Using pyubx2 (Linux)

Install pyubx2:
```bash
pip3 install pyubx2
```

Configure via Python script:
```python
from serial import Serial
from pyubx2 import UBXMessage, SET

port = "/dev/ttyUSB0"
baud = 115200

with Serial(port, baud, timeout=3) as serial:
    # Set survey-in mode
    msg = UBXMessage('CFG', 'CFG-TMODE3', SET,
                     mode=1,  # Survey-in
                     svinMinDur=300,  # 300 seconds
                     svinAccLimit=20000)  # 2.0m in 0.1mm units
    serial.write(msg.serialize())

    # Enable RTCM3 messages
    for msgid in [1005, 1077, 1087, 1097, 1127, 1230]:
        msg = UBXMessage('CFG', 'CFG-MSGOUT-RTCM_3X_{:04d}_USB'.format(msgid), SET, rate=1)
        serial.write(msg.serialize())

    # Save configuration
    msg = UBXMessage('CFG', 'CFG-CFG', SET, saveMask=0xFFFF, devMask=0x01)
    serial.write(msg.serialize())
```

## Survey-In Process

**Start Survey:**
1. Position antenna with clear sky view
2. Power on GPS module
3. Module enters survey-in mode automatically
4. Monitor with: `cat /dev/ttyUSB0` (will show NMEA + RTCM3 binary)

**Survey Requirements:**
- Duration: 300 seconds minimum (5 minutes)
- Accuracy: < 2 meters 3D position error
- Fix type: 3D fix during survey

**Monitor Progress:**
Use u-center or check UBX-NAV-SVIN messages:
- Valid flag indicates survey complete
- meanAcc shows position accuracy in cm

**Typical Survey Time:**
- 5-15 minutes for 2m accuracy
- 30-60 minutes for 1m accuracy
- Longer survey = better base position

## Verification

Test GPS output:

```bash
# Raw serial output (NMEA + RTCM3)
cat /dev/ttyUSB0

# Should see:
# - $GNGGA NMEA sentences (position)
# - Binary RTCM3 frames (corrections)
```

Use provided test script:
```bash
cd /path/to/THerD-Server-Hardware
./scripts/test-gps.sh /dev/ttyUSB0
```

Expected output:
```
Testing GPS on /dev/ttyUSB0...
Found NMEA sentences: OK
Found RTCM3 frames: OK
Fix quality: 4 (RTK fixed) or 5 (RTK float)
Survey-in: Complete
GPS receiver ready for base station operation
```

## Troubleshooting

**No output on serial port:**
- Check USB connection
- Verify device path: `ls -l /dev/ttyUSB* /dev/ttyACM*`
- Check permissions: `groups` should include `dialout`

**Survey-in not completing:**
- Ensure clear sky view (no buildings, trees)
- Check antenna connection
- Extend minimum survey duration (600s)

**Fix quality stuck at 1 (single):**
- Antenna not connected or faulty
- No satellite visibility
- Module not configured for multi-band

**Binary garbage in output:**
- Normal - RTCM3 is binary mixed with NMEA text
- THerD-Server demultiplexes automatically

## Configuration for THerD-Server

Update `server.toml`:

```toml
[base_station]
enabled = true
device = "/dev/ttyUSB0"
baud_rate = 115200
```

Restart server:
```bash
sudo systemctl restart therd-server
```

Check logs:
```bash
sudo journalctl -u therd-server -f
# Should see: "RTK base station connected"
# Should see: "Broadcasting RTK correction" messages
```

## Next Steps

See [Deployment Guide](DEPLOYMENT.md) for complete server setup.
