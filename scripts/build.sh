#!/bin/bash
set -e

PLUGIN_NAME="developer_telemetry"
BUILD_DIR="bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔨 Developer Telemetry Plugin Build Script"
echo ""
echo "⚠️  WARNING: This script cannot build the plugin standalone!"
echo "The plugin requires DevLake's internal packages."
echo ""
echo "To build this plugin:"
echo "  1. Navigate to your DevLake backend directory"
echo "  2. Copy plugin source: cp -r ${PROJECT_ROOT}/plugins/${PLUGIN_NAME} plugins/"
echo "  3. Build: DEVLAKE_PLUGINS=${PLUGIN_NAME} scripts/build-plugins.sh"
echo ""
echo "See README.md for detailed instructions."
echo ""

exit 1
