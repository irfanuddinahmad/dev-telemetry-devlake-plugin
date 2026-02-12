# Developer Telemetry Plugin for Apache DevLake

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?logo=go)](https://go.dev/)

A DevLake plugin for collecting developer telemetry data from local development environments. This plugin enables teams to track developer productivity metrics, tool usage, and activity patterns.

## Features

- 📊 **Developer Metrics Collection**: Track active hours, tools used, and project context
- 📝 **Command Usage Tracking**: Monitor command execution patterns
- 🔄 **Webhook-Based Ingestion**: Push telemetry data from local collectors
- 🔌 **Native DevLake Plugin**: Seamless integration with Apache DevLake
- 💾 **Idempotent Updates**: Safe to send duplicate data without errors
- 🔐 **Connection Management**: Secure token-based authentication support

## Architecture

This plugin follows a **push-based webhook model** where local telemetry collectors send data to DevLake:

```
┌─────────────────┐        HTTP POST         ┌──────────────────┐
│  Local Collector│  ───────────────────────> │  DevLake Plugin  │
│  (VS Code, CLI) │  /connections/1/report    │                  │
└─────────────────┘                           └──────────────────┘
                                                       │
                                                       v
                                              ┌─────────────────┐
                                              │   MySQL/Postgres │
                                              │   _tool_developer│
                                              │     _metrics     │
                                              └─────────────────┘
```

## Installation

> ⚠️ **IMPORTANT**: The pre-built binary is NOT included in the git repository. You must either:
> - Download it from [GitHub Releases](https://github.com/irfanuddinahmad/dev-telemetry-devlake-plugin/releases), OR
> - Build from within the DevLake monorepo (building from this standalone repo will fail)

> ⚠️ **VERSION COMPATIBILITY**: Pre-built binaries are version-specific to DevLake. If you get a version mismatch error, you must rebuild against your DevLake version.

### Option 1: Use Pre-built Binary (Recommended)

```bash
# Download from GitHub releases
wget https://github.com/irfanuddinahmad/dev-telemetry-devlake-plugin/releases/latest/download/developer_telemetry.so

# Copy to DevLake plugins directory
mkdir -p /path/to/devlake/backend/bin/plugins/developer_telemetry/
cp developer_telemetry.so /path/to/devlake/backend/bin/plugins/developer_telemetry/

# Restart DevLake with plugin enabled
cd /path/to/devlake/backend
export DEVLAKE_PLUGINS=developer_telemetry
./bin/lake
```

### Option 2: Build from DevLake Monorepo

> ⚠️ **Note**: Building from this standalone repository will fail. The plugin requires DevLake's internal packages.

```bash
# Navigate to your DevLake installation
cd /path/to/your/devlake/backend

# Copy plugin source to DevLake
cp -r /path/to/dev-telemetry-devlake-plugin/plugins/developer_telemetry plugins/

# Build the plugin
DEVLAKE_PLUGINS=developer_telemetry make build-plugin
# Or use the build script:
DEVLAKE_PLUGINS=developer_telemetry scripts/build-plugins.sh

# Start DevLake with the plugin
export DEVLAKE_PLUGINS=developer_telemetry
./bin/lake
```

## Quick Start

### 1. Create a Connection

```bash
curl -X POST http://localhost:8080/plugins/developer_telemetry/connections \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Development Team",
    "endpoint": "http://localhost:8080",
    "secretToken": "your-secret-token-here"
  }'
```

Response:
```json
{
  "id": 1,
  "name": "Development Team",
  "endpoint": "http://localhost:8080",
  "createdAt": "2026-02-12T10:00:00Z"
}
```

### 2. Send Telemetry Data

```bash
curl -X POST http://localhost:8080/plugins/developer_telemetry/connections/1/report \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-secret-token-here" \
  -d '{
    "date": "2026-02-12",
    "developer": "john.doe",
    "email": "john@company.com",
    "name": "John Doe",
    "hostname": "john-laptop",
    "metrics": {
      "active_hours": 8,
      "tools_used": ["vscode", "git", "docker"],
      "commands": {
        "git": 45,
        "docker": 12,
        "npm": 23
      },
      "projects": ["backend-api", "frontend-app"]
    }
  }'
```

Response:
```json
{
  "success": true,
  "message": "telemetry data received successfully"
}
```

### 3. Query the Data

```sql
-- Get developer activity summary
SELECT 
  developer_id,
  date,
  active_hours,
  tools_used,
  project_context
FROM _tool_developer_metrics
WHERE date >= '2026-02-01'
ORDER BY date DESC;

-- Get command usage statistics
SELECT 
  developer_id,
  date,
  command_counts
FROM _tool_developer_metrics
WHERE date = '2026-02-12';
```

## Data Schema

### Connection Table: `_tool_developer_telemetry_connections`

| Column | Type | Description |
|--------|------|-------------|
| id | BIGINT | Primary key |
| name | VARCHAR(100) | Connection name |
| endpoint | VARCHAR(255) | DevLake endpoint URL |
| secret_token | TEXT | Authentication token (encrypted) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### Metrics Table: `_tool_developer_metrics`

| Column | Type | Description |
|--------|------|-------------|
| connection_id | BIGINT | Foreign key to connection |
| developer_id | VARCHAR(255) | Developer identifier (e.g., username) |
| date | DATE | Metrics date |
| email | VARCHAR(255) | Developer email |
| name | VARCHAR(255) | Developer full name |
| hostname | VARCHAR(255) | Workstation hostname |
| active_hours | BIGINT | Hours actively coding |
| tools_used | TEXT | JSON array of tools (e.g., `["vscode","git"]`) |
| project_context | TEXT | JSON array of projects |
| command_counts | TEXT | JSON object of command counts |
| os_info | VARCHAR(255) | Operating system information |
| created_at | TIMESTAMP | Record creation time |
| updated_at | TIMESTAMP | Last update time |

**Composite Primary Key**: `(connection_id, developer_id, date)`

## API Endpoints

### Connection Management

- `POST /plugins/developer_telemetry/connections` - Create connection
- `GET /plugins/developer_telemetry/connections` - List connections
- `GET /plugins/developer_telemetry/connections/:id` - Get connection
- `PATCH /plugins/developer_telemetry/connections/:id` - Update connection
- `DELETE /plugins/developer_telemetry/connections/:id` - Delete connection
- `POST /plugins/developer_telemetry/connections/:id/test` - Test connection

### Telemetry Ingestion

- `POST /plugins/developer_telemetry/connections/:id/report` - Submit telemetry data

## Local Collector Integration

You can build local collectors to automatically send telemetry data:

### Example: Python Collector

```python
import requests
import json
from datetime import date

def send_telemetry(connection_id, token):
    data = {
        "date": str(date.today()),
        "developer": "john.doe",
        "email": "john@company.com",
        "name": "John Doe",
        "hostname": "john-laptop",
        "metrics": {
            "active_hours": 8,
            "tools_used": ["python", "vscode", "git"],
            "commands": {"python": 50, "git": 30},
            "projects": ["data-pipeline"]
        }
    }
    
    response = requests.post(
        f"http://localhost:8080/plugins/developer_telemetry/connections/{connection_id}/report",
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {token}"
        },
        json=data
    )
    return response.json()
```

### Example: Shell Script Collector

```bash
#!/bin/bash

CONNECTION_ID=1
TOKEN="your-secret-token"
DEVELOPER=$(whoami)
HOSTNAME=$(hostname)

curl -X POST "http://localhost:8080/plugins/developer_telemetry/connections/${CONNECTION_ID}/report" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d "{
    \"date\": \"$(date +%Y-%m-%d)\",
    \"developer\": \"${DEVELOPER}\",
    \"email\": \"${DEVELOPER}@company.com\",
    \"name\": \"Developer Name\",
    \"hostname\": \"${HOSTNAME}\",
    \"metrics\": {
      \"active_hours\": 8,
      \"tools_used\": [\"git\", \"vim\"],
      \"commands\": {\"git\": 25},
      \"projects\": [\"my-project\"]
    }
  }"
```

## Development

### Prerequisites

- Go 1.21+
- Access to Apache DevLake source code
- MySQL 8.0+ or PostgreSQL 13+

### Building

```bash
# From your DevLake backend directory
cd /path/to/devlake/backend

# Copy plugin source
cp -r /path/to/dev-telemetry-devlake-plugin/plugins/developer_telemetry plugins/

# Build
DEVLAKE_PLUGINS=developer_telemetry scripts/build-plugins.sh
```

### Testing

```bash
# Start MySQL
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mysql:8.0

# Start DevLake with test database
DB_URL="mysql://root:password@127.0.0.1:3306/devlake_test?charset=utf8mb4&parseTime=True" \
PORT=8080 \
PLUGIN_DIR=bin/plugins \
DEVLAKE_PLUGINS=developer_telemetry \
./bin/lake

# Run tests
go test ./plugins/developer_telemetry/...
```

## Troubleshooting

### Version Mismatch Error

```
plugin was built with a different version of package github.com/apache/incubator-devlake/core/config
```

**Solution**: Rebuild the plugin from within your DevLake installation (see Option 2 above).

### Plugin Not Loading

Check that:
1. The `.so` file is in the correct directory: `bin/plugins/developer_telemetry/`
2. The `DEVLAKE_PLUGINS` environment variable includes `developer_telemetry`
3. File permissions allow execution: `chmod +x bin/plugins/developer_telemetry/developer_telemetry.so`

### Database Migration Errors

If migrations fail:
```bash
# Drop and recreate the database
docker exec -it mysql-container mysql -uroot -ppassword -e "DROP DATABASE devlake_test; CREATE DATABASE devlake_test;"

# Restart DevLake to run migrations again
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built for [Apache DevLake](https://github.com/apache/incubator-devlake)
- Inspired by DORA metrics and developer productivity research

## Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/irfanuddinahmad/dev-telemetry-devlake-plugin/issues)
- 💬 [Discussions](https://github.com/irfanuddinahmad/dev-telemetry-devlake-plugin/discussions)
