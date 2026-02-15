# THerD-Server Deployment Guide

Production deployment of THerD-Server with RTK base station.

## Prerequisites

- Server hardware (see [Hardware Requirements](HARDWARE_REQUIREMENTS.md))
- RTK base station configured (see [RTK Setup](RTK_SETUP.md))
- Ubuntu 24.04 LTS or Raspberry Pi OS
- Internet connection

## Install THerD-Server

### From Binary Release (Recommended)

```bash
# Download latest release
wget https://github.com/momidala/THerD-Server/releases/latest/download/therd-server-linux-$(uname -m).tar.gz

# Extract
tar xzf therd-server-linux-$(uname -m).tar.gz

# Install
sudo cp therd-server /usr/local/bin/
sudo chmod +x /usr/local/bin/therd-server
```

### From Source

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Clone repository
git clone https://github.com/momidala/THerD-Server.git
cd THerD-Server

# Build release
cargo build --release

# Install
sudo cp target/release/therd-server /usr/local/bin/
```

## Configuration

Create configuration directory:
```bash
sudo mkdir -p /etc/therd
sudo mkdir -p /var/lib/therd
```

Copy example configuration:
```bash
sudo cp config/server.toml.example /etc/therd/server.toml
```

Edit configuration:
```bash
sudo nano /etc/therd/server.toml
```

Key settings to review:
- `http.bind_address` - Network interface (0.0.0.0 for all, 127.0.0.1 for local only)
- `http.port` - HTTP port (default: 8080)
- `websocket.port` - WebSocket port (default: 8081)
- `base_station.device` - GPS serial device path
- `data.worlds_dir` - World package storage
- `data.bytecode_dir` - Compiled bytecode cache

## Systemd Service

Install service file:
```bash
sudo cp config/therd-server.service /etc/systemd/system/
sudo systemctl daemon-reload
```

Enable and start:
```bash
sudo systemctl enable therd-server
sudo systemctl start therd-server
```

Check status:
```bash
sudo systemctl status therd-server
```

## Firewall Configuration

Allow HTTP and WebSocket ports:

**UFW (Ubuntu):**
```bash
sudo ufw allow 8080/tcp comment 'THerD HTTP'
sudo ufw allow 8081/tcp comment 'THerD WebSocket'
sudo ufw enable
```

**firewalld (CentOS/RHEL):**
```bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
```

## Verification

Check server health:
```bash
curl http://localhost:8080/health
# Should return: {"status":"ok"}
```

Check logs:
```bash
sudo journalctl -u therd-server -f
```

Expected log messages:
```
INFO therd_server: Server starting on 0.0.0.0:8080
INFO therd_server: WebSocket listening on 0.0.0.0:8081
INFO therd_server: RTK base station connected: /dev/ttyUSB0
INFO therd_server: Data directory: /var/lib/therd
```

## Upload Test World

Create test world package:
```bash
# See gravityAR repository for therd-package tool
therd-package create /path/to/world/
```

Upload:
```bash
curl -X POST http://localhost:8080/world \
     -H "Content-Type: application/octet-stream" \
     --data-binary @test-world.therd
```

Verify upload:
```bash
curl http://localhost:8080/world/metadata
# Should return world metadata JSON
```

## Monitoring

**Resource Usage:**
```bash
# CPU and memory
top -p $(pgrep therd-server)

# Disk usage
du -sh /var/lib/therd
```

**Logs:**
```bash
# Follow logs in real-time
sudo journalctl -u therd-server -f

# Last 100 lines
sudo journalctl -u therd-server -n 100

# Errors only
sudo journalctl -u therd-server -p err
```

**RTK Health:**
- GPS fix quality in logs (4 or 5 = good)
- Position drift < 10m
- Correction broadcast rate ~1Hz

## Backup

Backup world packages and configuration:
```bash
sudo tar czf therd-backup-$(date +%Y%m%d).tar.gz \
     /etc/therd/server.toml \
     /var/lib/therd/
```

## Updates

Update server software:
```bash
# Download new release
wget https://github.com/momidala/THerD-Server/releases/latest/download/therd-server-linux-$(uname -m).tar.gz

# Stop service
sudo systemctl stop therd-server

# Backup current binary
sudo cp /usr/local/bin/therd-server /usr/local/bin/therd-server.backup

# Install new version
tar xzf therd-server-linux-$(uname -m).tar.gz
sudo cp therd-server /usr/local/bin/
sudo chmod +x /usr/local/bin/therd-server

# Restart service
sudo systemctl start therd-server

# Check logs
sudo journalctl -u therd-server -f
```

## Troubleshooting

**Server won't start:**
- Check logs: `sudo journalctl -u therd-server -n 50`
- Verify configuration: `/etc/therd/server.toml`
- Check permissions: `/var/lib/therd` owned by service user

**GPS not detected:**
- Verify device exists: `ls -l /dev/ttyUSB*`
- Check permissions: User in `dialout` group
- Test GPS directly: `cat /dev/ttyUSB0`

**Clients can't connect:**
- Verify firewall rules allow ports 8080, 8081
- Check bind address in config (0.0.0.0 vs 127.0.0.1)
- Test locally first: `curl http://localhost:8080/health`

**High CPU usage:**
- Check number of connected clients (logs)
- Verify world package size (large assets increase load)
- Monitor with: `top -p $(pgrep therd-server)`

## Production Hardening

**Security:**
- Use reverse proxy (nginx) for HTTPS
- Limit client connections in config
- Run as non-root user (systemd service default)
- Keep system and software updated

**Reliability:**
- Enable automatic restart in systemd service
- Set up monitoring (Prometheus, Grafana)
- Configure log rotation
- Regular backups

## Next Steps

- Configure HTTPS with nginx reverse proxy
- Set up monitoring and alerting
- Test with real AR hardware
- Deploy world packages from gravityAR tooling

See [THerD-Server documentation](https://github.com/momidala/THerD-Server) for API details.
