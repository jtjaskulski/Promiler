#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

echo "🧹 Cleaning project ($PROJECT_DIR)..."

clean_dirs() {
    local label="$1"
    shift
    echo "  Removing $label..."
    for pattern in "$@"; do
        find "$PROJECT_DIR" -type d -name "$pattern" -prune -exec rm -rf {} \; 2>/dev/null || true
    done
}

# React Native / JS
clean_dirs "node_modules"          "node_modules"
clean_dirs "Metro cache"           ".metro"

# Android
clean_dirs "Android cache"         ".gradle" ".cxx"
find "$PROJECT_DIR" -type d -path "*/android/build" -prune -exec rm -rf {} \; 2>/dev/null || true
find "$PROJECT_DIR" -type d -path "*/android/app/build" -prune -exec rm -rf {} \; 2>/dev/null || true

# iOS
clean_dirs "iOS Pods"              "Pods"
find "$PROJECT_DIR" -type d -path "*/ios/build" -prune -exec rm -rf {} \; 2>/dev/null || true

# .NET
clean_dirs "bin/obj"               "bin" "obj"
clean_dirs "NuGet packages"        "packages"

# IDE
clean_dirs ".vs"                   ".vs"
clean_dirs ".idea"                 ".idea"

# Other
clean_dirs "TestResults"           "TestResults"
clean_dirs "Logs"                  "Logs"
clean_dirs "artifacts"             "artifacts"

echo "  Removing *.user files..."
find "$PROJECT_DIR" -type f -name "*.user" -delete 2>/dev/null || true

echo ""
echo "✅ Cleaning complete!"

ZIP_NAME="${PROJECT_NAME}-$(date +%Y%m%d-%H%M).zip"
echo "📦 Creating archive: $ZIP_NAME..."
cd "$(dirname "$PROJECT_DIR")"
zip -r "$ZIP_NAME" "$PROJECT_NAME" \
    -x "*/node_modules/*" \
    -x "*/.git/*" \
    -x "*/bin/*" \
    -x "*/obj/*" \
    -x "*/.gradle/*"
mv "$ZIP_NAME" "$PROJECT_DIR/"

echo ""
echo "✅ Done!"
echo "   Project size: $(du -sh "$PROJECT_DIR" 2>/dev/null | awk '{print $1}' || echo 'N/A')"
echo "   Archive: $PROJECT_DIR/$ZIP_NAME"