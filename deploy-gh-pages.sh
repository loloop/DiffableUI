#!/bin/bash

# Deploy documentation to GitHub Pages
# This script builds the docs and deploys them to the gh-pages branch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📚 DiffableUI Documentation GitHub Pages Deployment${NC}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes${NC}"
    echo "It's recommended to commit or stash changes before deploying"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Step 1: Generate the documentation website
echo -e "${BLUE}🔨 Building documentation website...${NC}"
if ./generate-docs-website.sh; then
    echo -e "${GREEN}✅ Documentation website built successfully${NC}"
else
    echo -e "${RED}❌ Failed to build documentation website${NC}"
    exit 1
fi

# Step 2: Check if gh-pages branch exists
echo -e "${BLUE}🔍 Checking gh-pages branch...${NC}"
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "gh-pages branch exists"
else
    echo "Creating gh-pages branch..."
    git checkout --orphan gh-pages
    git rm -rf .
    git commit --allow-empty -m "Initial gh-pages commit"
    git checkout "$CURRENT_BRANCH"
fi

# Step 3: Copy documentation to temporary directory
echo -e "${BLUE}📋 Preparing documentation for deployment...${NC}"
TEMP_DIR=$(mktemp -d)
cp -R docs-website/* "$TEMP_DIR/"

# Step 4: Switch to gh-pages branch
echo -e "${BLUE}🔄 Switching to gh-pages branch...${NC}"
git checkout gh-pages

# Step 5: Clear existing content and copy new documentation
echo -e "${BLUE}📁 Updating documentation...${NC}"
# Remove everything except .git
find . -maxdepth 1 ! -name '.git' ! -name '.' -exec rm -rf {} \;

# Copy new documentation
cp -R "$TEMP_DIR"/* .

# Create .nojekyll file to disable Jekyll processing
touch .nojekyll

# Step 6: Commit and push changes
echo -e "${BLUE}💾 Committing changes...${NC}"
git add .
git commit -m "Update documentation - $(date '+%Y-%m-%d %H:%M:%S')" || {
    echo -e "${YELLOW}⚠️  No changes to commit${NC}"
    git checkout "$CURRENT_BRANCH"
    rm -rf "$TEMP_DIR"
    exit 0
}

echo -e "${BLUE}🚀 Pushing to GitHub...${NC}"
git push origin gh-pages

# Step 7: Switch back to original branch
echo -e "${BLUE}🔄 Switching back to $CURRENT_BRANCH...${NC}"
git checkout "$CURRENT_BRANCH"

# Cleanup
rm -rf "$TEMP_DIR"

# Step 8: Display success message
echo ""
echo -e "${GREEN}🎉 Documentation deployed successfully!${NC}"
echo ""
echo -e "${BLUE}📍 Your documentation will be available at:${NC}"
echo "   https://[your-github-username].github.io/DiffableUI/"
echo ""
echo -e "${BLUE}📝 Note:${NC} It may take a few minutes for GitHub Pages to update"
echo ""
echo -e "${BLUE}⚙️  To enable GitHub Pages:${NC}"
echo "   1. Go to your repository settings on GitHub"
echo "   2. Navigate to 'Pages' section"
echo "   3. Set source to 'Deploy from a branch'"
echo "   4. Select 'gh-pages' branch and '/ (root)' folder"
echo "   5. Click Save"