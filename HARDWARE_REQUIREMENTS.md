# THerD Server Hardware Requirements

This document specifies the hardware platform and requirements for running THerD-Server.

## Overview

THerD-Server is the backend infrastructure for THerD AR Platform. It handles world uploads, compilation, distribution, and real-time multi-user state synchronization. The server can be deployed on various Linux platforms, from single-board computers to cloud VMs.

## Supported Platforms

### Recommended: Raspberry Pi 5 (8GB)

**Why:** Same hardware as client platform enables local development/testing. Sufficient performance for small deployments (1-10 concurrent users).

**Specifications:**
- **CPU:** Broadcom BCM2712 (Quad-core Cortex-A76 @ 2.4GHz)
- **RAM:** 8GB LPDDR4X
- **Storage:** 64GB+ microSD card or NVMe SSD (via HAT)
- **Network:** Gigabit Ethernet or Wi-Fi 6 (802.11ax)
- **Power:** USB-C 5V/5A (27W power supply)

**Use cases:**
- Local development server
- Small-scale deployments
- Single AR experience hosting
- Educational/demonstration environments

### Production: x86_64 Linux Server

**Why:** Higher performance, better scalability, standard cloud infrastructure.

**Minimum specifications:**
- **CPU:** 2 cores (4 recommended)
- **RAM:** 4GB (8GB+ recommended)
- **Storage:** 20GB disk space (SSD recommended)
- **Network:** 100Mbps+ connection
- **OS:** Ubuntu 22.04 LTS or newer, Debian 12+, or equivalent

**Recommended specifications (10-50 concurrent users):**
- **CPU:** 4-8 cores
- **RAM:** 16GB
- **Storage:** 100GB SSD
- **Network:** 1Gbps+ connection

**Use cases:**
- Production deployments
- Multi-user experiences
- High-traffic worlds
- Cloud hosting (AWS, Azure, GCP, DigitalOcean)

## Optional Hardware: RTK Base Station

THerD-Server can optionally broadcast RTK corrections for centimeter-accurate GPS positioning.

**Hardware:**
- **GNSS Receiver:** u-blox ZED-F9P or compatible
- **Antenna:** Survey-grade GNSS antenna with ground plane
- **Interface:** USB connection to server
- **Mounting:** Fixed position with clear sky view

**When needed:**
- Outdoor AR experiences requiring high-precision GPS
- Multi-user outdoor worlds with shared GPS anchor system

**When NOT needed:**
- Indoor-only AR experiences (AprilTag SLAM)
- Single-user experiences
- GPS precision tolerance > 1 meter

## Storage Requirements

### Base Installation
- **Binary:** ~5MB (THerD-Server executable)
- **Dependencies:** ~50MB (Rust runtime, system libraries)
- **Total:** ~60MB

### Runtime Data
- **Per world package:** 1-50MB typical (scripts, models, textures, audio)
- **Compiled bytecode cache:** ~5-20% of source size
- **Database:** ~1MB per 1000 worlds (metadata only)
- **Logs:** Variable (configure rotation)

**Capacity planning:**
- Small deployment (1-10 worlds): 1GB storage
- Medium deployment (10-100 worlds): 10GB storage
- Large deployment (100+ worlds): 50GB+ storage

## Network Requirements

### Bandwidth

**Per client connection:**
- **World download:** One-time 1-50MB (package size)
- **WebSocket handshake:** ~1KB initial
- **State sync:** 1-10KB/second sustained (depends on scene complexity)
- **RTK corrections (if enabled):** ~1KB/second sustained

**Example calculations:**
- 10 concurrent users: ~100KB/sec sustained = 0.8 Mbps
- 50 concurrent users: ~500KB/sec sustained = 4 Mbps
- 100 concurrent users: ~1MB/sec sustained = 8 Mbps

**Recommended:**
- Small deployment: 10 Mbps upload
- Medium deployment: 50 Mbps upload
- Large deployment: 100+ Mbps upload

### Latency

**Target:** <100ms round-trip time to clients

**Why:** Real-time state synchronization requires low latency for responsive multi-user interactions.

**Considerations:**
- Clients connect via WebSocket (persistent connection)
- Geographic proximity affects latency
- Consider edge deployment for global reach

### Ports

**Required open ports:**
- **8080/TCP:** HTTP API (world upload/download)
- **8081/TCP:** WebSocket (real-time state sync)

**Optional:**
- **443/TCP:** HTTPS (if using TLS termination)
- **Custom ports:** Configurable via server.toml

**Firewall:**
- Allow inbound connections on configured ports
- No outbound restrictions needed (except RTK NTRIP if used)

## Power Requirements

