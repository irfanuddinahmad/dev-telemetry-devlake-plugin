# Installation Guide

This guide covers different installation methods for the Developer Telemetry plugin.

## Prerequisites

- Apache DevLake (v0.20.0+)
- MySQL 8.0+ or PostgreSQL 13+
- Go 1.21+ (for building from source)

## Installation Methods

### Method 1: Pre-built Binary (Recommended)

This is the fastest method if a pre-built binary is available for your DevLake version.

1. **Download the binary**

   ```bash
   # Download from GitHub releases
   wget https://github.com/irfanuddinahmad/dev-telemetry-devlake-plugin/releases/latest/download/developer_telemetry.so
   
   # Or using curl
   curl -LO https://github.com/irfanuddinahmad/dev-telemetry-devlake-plugin/releases/latest/download/developer_telemetry.so
   ```

2. **Verify the download (optional but recommended)**

   ```bash
   # Download checksum
   wget https://github.com/irfanuddinahmad/dev-telemetry-devlake-plugin/releases/latest/download/developer_telemetry.so.sha256
   
   # Verify
   shasum -a 256 -c developer_telemetry.so.sha256
   ```

3. **Install to DevLake**

   ```bash
   # Create plugin directory
   mkdir -p /path/to/devlake/backend/bin/plugins/developer_telemetry/
   
   # Copy binary
   cp developer_telemetry.so /path/to/devlake/backend/bin/plugins/developer_telemetry/
   
   # Make executable (if needed)
   chmod +x /path/to/devlake/backend/bin/plugins/developer_telemetry/developer_telemetry.so
   ```

4. **Configure DevLake**

   ```bash
   # Set environment variable
   export DEVLAKE_PLUGINS=developer_telemetry
   
   # If using other plugins too
   export DEVLAKE_PLUGINS=github,jira,developer_telemetry
   ```

5. **Restart DevLake**

   ```bash
   cd /path/to/devlake/backend
   ./bin/lake
   ```

6. **Verify installation**

   ```bash
   # Check if plugin is loaded
   curl http://localhost:8080/plugins | jq '.[] | select(.name=="developer_telemetry")'
   ```

---

### Method 2: Build from Source

Use this method when:
- Pre-built binary is not available for your DevLake version
- You get version mismatch errors
- You want to modify the plugin

**Step 1: Prepare DevLake Environment**

```bash
# Navigate to your DevLake installation
cd /path/to/devlake/backend

# Ensure DevLake builds successfully
make build
```

**Step 2: Copy Plugin Source**

```bash
# Clone this repository
git clone https://github.com/irfanuddinahmad/dev-telemetry-devlake-plugin.git /tmp/dev-telemetry-plugin

# Copy plugin source to DevLake
cp -r /tmp/dev-telemetry-plugin/plugins/developer_telemetry plugins/
```

**Step 3: Build Plugin**

```bash
# Build using DevLake's build script
DEVLAKE_PLUGINS=developer_telemetry scripts/build-plugins.sh

# Or use make
DEVLAKE_PLUGINS=developer_telemetry make build-plugin
```

**Step 4: Verify Build**

```bash
# Check if binary was created
ls -lh bin/plugins/developer_telemetry/developer_telemetry.so

# Should show something like:
# -rw-r--r--  1 user  staff    27M Feb 12 10:00 developer_telemetry.so
```

**Step 5: Start DevLake**

```bash
export DEVLAKE_PLUGINS=developer_telemetry
./bin/lake
```

---

### Method 3: Docker Installation

If you're running DevLake in Docker:

**Step 1: Build Plugin**

First, build the plugin as described in Method 2.

**Step 2: Mount Plugin into Container**

```bash
# Stop existing container
docker stop devlake

# Run with plugin mounted
docker run -d \
  --name devlake \
  -p 8080:8080 \
  -v /path/to/devlake/backend/bin/plugins:/app/bin/plugins \
  -e DEVLAKE_PLUGINS=developer_telemetry \
  -e DB_URL="mysql://user:password@mysql:3306/devlake" \
  apache/devlake:latest
```

**Step 3: Using docker-compose**

Add to your `docker-compose.yml`:

```yaml
version: "3"
services:
  devlake:
    image: apache/devlake:latest
    environment:
      - DEVLAKE_PLUGINS=developer_telemetry
      - DB_URL=mysql://devlake:devlake@mysql:3306/devlake
    volumes:
      - ./backend/bin/plugins:/app/bin/plugins
    ports:
      - "8080:8080"
```

