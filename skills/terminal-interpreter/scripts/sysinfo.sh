#!/bin/bash
# System information collector for OpenClaw Terminal Interpreter
# Usage: sysinfo.sh [--quick] [--json]

set -euo pipefail

MODE="${1:-default}"
OUTPUT_FORMAT="text"

if [[ "$MODE" == "--json" ]]; then
    OUTPUT_FORMAT="json"
fi

if [[ "$MODE" == "--quick" ]]; then
    # Quick overview
    echo "=== OpenClaw Linux System Quick Info ==="
    echo ""
    echo "Hostname: $(hostname)"
    echo "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo 'Unknown')"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime | awk -F',' '{print $1}')"
    echo ""
    echo "CPU: $(nproc) cores"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}' | xargs)"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2 " (" int($3/$2*100) "%)"}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    echo ""
    echo "OpenClaw Gateway: $(systemctl --user is-active openclaw-gateway 2>/dev/null || echo 'Not running')"
    exit 0
fi

if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    # JSON output for programmatic use
    cat <<EOF
{
    "hostname": "$(hostname)",
    "os": "$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo 'Unknown')",
    "kernel": "$(uname -r)",
    "architecture": "$(uname -m)",
    "uptime": "$(uptime -p 2>/dev/null || uptime | awk -F',' '{print $1}')",
    "cpu": {
        "cores": $(nproc),
        "model": "$(cat /proc/cpuinfo 2>/dev/null | grep 'model name' | head -1 | cut -d':' -f2 | xargs || echo 'Unknown')"
    },
    "memory": {
        "total": "$(free -h | awk '/^Mem:/ {print $2}')",
        "used": "$(free -h | awk '/^Mem:/ {print $3}')",
        "free": "$(free -h | awk '/^Mem:/ {print $4}')"
    },
    "disk": {
        "total": "$(df -h / | awk 'NR==2 {print $2}')",
        "used": "$(df -h / | awk 'NR==2 {print $3}')",
        "available": "$(df -h / | awk 'NR==2 {print $4}')"
    },
    "openclaw": {
        "gateway_status": "$(systemctl --user is-active openclaw-gateway 2>/dev/null || echo 'unknown')",
        "version": "$(openclaw --version 2>/dev/null || echo 'unknown')"
    }
}
EOF
    exit 0
fi

# Full text output
echo "=========================================="
echo "   OpenClaw Linux System Information"
echo "=========================================="
echo ""

echo "📊 SYSTEM"
echo "  Hostname:     $(hostname)"
echo "  OS:           $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo 'Unknown')"
echo "  Kernel:       $(uname -r)"
echo "  Architecture: $(uname -m)"
echo "  Uptime:       $(uptime -p 2>/dev/null || uptime | awk -F',' '{print $1}')"
echo ""

echo "💻 HARDWARE"
echo "  CPU:          $(nproc) cores - $(cat /proc/cpuinfo 2>/dev/null | grep 'model name' | head -1 | cut -d':' -f2 | xargs || echo 'Unknown')"
echo "  Memory:       $(free -h | awk '/^Mem:/ {printf "%s used / %s total (%s free)\n", $3, $2, $4}')"
echo "  Disk (/):     $(df -h / | awk 'NR==2 {printf "%s used / %s total (%s available, %s used)\n", $3, $2, $4, $5}')"
echo ""

echo "🌐 NETWORK"
echo "  Primary IP:   $(ip route get 1 2>/dev/null | awk '{print $7; exit}' || hostname -I | awk '{print $1}')"
ip addr show 2>/dev/null | grep "inet " | grep -v "127.0.0.1" | head -3 | while read line; do
    echo "                $line"
done
echo ""

echo "🔧 OPENCLAW"
echo "  Gateway:      $(systemctl --user is-active openclaw-gateway 2>/dev/null || echo 'Not installed/running')"
echo "  Version:      $(openclaw --version 2>/dev/null || echo 'Not installed')"
echo "  Config:       ${HOME}/.config/openclaw/config.json"
echo ""

echo "📦 TOP PROCESSES (by memory)"
ps aux --sort=-%mem 2>/dev/null | head -6 | tail -5 | while read user pid cpu mem vsz rss tty stat start time command; do
    printf "  %-8s %5s%% %s\n" "$command" "$mem" "$command"
done
echo ""

echo "=========================================="