### Raspberry Pi 5
- **Idle:** 3-4W
- **Active (serving clients):** 8-12W
- **Power supply:** 27W USB-C (official recommendation)
- **UPS:** Optional for continuous uptime

### x86_64 Server
- **Varies by hardware**
- **Cloud VMs:** No power management needed
- **Bare metal:** Plan for UPS in production

## Environmental Requirements

### Operating Temperature

**Raspberry Pi 5:**
- **Operating range:** 0°C to 50°C (32°F to 122°F)
- **Recommended:** 15°C to 35°C (59°F to 95°F)
- **Cooling:** Passive heatsink or active fan recommended under sustained load

**x86_64 Server:**
- **Depends on hardware**
- **Data center standard:** 18°C to 27°C (64°F to 81°F)

### Location

**For RTK base station:**
- Fixed position with clear sky view
- Minimal obstructions above 10° elevation
- Away from RF interference sources
- Vibration-free mounting

**For server only (no RTK):**
- Standard indoor environment
- Network connectivity
- No special requirements

## Software Dependencies

### Operating System

**Raspberry Pi 5:**
- Raspberry Pi OS (64-bit) - Latest version
- Ubuntu 22.04 LTS or newer for ARM64

**x86_64:**
- Ubuntu 22.04 LTS or newer
- Debian 12+
- RHEL 9+ / Rocky Linux 9+
- Arch Linux (rolling)

### Runtime Dependencies

**Required:**
- `glibc` 2.31+ or `musl`
- `libssl` (OpenSSL 1.1.1+ or 3.x)
- `libwebsockets` (included in binary or system package)

**Optional:**
- `gravity` compiler (for source-to-bytecode compilation)
- `systemd` (for service management)

**Installation:**
```bash
# Ubuntu/Debian
sudo apt install libssl3

# RHEL/Rocky
sudo dnf install openssl-libs
```

## Performance Characteristics

### CPU Usage

**Idle:** 1-2% (one core)
**Per client:** ~2-5% (depends on scene complexity)
**Compilation:** Spikes to 100% one core per compilation

**Bottleneck:** Gravity compilation is CPU-bound. Consider pre-compiling worlds if deployment load is high.

### Memory Usage

**Base:** ~50MB (server process)
**Per client:** ~1-2MB (WebSocket connection + state)
**World cache:** ~10-50MB (loaded worlds in memory)

**Example:**
- 10 clients: ~80MB total
- 50 clients: ~200MB total
- 100 clients: ~350MB total

### Disk I/O

**Read-heavy workload:**
- World downloads (one-time per client)
- Bytecode cache reads

**Write operations:**
- World uploads (infrequent)
- Bytecode cache writes (after compilation)
- Database updates (minimal)

**SSD recommended** for production (faster world loading).

## Deployment Topologies

### Single Server

**Architecture:**
- One server instance
- All clients connect to same server
- Shared state synchronization

**Use cases:**
- Single AR experience
- Development/testing
- Small deployments

### Multi-Server (Future)

**Not currently supported.** Future architecture may include:
- Load balancing across multiple servers
- Geographic distribution
- Horizontal scaling

**Current limitation:** One world per server instance. Deploy multiple server instances for multiple simultaneous worlds.

## Security Considerations

### Network Security

**Recommended:**
- Place server behind firewall
- Use HTTPS/WSS in production (TLS termination)
- Rate limiting at network edge
- DDoS protection for public-facing deployments

**Current state:**
- Server supports plain HTTP/WebSocket
- TLS termination via reverse proxy (nginx, Caddy)

### Physical Security

**For RTK base station:**
- Fixed position integrity matters for accuracy
- Tampering detection recommended
- Secure mounting

## Upgrade Path

### Raspberry Pi 5 → Production Server

When outgrowing Pi 5:
1. Export world packages from Pi
2. Set up x86_64 server
3. Upload worlds to new server
4. Update client configurations
5. Migrate RTK base station connection (if used)

**Data migration:** World packages are portable (same format across platforms).

## Summary

**Minimum viable deployment:**
- Raspberry Pi 5 (8GB) or equivalent x86_64 VM
- 64GB storage
- 10 Mbps network connection
- Ubuntu/Debian Linux

**Production deployment:**
- x86_64 server (4+ cores, 16GB RAM)
- 100GB SSD storage
- 100+ Mbps network connection
- UPS, monitoring, backups

**RTK-enabled deployment:**
- Add u-blox ZED-F9P base station
- Fixed position with sky view
- USB connection to server

---

**Related documentation:**
- Deployment guide: `DEPLOYMENT.md`
- Configuration reference: `CONFIGURATION.md`
- Installation instructions: `INSTALLATION.md`
