# API Documentation

## Base URL

```
http://localhost:8080/plugins/developer_telemetry
```

## Authentication

Most endpoints require no authentication for connection management. The telemetry report endpoint requires a bearer token.

```
Authorization: Bearer <secretToken>
```

---

## Connection Management

### Create Connection

**POST** `/connections`

Create a new telemetry connection.

**Request Body:**
```json
{
  "name": "Development Team",
  "endpoint": "http://localhost:8080",
  "secretToken": "your-secret-token-here",
  "proxy": "",
  "rateLimitPerHour": 1000
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "Development Team",
  "endpoint": "http://localhost:8080",
  "rateLimitPerHour": 1000,
  "createdAt": "2026-02-12T10:00:00Z",
  "updatedAt": "2026-02-12T10:00:00Z"
}
```

---

### List Connections

**GET** `/connections`

Get all telemetry connections.

**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "name": "Development Team",
    "endpoint": "http://localhost:8080",
    "createdAt": "2026-02-12T10:00:00Z",
    "updatedAt": "2026-02-12T10:00:00Z"
  }
]
```

---

### Get Connection

**GET** `/connections/:connectionId`

Get a specific connection by ID.

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "Development Team",
  "endpoint": "http://localhost:8080",
  "rateLimitPerHour": 1000,
  "createdAt": "2026-02-12T10:00:00Z",
  "updatedAt": "2026-02-12T10:00:00Z"
}
```

**Error Response:** `404 Not Found`
```json
{
  "success": false,
  "message": "connection 1 not found"
}
```

---

### Update Connection

**PATCH** `/connections/:connectionId`

Update an existing connection.

**Request Body:**
```json
{
  "name": "Updated Team Name",
  "endpoint": "http://new-endpoint:8080",
  "secretToken": "new-token",
  "rateLimitPerHour": 2000
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "name": "Updated Team Name",
  "endpoint": "http://new-endpoint:8080",
  "rateLimitPerHour": 2000,
  "updatedAt": "2026-02-12T11:00:00Z"
}
```

---

### Delete Connection

**DELETE** `/connections/:connectionId`

Delete a connection. This will also delete all associated telemetry data.

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "connection deleted"
}
```

---

### Test Connection

**POST** `/connections/:connectionId/test`

Test a connection to verify it's working.

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "connection test successful"
}
```

---

## Telemetry Data

### Submit Telemetry Report

**POST** `/connections/:connectionId/report`

Submit developer telemetry data for a specific date.

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <secretToken>
```

**Request Body:**
```json
{
  "date": "2026-02-12",
  "developer": "john.doe",
  "email": "john@company.com",
  "name": "John Doe",
  "hostname": "john-laptop",
  "metrics": {
    "active_hours": 8,
    "tools_used": ["vscode", "git", "docker", "npm"],
    "commands": {
      "git": 45,
      "npm": 23,
      "docker": 12,
      "curl": 5
    },
    "projects": ["backend-api", "frontend-app", "mobile-app"]
  }
}
```

**Field Descriptions:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| date | string | Yes | Date in YYYY-MM-DD format |
| developer | string | Yes | Developer username/identifier |
| email | string | No | Developer email address |
| name | string | No | Developer full name |
| hostname | string | No | Workstation hostname |
| metrics.active_hours | integer | No | Hours actively coding |
| metrics.tools_used | array[string] | No | List of tools used |
| metrics.commands | object | No | Command counts (command: count) |
| metrics.projects | array[string] | No | List of projects worked on |

**Response:** `200 OK`
```json
{
  "success": true,
  "message": "telemetry data received successfully"
}
```

**Idempotency:**
Sending the same data (same connection_id, developer, and date) will update the existing record, not create a duplicate.

**Error Responses:**

**400 Bad Request** - Invalid input
```json
{
  "success": false,
  "message": "date and developer are required fields"
}
```

**400 Bad Request** - Invalid date format
```json
{
  "success": false,
  "message": "invalid date format, expected YYYY-MM-DD"
}
```

**401 Unauthorized** - Missing or invalid token
```json
{
  "success": false,
  "message": "unauthorized"
}
```

**404 Not Found** - Connection doesn't exist
```json
{
  "success": false,
  "message": "connection 1 not found"
}
```

---

## Data Models

### Connection

```json
{
  "id": 1,
  "name": "Development Team",
  "endpoint": "http://localhost:8080",
  "secretToken": "encrypted-token",
  "proxy": "",
  "rateLimitPerHour": 1000,
  "createdAt": "2026-02-12T10:00:00Z",
  "updatedAt": "2026-02-12T10:00:00Z"
}
```

### Developer Metrics

```json
{
  "connectionId": 1,
  "developerId": "john.doe",
  "date": "2026-02-12",
  "email": "john@company.com",
  "name": "John Doe",
  "hostname": "john-laptop",
  "activeHours": 8,
  "toolsUsed": "[\"vscode\",\"git\",\"docker\"]",
  "projectContext": "[\"backend-api\",\"frontend-app\"]",
  "commandCounts": "{\"git\":45,\"npm\":23}",
  "osInfo": "",
  "createdAt": "2026-02-12T10:00:00Z",
  "updatedAt": "2026-02-12T10:00:00Z"
}
```

**Note:** `toolsUsed`, `projectContext`, and `commandCounts` are stored as JSON strings in the database.

---

## Rate Limiting

Rate limiting is configured per connection via the `rateLimitPerHour` field. Default is 1000 requests per hour.

---

## Examples

### cURL Examples

```bash
# Create connection
curl -X POST http://localhost:8080/plugins/developer_telemetry/connections \
  -H "Content-Type: application/json" \
  -d '{"name":"My Team","endpoint":"http://localhost:8080","secretToken":"token123"}'

