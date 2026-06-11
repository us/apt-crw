# CRW APT Repository

Debian/Ubuntu package repository for [CRW](https://github.com/us/crw) — the web scraper built for AI agents.

## Usage

```bash
# Add GPG key
curl -fsSL https://apt.fastcrw.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/crw.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/crw.gpg] https://apt.fastcrw.com stable main" | sudo tee /etc/apt/sources.list.d/crw.list

# Install
sudo apt update
sudo apt install crw        # CLI
sudo apt install crw-mcp    # MCP server
sudo apt install crw-server # API server
```

## Packages

| Package | Description |
|---|---|
| `crw` | Fast web scraper CLI — `crw example.com` |
| `crw-mcp` | MCP server for AI agents (Claude, Cursor, etc.) |
| `crw-server` | Firecrawl-compatible REST API server |

## How it works

This repository is automatically updated on each CRW release via GitHub Actions. The `.deb` packages are built from the release binaries and signed with GPG.
