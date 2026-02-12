# Quick Start Guide

Get up and running with the Developer Telemetry DevLake plugin in 5 minutes.

## 1. Installation

> ⚠️ **VERSION COMPATIBILITY**: Pre-built binaries are version-specific. If you get a version mismatch error, use Option B.

### Option A: Use Pre-built Binary (Fastest)

```bash
# Download from GitHub releases
wget https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/releases/latest/download/developer_telemetry.so

# Copy to DevLake plugins directory
mkdir -p /path/to/devlake/backend/bin/plugins/developer_telemetry/
cp developer_telemetry.so /path/to/devlake/backend/bin/plugins/developer_telemetry/

# Restart DevLake
cd /path/to/devlake/backend
export DEVLAKE_PLUGINS=developer_telemetry
./bin/lake
```

### Option B: Rebuild for Your DevLake Version

```bash
# Navigate to your DevLake installation
cd /path/to/devlake/backend

# Copy plugin source
cp -r /path/to/dev-telemetry-devlake-plugin/plugins/developer_telemetry plugins/

# Build against your DevLake version
DEVLAKE_PLUGINS=developer_telemetry scripts/build-plugins.sh

# Start DevLake
export DEVLAKE_PLUGINS=developer_telemetry
./bin/lake
```

## 2. Configuration

### Create Connection

```bash
curl -X POST http://localhost:8080/plugins/developer_telemetry/connections \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Development Team",
    "endpoint": "http://localhost:8080",
    "secretToken": "my-secret-token-12345"
  }'
```

Expected response:
```json
{
  "id": 1,
  "name": "My Development Team",
  "endpoint": "http://localhost:8080",
  "createdAt": "2026-02-12T10:00:00Z",
  "updatedAt": "2026-02-12T10:00:00Z"
}
```

### Verify Connection

```bash
curl http://localhost:8080/plugins/developer_telemetry/connections/1
```

## 3. Send Your First Telemetry Report

```bash
curl -X POST http://localhost:8080/plugins/developer_telemetry/connections/1/report \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer my-secret-token-12345" \
  -d '{
    "date": "2026-02-12",
    "developer": "alice.smith",
    "email": "alice@company.com",
    "name": "Alice Smith",
    "hostname": "alice-macbook",
    "metrics": {
      "active_hours": 7,
      "tools_used": ["vscode", "git", "docker", "npm"],
      "commands": {
        "git": 45,
        "npm": 23,
        "docker": 12
      },
      "projects": ["backend-api", "frontend-app", "docs"]
    }
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "telemetry data received successfully"
}
```

## 4. Query Your Data

Connect to your database and run:

```sql
-- View all developer metrics
SELECT * FROM _tool_developer_metrics;

-- Get today's activity
SELECT 
  developer_id,
  active_hours,
  tools_used,
  project_context
FROM _tool_developer_metrics
WHERE date = CURDATE();

-- Get developer summary for the week
SELECT 
  developer_id,
  COUNT(*) as days_active,
  SUM(active_hours) as total_hours,
  AVG(active_hours) as avg_hours
FROM _tool_developer_metrics
WHERE date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY developer_id;
```

## 5. Update Existing Data (Idempotent)

You can safely re-send data for the same developer and date - it will update:

```bash
curl -X POST http://localhost:8080/plugins/developer_telemetry/connections/1/report \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer my-secret-token-12345" \
  -d '{
    "date": "2026-02-12",
    "developer": "alice.smith",
    "email": "alice.updated@company.com",
    "name": "Alice Smith",
    "hostname": "alice-new-macbook",
    "metrics": {
      "active_hours": 8,
      "tools_used": ["vscode", "git"],
      "commands": {
        "git": 60
      },
      "projects": ["backend-api-v2"]
    }
  }'
```

The record will be updated, not duplicated!

## Next Steps

### Create a Local Collector

Build a simple collector that runs on developers' machines:

**Python Example** (`collector.py`):
```python
#!/usr/bin/env python3
import requests
import json
from datetime import date
import os
import socket

CONNECTION_ID = 1
TOKEN = "my-secret-token-12345"
DEVLAKE_URL = "http://localhost:8080"

def collect_metrics():
    # Customize this to collect actual metrics
    return {
        "date": str(date.today()),
        "developer": os.getenv("USER"),
        "email": f"{os.getenv('USER')}@company.com",
        "name": "Developer Name",
        "hostname": socket.gethostname(),
        "metrics": {
            "active_hours": 8,
            "tools_used": ["python", "vscode", "git"],
            "commands": {"python": 30, "git": 20},
            "projects": ["my-project"]
        }
    }

def send_telemetry():
    data = collect_metrics()
    url = f"{DEVLAKE_URL}/plugins/developer_telemetry/connections/{CONNECTION_ID}/report"
    
    response = requests.post(
        url,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {TOKEN}"
        },
        json=data
    )
    
    if response.status_code == 200:
        print("✅ Telemetry sent successfully!")
    else:
        print(f"❌ Error: {response.text}")

if __name__ == "__main__":
    send_telemetry()
```

Run it:
```bash
chmod +x collector.py
./collector.py
```

### Schedule Daily Collection

Add to crontab to run daily at 6 PM:
```bash
0 18 * * * /path/to/collector.py
```

### Build a VS Code Extension

Create a VS Code extension that tracks:
- Active coding time
- File types worked on
- Extensions used
- Commands executed

Send this data to DevLake daily.

## Troubleshooting

### Connection Refused

Make sure DevLake is running:
```bash
curl http://localhost:8080/plugins
```

### Unauthorized Error

Check your token matches the connection:
```bash
# Get connection details
curl http://localhost:8080/plugins/developer_telemetry/connections/1
```

### Database Connection Issues

Verify database is accessible:
```bash
mysql -h 127.0.0.1 -P 3306 -u devlake -p devlake_test
```

## More Examples

See the [docs/examples](docs/examples) directory for:
- Shell script collector
- Node.js collector
- Go collector
- VS Code extension template
- CI/CD integration examples

## Support

Need help? Check:
- [Full Documentation](../README.md)
- [API Reference](docs/API.md)
- [GitHub Issues](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/issues)