# Submit telemetry
curl -X POST http://localhost:8080/plugins/developer_telemetry/connections/1/report \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{
    "date":"2026-02-12",
    "developer":"alice",
    "email":"alice@co.com",
    "name":"Alice Smith",
    "hostname":"alice-mac",
    "metrics":{
      "active_hours":7,
      "tools_used":["python","vscode"],
      "commands":{"python":50,"git":20},
      "projects":["data-pipeline"]
    }
  }'

# Get all connections
curl http://localhost:8080/plugins/developer_telemetry/connections

# Get specific connection
curl http://localhost:8080/plugins/developer_telemetry/connections/1

# Update connection
curl -X PATCH http://localhost:8080/plugins/developer_telemetry/connections/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Team Name"}'

# Delete connection
curl -X DELETE http://localhost:8080/plugins/developer_telemetry/connections/1
```

### JavaScript Examples

```javascript
// Create connection
const response = await fetch('http://localhost:8080/plugins/developer_telemetry/connections', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    name: 'Development Team',
    endpoint: 'http://localhost:8080',
    secretToken: 'my-token-123'
  })
});
const connection = await response.json();

// Submit telemetry
await fetch(`http://localhost:8080/plugins/developer_telemetry/connections/${connection.id}/report`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer my-token-123'
  },
  body: JSON.stringify({
    date: '2026-02-12',
    developer: 'alice',
    email: 'alice@company.com',
    name: 'Alice Smith',
    hostname: 'alice-laptop',
    metrics: {
      active_hours: 8,
      tools_used: ['node', 'vscode', 'git'],
      commands: { npm: 30, git: 25 },
      projects: ['api', 'frontend']
    }
  })
});
```

### Python Examples

```python
import requests

# Create connection
response = requests.post(
    'http://localhost:8080/plugins/developer_telemetry/connections',
    json={
        'name': 'Development Team',
        'endpoint': 'http://localhost:8080',
        'secretToken': 'my-token-123'
    }
)
connection = response.json()

# Submit telemetry
requests.post(
    f'http://localhost:8080/plugins/developer_telemetry/connections/{connection["id"]}/report',
    headers={
        'Content-Type': 'application/json',
        'Authorization': 'Bearer my-token-123'
    },
    json={
        'date': '2026-02-12',
        'developer': 'bob',
        'email': 'bob@company.com',
        'name': 'Bob Jones',
        'hostname': 'bob-desktop',
        'metrics': {
            'active_hours': 6,
            'tools_used': ['python', 'pycharm', 'docker'],
            'commands': {'python': 40, 'docker': 15, 'git': 20},
            'projects': ['ml-model', 'data-pipeline']
        }
    }
)
```

---

## Database Queries

### Query Examples

```sql
-- Get all metrics for a developer
SELECT * FROM _tool_developer_metrics 
WHERE developer_id = 'john.doe' 
ORDER BY date DESC;

-- Get metrics for a date range
SELECT developer_id, date, active_hours, tools_used
FROM _tool_developer_metrics
WHERE date BETWEEN '2026-02-01' AND '2026-02-12'
ORDER BY date DESC, developer_id;

-- Get developer activity summary
SELECT 
  developer_id,
  COUNT(*) as days_active,
  SUM(active_hours) as total_hours,
  AVG(active_hours) as avg_hours_per_day
FROM _tool_developer_metrics
WHERE date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY developer_id;

-- Parse JSON fields
SELECT 
  developer_id,
  date,
  JSON_EXTRACT(tools_used, '$') as tools,
  JSON_EXTRACT(command_counts, '$.git') as git_commands
FROM _tool_developer_metrics
WHERE date = '2026-02-12';
```
