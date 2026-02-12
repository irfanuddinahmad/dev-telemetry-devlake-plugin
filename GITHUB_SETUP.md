# GitHub Setup Guide

This guide walks you through creating a GitHub repository and pushing your plugin.

## Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click the **+** icon in the top right → **New repository**
3. Fill in the details:
   - **Repository name**: `dev-telemetry-devlake-plugin`
   - **Description**: "Developer Telemetry Plugin for Apache DevLake - Track developer productivity metrics"
   - **Visibility**: Public or Private
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)
4. Click **Create repository**

## Step 2: Add Remote and Push

```bash
cd /Users/irfan.ahmad/arbisoft-src/dev-telemetry-devlake-plugin

# Add GitHub remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin.git

# Verify remote
git remote -v

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Configure Repository Settings

### 3.1 Update README

1. Go to your repository on GitHub
2. Edit `README.md`
3. Replace `YOUR_USERNAME` with your actual GitHub username in all URLs:
   - Release download URLs
   - Badge URLs
   - Issue tracker URLs
   - Discussions URLs

### 3.2 Add Topics

1. Go to repository page
2. Click the gear icon next to "About"
3. Add topics: `devlake`, `devlake-plugin`, `developer-metrics`, `productivity`, `telemetry`, `golang`

### 3.3 Enable Features

1. **Issues**: Settings → Features → Issues ✓
2. **Discussions**: Settings → Features → Discussions ✓
3. **Projects**: Optional

## Step 4: Create First Release

### 4.1 Build the Plugin Binary

```bash
# Navigate to DevLake installation
cd /path/to/devlake/backend

# Copy plugin source
cp -r /path/to/dev-telemetry-devlake-plugin/plugins/developer_telemetry plugins/

# Build
DEVLAKE_PLUGINS=developer_telemetry scripts/build-plugins.sh

# Verify build
ls -lh bin/plugins/developer_telemetry/developer_telemetry.so
```

### 4.2 Create Release Package

```bash
# Create release directory
mkdir -p releases/v0.1.0
cp bin/plugins/developer_telemetry/developer_telemetry.so releases/v0.1.0/

# Generate checksum
cd releases/v0.1.0
shasum -a 256 developer_telemetry.so > developer_telemetry.so.sha256

# View checksum
cat developer_telemetry.so.sha256
```

### 4.3 Create GitHub Release

1. Go to your repository on GitHub
2. Click **Releases** → **Create a new release**
3. Click **Choose a tag** → Type `v0.1.0` → **Create new tag**
4. **Release title**: `v0.1.0 - Initial Release`
5. **Description**:

```markdown
## Developer Telemetry Plugin v0.1.0

First stable release of the Developer Telemetry plugin for Apache DevLake.

### Features

- ✅ Webhook-based telemetry data ingestion
- ✅ Connection management with secure token authentication
- ✅ Developer metrics tracking (active hours, tools, commands, projects)
- ✅ Idempotent updates (upsert support)
- ✅ MySQL and PostgreSQL support
- ✅ Comprehensive API endpoints
- ✅ Auto-migrations on startup

### Installation

