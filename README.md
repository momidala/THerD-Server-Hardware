# THerD-Server-Hardware

Hardware platform and deployment documentation for THerD-Server.

## Overview

This repository documents the hardware requirements, deployment configurations, and infrastructure setup for running THerD-Server - the backend infrastructure for the THerD AR Platform.

THerD-Server handles:
- World package uploads from artists
- Gravity script compilation to bytecode
- World distribution to AR clients
- Real-time multi-user state synchronization
- Optional RTK GPS correction broadcasting

## Documentation

- **[Hardware Requirements](docs/HARDWARE_REQUIREMENTS.md)** - Platform specifications, supported hardware, capacity planning
- **[RTK Setup Guide](docs/RTK_SETUP.md)** *(coming soon)* - GPS base station configuration
- **[Deployment Guide](docs/DEPLOYMENT.md)** *(coming soon)* - Step-by-step deployment instructions
- **[Configuration Templates](config/)** *(coming soon)* - Server configuration examples

## Quick Start

### Minimum Requirements

- **Platform:** Raspberry Pi 5 (8GB) or x86_64 Linux server
- **OS:** Ubuntu 22.04 LTS or newer
- **Storage:** 64GB+ (SSD recommended)
- **Network:** 10+ Mbps connection
- **Ports:** 8080/TCP (HTTP), 8081/TCP (WebSocket)

### Supported Platforms

1. **Raspberry Pi 5** - Recommended for development, small deployments (1-10 users)
2. **x86_64 Linux Server** - Recommended for production (10+ users)
3. **Cloud VMs** - AWS, Azure, GCP, DigitalOcean (2+ cores, 4GB+ RAM)

### Optional Hardware

- **RTK Base Station** - u-blox ZED-F9P for centimeter-accurate GPS (outdoor AR experiences)

## Repository Structure

```
THerD-Server-Hardware/
├── README.md                         # This file
├── docs/
│   ├── HARDWARE_REQUIREMENTS.md     # Platform specifications
│   ├── RTK_SETUP.md                 # GPS base station setup (planned)
│   └── DEPLOYMENT.md                 # Deployment guide (planned)
├── config/
│   ├── server.toml.example          # Configuration template (planned)
│   └── therd-server.service         # Systemd service file (planned)
└── scripts/
    └── test-gps.sh                   # GPS verification script (planned)
```

## Related Repositories

- **[THerD-Server](https://github.com/momidala/THerD-Server)** - Server software (Rust implementation)
- **[THerD-platform](https://github.com/momidala/THerD-platform)** - Client platform (C/OpenGL ES)
- **[GravityAR](https://github.com/momidala/GravityAR)** - Scripting language and tooling

## Use Cases

### Development Server
- Local testing during AR experience creation
- Raspberry Pi 5 at artist's desk
- Single world, single developer workflow

### Small Deployment
- Community AR experience (1-10 concurrent users)
- Raspberry Pi 5 or small VPS
- Single location, single world

### Production Deployment
- Public AR experience (10-50+ concurrent users)
- x86_64 dedicated server or cloud VM
- Multi-user, high-traffic worlds
- RTK base station for outdoor experiences

## Status

**Current state:** Hardware requirements documented, deployment guides in progress.

**Deployment support:**
- Raspberry Pi 5: Documented
- x86_64 Linux: Documented
- Cloud platforms: General guidance provided
- RTK hardware: Optional configuration documented

## Contributing

This repository is part of the THerD Platform developed by Momidala Consulting, LLC.

## License

Documentation: CC-BY-4.0
Hardware specifications: Public domain (vendor-neutral)

---

**For server software installation and usage, see [THerD-Server](https://github.com/momidala/THerD-Server).**
