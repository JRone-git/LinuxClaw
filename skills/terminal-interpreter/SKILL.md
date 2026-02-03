---
name: terminal-interpreter
description: Execute shell commands, manage files, and run interactive terminal sessions on Linux - a lightweight local companion for OpenClaw Gateway.
metadata:
  {
    "openclaw": {
      "emoji": "🐧",
      "os": ["linux"],
      "requires": { "bins": ["bash", "python3"] }
    }
  }
---

# Terminal Interpreter Skill (Linux Companion)

A lightweight Linux-native companion that brings core OpenClaw capabilities to Linux servers without needing the full macOS/iOS/Android companion apps. This skill enables the Gateway to execute commands, manage files, and interact with the Linux system directly.

## Quickstart

```bash
# Run a simple command and get output
bash command:"uname -a && df -h"

# Execute in specific directory
bash workdir:~/projects command:"ls -la"

# Interactive session with PTY (for editors, TUI apps)
bash pty:true command:"htop"
```

## Core Capabilities

### 1. Shell Command Execution

```bash
# One-shot command
bash command:"apt list --upgradable"

# With timeout
bash command:"sleep 5 && echo done" timeout:10

# Background process
bash background:true command:"python3 -m http.server 8080"
# Returns sessionId for monitoring
```

### 2. Interactive Terminal Sessions (PTY)

For interactive CLI tools:

```bash
# Text editor
bash pty:true command:"nano /tmp/notes.txt"

# File manager
bash pty:true command:"ranger"

# System monitor
bash pty:true command:"btop"

# Any TUI application
bash pty:true command:"tig" workdir:~/Projects/openclaw
```

### 3. File Operations

```bash
# Read file content
bash command:"cat /var/log/syslog | tail -50"

# Write to file
bash command:"echo 'config setting' > ~/.myapp/config"

# List directory
bash command:"ls -lah /etc/nginx/"

# Search files
bash command:"find /var/log -name '*.log' -mtime -1"

# File statistics
bash command:"du -sh ~/* 2>/dev/null | sort -h"
```

### 4. System Information

```bash
# Hardware info
bash command:"lscpu | grep -E 'Model name|CPU\(s\)' && free -h"

# Disk usage
bash command:"df -h | grep -E 'Filesystem|/dev/'"

# Network status
bash command:"ip addr show && ss -tulpn"

# Running processes
bash command:"ps aux --sort=-%mem | head -20"

# Service status
bash command:"systemctl --failed"

# Check for updates
bash command:"apt update -qq && apt list --upgradable 2>/dev/null | wc -l"
```

### 5. Process Management

```bash
# Start long-running service
bash background:true command:"node server.js" workdir:~/myapp

# Monitor via process tool
process action:list
process action:log sessionId:XXX
process action:poll sessionId:XXX

# Send input to running process
process action:submit sessionId:XXX data:"restart"

# Kill process
process action:kill sessionId:XXX
```

### 6. Package Management

```bash
# Check installed packages
bash command:"dpkg -l | grep -i docker"

# Install (if user approves)
bash command:"sudo apt install -y htop ranger"

# Search packages
bash command:"apt search 'python3-' | grep '^python3-' | head -20"
```

## Advanced Patterns

### Real-time Log Monitoring

```bash
# Start background log watcher
bash background:true command:"tail -f /var/log/nginx/access.log"

# Later: check output
process action:log sessionId:XXX limit:50
```

### Multi-step Workflows

```bash
# Example: Deploy workflow
bash command:"cd ~/app && git pull origin main"
bash command:"cd ~/app && npm ci"
bash command:"cd ~/app && npm run build"
bash command:"sudo systemctl restart myapp"
```

### Session Persistence with tmux

For long-running interactive sessions that survive disconnects:

```bash
# Create named tmux session
bash command:"tmux new-session -d -s openclaw-dev -n editor"

# Attach vim to it
bash command:"tmux send-keys -t openclaw-dev:0 'cd ~/project && vim' Enter"

# Later: re-attach from any terminal
bash command:"tmux attach -t openclaw-dev"
```

### Script Execution

```bash
# Create and run a script
bash command:"cat > /tmp/backup.sh << 'EOF'
#!/bin/bash
tar czf ~/backup-$(date +%Y%m%d).tar.gz ~/important-data
EOF && chmod +x /tmp/backup.sh && /tmp/backup.sh"
```

## Security Considerations

- **Sandbox mode**: By default, commands run in OpenClaw's sandbox
- **Elevated mode**: Use `elevated:true` for host-level access (if gateway allows)
- **Sensitive data**: Avoid logging secrets; use environment variables
- **Destructive operations**: Always confirm with user before `rm -rf`, `dd`, etc.

## Integration with Gateway

This skill acts as a bridge - the Gateway running on Linux can use these tools to:

1. **Self-host maintenance**: Update itself, check logs, restart services
2. **File management**: Read/write configs, logs, data files
3. **Monitoring**: Check system health, resource usage
4. **Automation**: Cron-like scheduled tasks via scheduled threads
5. **Development**: Run build scripts, test commands, git operations

## Common Tasks

### Update OpenClaw Gateway

```bash
# Check for updates
bash command:"npm outdated -g openclaw"

# Update
bash command:"npm install -g openclaw@latest"

# Restart service
bash command:"systemctl --user restart openclaw-gateway"
```

### Check Gateway Health

```bash
# Check if running
bash command:"systemctl --user status openclaw-gateway"

# View recent logs
bash command:"journalctl --user -u openclaw-gateway -n 50 --no-pager"

# Check resource usage
bash command:"ps aux | grep -E 'PID|openclaw'"
```

### Manage Configuration

```bash
# View config
bash command:"cat ~/.config/openclaw/config.json | jq ."

# Edit config
bash command:"nano ~/.config/openclaw/config.json"
```

## Comparison: Terminal vs macOS Companion

| Feature | macOS Companion | Terminal Interpreter |
|---------|----------------|---------------------|
| **Voice Wake** | ✅ Native | ❌ Requires external trigger |
| **Talk Mode** | ✅ Native | ❌ Text-only |
| **File Access** | ✅ Full access | ✅ Full access via bash |
| **Screen/Audio** | ✅ Native capture | ❌ Not available |
| **Camera** | ✅ Native | ❌ Not available |
| **Code Execution** | ✅ Via skills | ✅ Via skills |
| **Interactive CLI** | ✅ Terminal.app | ✅ PTY support |
| **Process Control** | ✅ | ✅ Background + process tool |
| **System Integration** | ✅ Menu bar | ⚠️ Via systemd/User scripts |

## Roadmap

Future enhancements:
- [ ] WebSocket streaming for real-time output
- [ ] Clipboard integration (xclip/xsel)
- [ ] Screenshot capability (scrot/maim)
- [ ] Audio recording (arecord/parec)
- [ ] Notification integration (notify-send)
- [ ] Polkit integration for privilege escalation