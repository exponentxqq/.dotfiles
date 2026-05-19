#!/bin/bash
# Install Claude plugins from plugins.json manifest

set -e

BASEDIR=$(cd "$(dirname "$0")" && pwd)
PLUGINS_FILE="$BASEDIR/plugins.json"

if [ ! -f "$PLUGINS_FILE" ]; then
    echo "Error: plugins.json not found at $PLUGINS_FILE"
    exit 1
fi

# Parse plugins using jq (install if not available)
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    brew install jq || apt-get install jq -y || sudo apt-get install jq -y
fi

echo "Installing Claude plugins..."

# Extract unique marketplaces first
marketplaces=$(jq -r '.plugins[] | "\(.marketplace) \(.repo)"' "$PLUGINS_FILE" | sort -u)

while read -r marketplace repo; do
    echo "Adding marketplace: $marketplace ($repo)"
    claude plugins marketplace add "$marketplace" 2>/dev/null || true
done <<< "$marketplaces"

# Install each plugin
plugins=$(jq -r '.plugins[].name' "$PLUGINS_FILE")

for plugin in $plugins; do
    echo "Installing plugin: $plugin"
    claude plugins install "$plugin"
done

echo "Done! Plugins installed successfully."