---

## Configuration

### Database Setup

The plugin will automatically create required tables on first run:
- `_tool_developer_telemetry_connections`
- `_tool_developer_metrics`

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DEVLAKE_PLUGINS` | Comma-separated list of plugins to load | (none) |
| `DB_URL` | Database connection string | (required) |
| `PORT` | API server port | 8080 |
| `ENCRYPTION_SECRET` | Secret for encrypting tokens | (required) |

### Example Configuration

```bash
export DEVLAKE_PLUGINS=developer_telemetry
export DB_URL="mysql://devlake:devlake123@127.0.0.1:3306/devlake?charset=utf8mb4&parseTime=True"
export PORT=8080
export ENCRYPTION_SECRET="your-secret-key-min-32-chars"
```

---

## Troubleshooting

### Version Mismatch Error

```
plugin was built with a different version of package github.com/apache/incubator-devlake/core/config
```

**Solution**: Rebuild the plugin using Method 2 (Build from Source).

### Plugin Not Loading

**Check logs:**
```bash
tail -f /var/log/devlake.log
# or
./bin/lake 2>&1 | tee devlake.log
```

**Common issues:**
1. Plugin file not in correct directory
2. Missing execute permissions: `chmod +x path/to/plugin.so`
3. `DEVLAKE_PLUGINS` environment variable not set
4. Plugin built for wrong Go/DevLake version

### Database Migration Errors

If you see migration errors:

```bash
# Drop and recreate database (WARNING: loses all data)
mysql -u root -p -e "DROP DATABASE devlake; CREATE DATABASE devlake;"

# Restart DevLake to run migrations again
./bin/lake
```

### File Permissions

```bash
# Ensure plugin is readable and executable
chmod 755 bin/plugins/developer_telemetry/developer_telemetry.so

# Check ownership
ls -l bin/plugins/developer_telemetry/
```

---

## Verification

After installation, verify everything is working:

```bash
# 1. Check if plugin is loaded
curl http://localhost:8080/plugins | jq '.[] | select(.name=="developer_telemetry")'

# 2. Create a test connection
curl -X POST http://localhost:8080/plugins/developer_telemetry/connections \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","endpoint":"http://localhost:8080","secretToken":"test123"}'

# 3. Send test telemetry
curl -X POST http://localhost:8080/plugins/developer_telemetry/connections/1/report \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test123" \
  -d '{
    "date":"2026-02-12",
    "developer":"test",
    "metrics":{"active_hours":1,"tools_used":["test"],"commands":{"test":1},"projects":["test"]}
  }'

# 4. Check database
mysql -u devlake -p devlake -e "SELECT * FROM _tool_developer_metrics WHERE developer_id='test';"
```

---

## Upgrading

### Upgrading from Pre-built Binary

```bash
# Download new version
wget https://github.com/irfanuddinahmad/dev-telemetry-devlake-plugin/releases/download/v0.2.0/developer_telemetry.so

# Backup old version
cp bin/plugins/developer_telemetry/developer_telemetry.so bin/plugins/developer_telemetry/developer_telemetry.so.backup

# Replace with new version
cp developer_telemetry.so bin/plugins/developer_telemetry/

# Restart DevLake
pkill -f bin/lake
./bin/lake
```

### Upgrading from Source

```bash
# Pull latest changes
cd /path/to/dev-telemetry-plugin
git pull

# Copy updated source
cp -r plugins/developer_telemetry /path/to/devlake/backend/plugins/

# Rebuild
cd /path/to/devlake/backend
DEVLAKE_PLUGINS=developer_telemetry scripts/build-plugins.sh

# Restart
pkill -f bin/lake
./bin/lake
```

---

## Uninstallation

```bash
# 1. Stop DevLake
pkill -f bin/lake

# 2. Remove plugin binary
rm -rf bin/plugins/developer_telemetry/

# 3. (Optional) Remove plugin tables
mysql -u devlake -p devlake -e "
  DROP TABLE IF EXISTS _tool_developer_metrics;
  DROP TABLE IF EXISTS _tool_developer_telemetry_connections;
"

# 4. Update environment variable
# Remove 'developer_telemetry' from DEVLAKE_PLUGINS

# 5. Restart DevLake
./bin/lake
```

---

## Next Steps

- [Quick Start Guide](../QUICKSTART.md) - Get started in 5 minutes
- [API Documentation](API.md) - Full API reference
- [Examples](examples/) - Sample collectors and integrations
