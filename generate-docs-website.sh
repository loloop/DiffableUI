#!/bin/bash

# Generate static HTML website from DocC archive
# This script builds the documentation and transforms it into a deployable website

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DERIVED_DATA_PATH=".build"
ARCHIVE_PATH="$DERIVED_DATA_PATH/Build/Products/Debug/DiffableUI.doccarchive"
OUTPUT_PATH="docs-website"
HOSTING_BASE_PATH="/DiffableUI"

echo -e "${BLUE}📚 DiffableUI Documentation Website Generator${NC}"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Set docc path
DOCC_PATH="$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/bin/docc"

# Check if docc is available
if [ ! -f "$DOCC_PATH" ]; then
    echo -e "${RED}❌ Error: 'docc' command not found at $DOCC_PATH${NC}"
    echo "Please ensure Xcode 13.3+ is installed"
    exit 1
fi

# Step 1: Build the documentation archive
echo -e "${BLUE}📦 Building documentation archive...${NC}"
if xcodebuild docbuild -scheme DiffableUI -derivedDataPath "$DERIVED_DATA_PATH" -quiet; then
    echo -e "${GREEN}✅ Documentation archive built successfully${NC}"
else
    echo -e "${RED}❌ Failed to build documentation archive${NC}"
    exit 1
fi

# Step 2: Check if archive exists
if [ ! -d "$ARCHIVE_PATH" ]; then
    echo -e "${RED}❌ Error: Documentation archive not found at $ARCHIVE_PATH${NC}"
    exit 1
fi

# Step 3: Clean previous output
if [ -d "$OUTPUT_PATH" ]; then
    echo -e "${BLUE}🧹 Cleaning previous output directory...${NC}"
    rm -rf "$OUTPUT_PATH"
fi

# Step 4: Process the archive into static HTML
echo -e "${BLUE}🔄 Transforming archive to static HTML website...${NC}"
echo "  Output directory: $OUTPUT_PATH"
echo "  Hosting base path: $HOSTING_BASE_PATH"

# Use docc to process the archive
"$DOCC_PATH" process-archive \
    transform-for-static-hosting "$ARCHIVE_PATH" \
    --hosting-base-path "$HOSTING_BASE_PATH" \
    --output-path "$OUTPUT_PATH"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Static website generated successfully${NC}"
else
    echo -e "${RED}❌ Failed to generate static website${NC}"
    exit 1
fi

# Step 5: Create an index.html redirect if needed
if [ ! -f "$OUTPUT_PATH/index.html" ]; then
    echo -e "${BLUE}📝 Creating index.html redirect...${NC}"
    cat > "$OUTPUT_PATH/index.html" << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="refresh" content="0; url=./documentation/diffableui/">
    <title>DiffableUI Documentation</title>
</head>
<body>
    <p>Redirecting to <a href="./documentation/diffableui/">DiffableUI Documentation</a>...</p>
</body>
</html>
EOF
fi

# Step 6: Create a simple local server script
echo -e "${BLUE}📝 Creating local preview server script...${NC}"
cat > "$OUTPUT_PATH/serve-locally.sh" << 'EOF'
#!/bin/bash
# Serve the documentation locally for preview

PORT=${1:-8000}
echo "🌐 Starting local documentation server on http://localhost:$PORT"
echo "Press Ctrl+C to stop the server"
python3 -m http.server $PORT
EOF
chmod +x "$OUTPUT_PATH/serve-locally.sh"

# Step 7: Display summary
echo ""
echo -e "${GREEN}🎉 Documentation website generated successfully!${NC}"
echo ""
echo -e "${BLUE}📁 Output location:${NC} $OUTPUT_PATH"
echo ""
echo -e "${BLUE}🚀 Next steps:${NC}"
echo "  1. To preview locally:"
echo "     cd $OUTPUT_PATH && ./serve-locally.sh"
echo ""
echo "  2. To deploy to GitHub Pages:"
echo "     - Copy contents of '$OUTPUT_PATH' to your gh-pages branch"
echo "     - Or use GitHub Actions to automate deployment"
echo ""
echo "  3. To deploy to other hosting services:"
echo "     - Upload contents of '$OUTPUT_PATH' to your web server"
echo "     - Ensure your server is configured to serve static files"
echo ""
echo -e "${BLUE}📝 Notes:${NC}"
echo "  - The site is configured for hosting at: $HOSTING_BASE_PATH"
echo "  - To change the hosting path, modify HOSTING_BASE_PATH in this script"
echo "  - The generated site is fully static and can be hosted anywhere"