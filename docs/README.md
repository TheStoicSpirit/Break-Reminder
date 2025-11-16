# Break Reminder 🧘‍♂️

Lightweight Windows utility for healthy work habits. Get periodic reminders to hydrate, stretch, walk, and rest your eyes.

![License](https://img.shields.io/badge/license-AGPL--3.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)
![PowerShell](https://img.shields.io/badge/powershell-5.1%2B-blue.svg)

## Features

- 120+ professional break messages
- Choose to take a break or skip
- Easy scheduling (hourly, custom intervals)
- Fully customizable
- Minimal resource usage
- Modern borderless UI

## Quick Start

**Requirements:** Windows 7+, PowerShell 5.1+ (pre-installed on Win10/11)

1. Download and extract
2. Run `src\main.ps1` to test
3. Schedule it (see below)

## Auto-Schedule Setup

**Task Scheduler:**
1. Open Task Scheduler → Create Basic Task
2. Set trigger: Daily, repeat every 1 hour
3. Action: Start `powershell.exe`
4. Arguments: `-WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\path\to\Break-Reminder\src\main.ps1"`
5. Enable "Run with highest privileges"

**No terminal window** - Runs silently in background

## Customize

**Messages:** Edit `data\messages.txt` (one per line)

**Settings:** Edit `data\config.ini`
```ini
BreakAction=sleep    # Options: sleep, lock, hibernate, shutdown
EnableLogging=true
```

## Structure

```
break-reminder/
├── src/main.ps1         # Main script
├── data/
│   ├── messages.txt     # Your messages
│   └── config.ini       # Settings
├── docs/                # Documentation
└── .github/             # Issue templates
```

## Troubleshooting

**Script won't run?**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**System won't sleep?** Check power settings and user permissions.

**Change frequency?** Edit Task Scheduler trigger interval.

## Contributing

Fork → Branch → PR. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

AGPL-3.0 - See [LICENSE](https://github.com/TheStoicSpirit/Break-Reminder?tab=AGPL-3.0-1-ov-file)

---

**Made with ❤️ for healthier work habits** | [Issues](https://github.com/TheStoicSpirit/Break-Reminder/issues) | [Contribute](docs/CONTRIBUTING.md)
