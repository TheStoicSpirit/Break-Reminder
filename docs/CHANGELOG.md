# Changelog

All notable changes to Break Reminder. Format based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

- Activity detection
- Break tracking & statistics
- Cross-platform support
- Sound notifications
- Multiple profiles

## [1.0.0] - 2025-11-16

**Initial public release**

### Features
- 50+ motivational break messages
- Modern PowerShell GUI with custom styling
- Configurable break actions (sleep/lock/hibernate/shutdown)
- Configuration file support (config.ini)
- Automatic logging system
- Custom icon support
- Fully portable with relative paths
- No terminal window when scheduled
- Draggable borderless window
- Complete documentation

### Technical
- Standalone PowerShell script (no .bat required)
- WPF-based GUI with modern design
- Proper error handling and fallbacks
- Task Scheduler ready

---

## Updating

1. Download latest release
2. Backup `data/messages.txt` and `data/config.ini` (if customized)
3. Extract and replace files
4. Restore your backups

---

[Unreleased]: https://github.com/TheStoicSpirit/Break-Reminder/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/TheStoicSpirit/Break-Reminder/releases/tag/v1.0.0