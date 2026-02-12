#!/bin/bash
set -e

PLUGIN_NAME="developer_telemetry"
VERSION=${1:-"v0.1.0"}
BUILD_DIR="bin"

echo "📦 Creating release for ${PLUGIN_NAME} ${VERSION}"
echo ""

# Check if running from DevLake directory
if [ ! -f "go.mod" ] || ! grep -q "incubator-devlake" go.mod; then
    echo "❌ Error: This script must be run from the DevLake backend directory"
    echo ""
    echo "Steps:"
    echo "  1. cd /path/to/devlake/backend"
    echo "  2. cp -r /path/to/dev-telemetry-devlake-plugin/plugins/${PLUGIN_NAME} plugins/"
    echo "  3. /path/to/dev-telemetry-devlake-plugin/scripts/release.sh ${VERSION}"
    exit 1
fi

# Build the plugin
echo "Building plugin..."
DEVLAKE_PLUGINS=${PLUGIN_NAME} scripts/build-plugins.sh

# Check if build succeeded
PLUGIN_PATH="bin/plugins/${PLUGIN_NAME}/${PLUGIN_NAME}.so"
if [ ! -f "$PLUGIN_PATH" ]; then
    echo "❌ Build failed: ${PLUGIN_PATH} not found"
    exit 1
fi

# Create release directory
RELEASE_DIR="releases/${PLUGIN_NAME}-${VERSION}"
mkdir -p "$RELEASE_DIR"

# Copy binary
cp "$PLUGIN_PATH" "$RELEASE_DIR/${PLUGIN_NAME}.so"

# Generate checksum
cd "$RELEASE_DIR"
shasum -a 256 "${PLUGIN_NAME}.so" > "${PLUGIN_NAME}.so.sha256"

echo ""
echo "✅ Release created: $RELEASE_DIR"
echo ""
echo "Contents:"
ls -lh "$RELEASE_DIR"
echo ""
echo "Checksum:"
cat "$RELEASE_DIR/${PLUGIN_NAME}.so.sha256"
echo ""
echo "Next steps:"
echo "  1. Create a GitHub release for ${VERSION}"
echo "  2. Upload ${PLUGIN_NAME}.so and ${PLUGIN_NAME}.so.sha256"
echo "  3. Update README.md with the new version"
