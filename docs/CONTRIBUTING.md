# Contributing

Thanks for helping improve Break Reminder! 🎉

## Quick Guidelines

**Be respectful** • **Be constructive** • **Be welcoming**

## How to Contribute

### Report Bugs
Check existing issues first, then create a new one with:
- Clear description
- Steps to reproduce
- Expected vs actual behavior
- Environment (OS, PowerShell version)

### Suggest Features
Open an issue describing:
- The problem it solves
- Proposed solution
- Why others would benefit

### Add Messages
1. Fork the repo
2. Edit `data/messages.txt`
3. Keep messages: positive, clear, appropriate, 5-80 chars
4. Submit PR

### Code Changes
1. Fork and create a branch: `git checkout -b feature/amazing-feature`
2. Make changes and test thoroughly
3. Commit: `git commit -m 'Add amazing feature'`
4. Push and open PR

## Code Style

**PowerShell:**
- PascalCase for functions
- camelCase for variables
- Add comments for complex logic

**Batch:**
- Use `%~dp0` for relative paths
- Add section comments
- Handle errors

## Testing Checklist
- [ ] Test on Windows 10/11
- [ ] Both buttons work
- [ ] Messages load correctly
- [ ] Config changes apply
- [ ] No PowerShell errors

## Versioning

[Semantic Versioning](https://semver.org/): MAJOR.MINOR.PATCH

## License

Contributions are licensed under AGPL-3.0.

## Questions?

Open an issue tagged `question` or comment on existing discussions.

---

**Happy Contributing! 🚀**