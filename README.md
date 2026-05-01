# lock_setting

A lightweight tool to lock system configurations on Linux (GNOME/dconf). 
Designed to prevent unauthorized or accidental changes to critical settings.

## Features
- **Network Lock**: Disable modification of wired network settings.
- **Easy Deployment**: Run directly from GitHub via a one-liner command.
- **Multilingual Support**: Scripts available in Japanese and English.

## Structure
- `/jp`: Japanese version of scripts and documentation.
- `/en`: English version of scripts and documentation.

## Quick Start
To use the English version:
```bash
curl -s [https://raw.githubusercontent.com/appipinopi/lock_setting/main/en/lock_network.sh](https://raw.githubusercontent.com/appipinopi/lock_setting/main/en/lock_network.sh) | bash
