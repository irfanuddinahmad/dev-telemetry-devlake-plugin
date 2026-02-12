# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Batch telemetry endpoint for multiple developers
- Grafana dashboard templates
- VS Code extension example collector
- CLI tool for manual telemetry submission

## [0.1.0] - 2026-02-12

### Added
- Initial plugin implementation
- Connection management API with full CRUD operations
  - `POST /connections` - Create connection
  - `GET /connections` - List connections
  - `GET /connections/:id` - Get connection
  - `PATCH /connections/:id` - Update connection
  - `DELETE /connections/:id` - Delete connection
  - `POST /connections/:id/test` - Test connection
- Telemetry report webhook endpoint
  - `POST /connections/:id/report` - Submit telemetry data
- Developer metrics data model
  - Active hours tracking
  - Tools used (JSON array)
  - Command execution counts (JSON object)
  - Project context (JSON array)
  - Developer identification (email, name, hostname)
- Database schema with auto-migrations
  - `_tool_developer_telemetry_connections` table
  - `_tool_developer_metrics` table with composite primary key
- Idempotent update support (upsert on connection_id, developer_id, date)
- MySQL and PostgreSQL compatibility
- Secure token-based authentication (encrypted storage)
- Comprehensive documentation
  - README with feature overview and architecture
  - QUICKSTART guide for 5-minute setup
  - API reference documentation
  - Installation guide with multiple methods
- Build and release tooling
  - Makefile with common targets
  - Build scripts for DevLake integration
  - Release script for creating distribution packages
- License (Apache 2.0)
- GitHub setup documentation

### Features
- **Webhook-based ingestion**: Push model for local collectors to send data
- **Composite primary key**: Ensures one record per (connection, developer, date)
- **JSON field storage**: Flexible storage for arrays and maps as JSON strings
- **Idempotent updates**: Safe to resend data without creating duplicates
- **Connection isolation**: Multiple teams/projects via separate connections
- **Auto-migrations**: Database tables created automatically on startup

### Technical Details
- Built as Go plugin for DevLake (buildmode=plugin)
- Uses GORM ORM with DAL abstraction layer
- Implements DevLake plugin interfaces:
  - PluginMeta
  - PluginInit
  - PluginModel
  - PluginMigration
  - PluginApi
- Gin web framework for HTTP routing
- mapstructure for request decoding
- JSON marshaling for array/map fields

### Compatibility
- DevLake: v0.20.0 and later
- Go: 1.21 or later
- MySQL: 8.0 or later
- PostgreSQL: 13 or later

### Known Issues
- Authentication header reading not fully implemented (TODO in code)
- No rate limiting enforcement yet (field exists but not used)
- No batch submission endpoint (single developer per request)

### Documentation
- [README.md](README.md) - Overview and features
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [docs/API.md](docs/API.md) - API reference
- [docs/INSTALLATION.md](docs/INSTALLATION.md) - Installation guide
- [GITHUB_SETUP.md](GITHUB_SETUP.md) - GitHub repository setup
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contributing guidelines

### Build Artifacts
- `developer_telemetry.so` - Plugin binary (~27MB)
- `developer_telemetry.so.sha256` - Binary checksum

---

## Version History

[Unreleased]: https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/releases/tag/v0.1.0