Download `developer_telemetry.so` and follow the [installation guide](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin#installation).

### What's New

- Initial plugin implementation
- Full CRUD operations for connections
- Telemetry report endpoint with authentication
- Composite primary key support (connection_id, developer_id, date)
- JSON field storage for arrays and maps

### Compatibility

- DevLake: v0.20.0+
- Go: 1.21+
- MySQL: 8.0+
- PostgreSQL: 13+

### Documentation

- [Quick Start Guide](QUICKSTART.md)
- [API Documentation](docs/API.md)
- [Installation Guide](docs/INSTALLATION.md)

### Checksums

See `developer_telemetry.so.sha256` for binary verification.
```

6. **Attach files**:
   - Drag and drop `developer_telemetry.so`
   - Drag and drop `developer_telemetry.so.sha256`

7. Click **Publish release**

## Step 5: Set Up GitHub Actions (Optional)

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      
      - name: golangci-lint
        uses: golangci/golangci-lint-action@v3
        with:
          version: latest
          args: --timeout=5m
          working-directory: plugins/developer_telemetry

  verify:
    name: Verify
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      
      - name: Verify formatting
        run: |
          gofmt -l plugins/developer_telemetry
          test -z "$(gofmt -l plugins/developer_telemetry)"
      
      - name: Verify go.mod
        run: |
          cd plugins/developer_telemetry
          go mod tidy
          git diff --exit-code go.mod go.sum
```

## Step 6: Add Badges to README

Update your README.md with dynamic badges:

```markdown
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?logo=go)](https://go.dev/)
[![GitHub release](https://img.shields.io/github/v/release/YOUR_USERNAME/dev-telemetry-devlake-plugin)](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/releases)
[![GitHub issues](https://img.shields.io/github/issues/YOUR_USERNAME/dev-telemetry-devlake-plugin)](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/issues)
[![GitHub stars](https://img.shields.io/github/stars/YOUR_USERNAME/dev-telemetry-devlake-plugin)](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/stargazers)
```

## Step 7: Create Contributing Guidelines

Create `CONTRIBUTING.md`:

```markdown
# Contributing to Developer Telemetry Plugin

Thank you for your interest in contributing!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin.git`
3. Create a branch: `git checkout -b feature/my-feature`
4. Make your changes
5. Test your changes
6. Commit: `git commit -m "Add my feature"`
7. Push: `git push origin feature/my-feature`
8. Create a Pull Request

## Development Setup

See [README.md](README.md#development) for setup instructions.

## Code Style

- Follow Go conventions
- Run `gofmt` before committing
- Add tests for new features
- Update documentation

## Pull Request Process

1. Update README.md if needed
2. Update CHANGELOG.md
3. Ensure all tests pass
4. Request review from maintainers

## Reporting Bugs

Use [GitHub Issues](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/issues) to report bugs.

Include:
- DevLake version
- Plugin version
- Steps to reproduce
- Expected vs actual behavior
- Error messages/logs

## Feature Requests

Use [GitHub Discussions](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/discussions) for feature requests.
```

## Step 8: Add License Information

Create `NOTICE` file:

```text
Developer Telemetry Plugin for Apache DevLake
Copyright 2026 Your Name

This product includes software developed at
The Apache Software Foundation (http://www.apache.org/).
```

## Step 9: Create Changelog

Create `CHANGELOG.md`:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-12

### Added
- Initial plugin implementation
- Connection management API (CRUD operations)
- Telemetry report webhook endpoint
- Developer metrics data model
- Database migrations for MySQL/PostgreSQL
- Idempotent update support
- Comprehensive documentation
- Build and release scripts

### Features
- Track active hours, tools used, command counts, project context
- Push-based webhook model
- Secure token-based authentication
- JSON storage for arrays and maps
- Composite primary key (connection_id, developer_id, date)

[0.1.0]: https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/releases/tag/v0.1.0
```

## Step 10: Final Commit and Push

```bash
cd /Users/irfan.ahmad/arbisoft-src/dev-telemetry-devlake-plugin

# Add new files
git add .github/workflows/ci.yml CONTRIBUTING.md NOTICE CHANGELOG.md

# Commit
git commit -m "Add GitHub workflows, contributing guidelines, and changelog"

# Push
git push origin main
```

## Verification Checklist

- [ ] Repository created on GitHub
- [ ] Code pushed to `main` branch
- [ ] README.md updated with correct username
- [ ] Topics added to repository
- [ ] First release created (v0.1.0)
- [ ] Binary and checksum attached to release
- [ ] Issues enabled
- [ ] Discussions enabled (optional)
- [ ] GitHub Actions workflow added (optional)
- [ ] Contributing guidelines added
- [ ] Changelog created
- [ ] License and Notice files present

## Next Steps

1. **Star your own repo** (to give it visibility)
2. **Share on social media** or relevant communities
3. **Write a blog post** about the plugin
4. **Create example collectors** (VS Code extension, CLI tool)
5. **Submit to DevLake plugin directory** (if exists)
6. **Monitor issues and discussions**
7. **Plan next release** with community feedback

## Need Help?

- DevLake Documentation: https://devlake.apache.org/
- DevLake GitHub: https://github.com/apache/incubator-devlake
- Your Plugin Issues: https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/issues

---

**Congratulations!** Your plugin is now open source and ready for the community! 🎉
