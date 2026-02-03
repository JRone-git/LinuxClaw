# 🐧 Terminal Interpreter Skill

A lightweight Linux-native companion skill for **OpenClaw Gateway** that enables command execution, file management, and interactive terminal sessions on Linux systems.

> **Note:** Unlike the macOS/iOS/Android companion apps which provide voice wake, talk mode, and native UI integration, this skill is a **terminal-based** companion that uses OpenClaw's built-in `bash` and `process` tools.

## What is this?

OpenClaw Gateway supports Linux (as documented in the [Quickstart Guide](https://docs.openclaw.com/quickstart)), but there's no standalone "Linux Companion App" like there is for macOS. This skill bridges that gap by leveraging OpenClaw's existing tool infrastructure to provide:

- ✅ Shell command execution
- ✅ Interactive PTY sessions (for TUI apps like vim, htop, etc.)
- ✅ Background process management
- ✅ File operations and monitoring
- ✅ System information gathering

## Quick Start

```bash
# System info
bash command:"./scripts/sysinfo.sh --quick"

# Interactive file manager
bash pty:true command:"ranger"

# Monitor a log file
bash background:true command:"./scripts/file-watcher.sh /var/log/syslog 30"

# Run a development server
bash background:true workdir:~/myapp command:"npm run dev"
```

## Directory Structure

```
terminal-interpreter/
├── SKILL.md                    # Skill definition and documentation
├── README.md                   # This file
├── scripts/
│   ├── sysinfo.sh             # System information collector
│   └── file-watcher.sh        # Real-time file monitoring
└── examples/
    └── demo.sh                # Interactive demo (coming soon)
```

## Core Capabilities

### 1. Shell Execution

```bash
# Simple command
bash command:"uptime"

# With working directory
bash workdir:/var/log command:"ls -lah"

# Timeout protection
bash command:"sleep 10" timeout:5
```

### 2. Interactive PTY Sessions

For tools that need a pseudo-terminal:

```bash
# Text editor
bash pty:true command:"nano ~/.bashrc"

# System monitor
bash pty:true command:"btop"

# Git TUI
bash pty:true command:"lazygit"
```

### 3. Background Processes

```bash
# Start in background
bash background:true command:"python3 -m http.server 8080"
# Returns: sessionId (save this!)

# Check status
process action:poll sessionId:XXX

# View output
process action:log sessionId:XXX

# Send input
process action:submit sessionId:XXX data:"help"

# Kill process
process action:kill sessionId:XXX
```

### 4. File Operations

```bash
# Read files
bash command:"cat /etc/os-release"

# Search
bash command:"grep -r 'pattern' /path/to/search"

# Archive
bash command:"tar czf backup.tar.gz ~/important-files"

# Disk usage
bash command:"ncdu /var/log"
```

## Helper Scripts

### `sysinfo.sh` - System Information

```bash
# Quick overview
./scripts/sysinfo.sh --quick

# Full report
./scripts/sysinfo.sh

# JSON output (for automation)
./scripts/sysinfo.sh --json
```

### `file-watcher.sh` - File Monitoring

```bash
# Watch last 50 lines (default)
./scripts/file-watcher.sh /var/log/nginx/access.log

# Watch last 100 lines
./scripts/file-watcher.sh /var/log/nginx/access.log 100
```

## Comparison with macOS Companion

| Feature | macOS Companion | Terminal Interpreter |
|---------|-----------------|---------------------|
| Voice Wake | ✅ Native "Hey OpenClaw" | ❌ Not available |
| Talk Mode | ✅ Native | ❌ Text-only |
| File Access | ✅ Full filesystem | ✅ Full access via bash |
| Screen Capture | ✅ Native | ❌ Not available |
| Audio | ✅ Microphone/Speakers | ❌ Not available |
| Camera | ✅ Native | ❌ Not available |
| Interactive CLI | ✅ Terminal.app | ✅ PTY support |
| Process Control | ✅ | ✅ Background + process tool |
| System Integration | ✅ Menu bar | ⚠️ Via systemd/scripts |

## Use Cases

### 1. Self-Hosted OpenClaw Gateway Management

```bash
# Check gateway status
bash command:"systemctl --user status openclaw-gateway"

# View logs
bash command:"journalctl --user -u openclaw-gateway -f"

# Update gateway
bash command:"npm install -g openclaw@latest && systemctl --user restart openclaw-gateway"
```

### 2. Development Workflows

```bash
# Run tests
bash workdir:~/myproject command:"npm test"

# Git operations
bash workdir:~/myproject command:"git status && git log --oneline -10"

# Build project
bash background:true workdir:~/myproject command:"npm run build"
```

### 3. System Monitoring

```bash
# Monitor resources
bash background:true command:"watch -n 5 'df -h && free -h'"

# Watch logs
bash background:true command:"tail -f /var/log/syslog"

# Check services
bash command:"systemctl --failed"
```

### 4. Automation Tasks

```bash
# Scheduled backup
bash command:"tar czf ~/backups/config-$(date +%Y%m%d).tar.gz ~/.config"

# Cleanup
bash command:"find ~/Downloads -mtime +30 -delete"

# Update packages
bash command:"sudo apt update && apt list --upgradable"
```

## Integration with OpenClaw Gateway

When OpenClaw Gateway detects it's running on Linux, it can use this skill to:

1. **Self-diagnose**: Check its own health, logs, resource usage
2. **File operations**: Read/write configuration, access logs
3. **Process management**: Restart services, manage workers
4. **System automation**: Scheduled tasks, cleanup jobs
5. **Development**: Run build scripts, tests, deployments

## Installation

1. Clone or copy this skill to your OpenClaw skills directory:

```bash
cp -r terminal-interpreter ~/.config/openclaw/skills/
```

2. Ensure the scripts are executable:

```bash
chmod +x ~/.config/openclaw/skills/terminal-interpreter/scripts/*.sh
```

3. OpenClaw Gateway will auto-discover the skill on restart

## Configuration

No configuration required. The skill uses OpenClaw's built-in `bash` and `process` tools which are already available when running on Linux.

## Security Notes

- Commands run within OpenClaw's sandbox by default
- Use `elevated:true` for host-level access (if gateway allows)
- Be careful with destructive operations (`rm -rf`, `dd`, etc.)
- Sensitive data should use environment variables, not command arguments

## Future Enhancements

Potential additions to bring this closer to feature parity with native companion apps:

- [ ] Clipboard integration (`xclip`/`xsel`)
- [ ] Screenshot capability (`scrot`/`maim`)
- [ ] Audio recording (`arecord`/`parec`)
- [ ] Desktop notifications (`notify-send`)
- [ ] Polkit integration for privilege escalation
- [ ] D-Bus integration for desktop events

## Contributing

This skill is part of the OpenClaw ecosystem. To contribute:

1. Test on different Linux distributions
2. Add more helper scripts for common tasks
3. Improve error handling and edge cases
4. Document additional use cases

## License

MIT - Same as OpenClaw Gateway

---

**Questions?** Check the [OpenClaw Documentation](https://docs.openclaw.com) or the main `SKILL.md` file for detailed usage examples.