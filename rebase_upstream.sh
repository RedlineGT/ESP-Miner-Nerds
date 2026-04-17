#!/bin/bash
# Rebase script for syncing with upstream Official_Bleeding_Edge branch
# while preserving 3.5" display adaptations
#cd /home/nahin/Desktop/ESP-Miner-NerdQAxePlus-develop && git restore readme.md && git remote | grep -q '^upstream\s' || git remote add upstream https://github.com/RedlineGT/ESP-Miner-Nerds.git && git fetch upstream && git checkout Official_Bleeding_Edge_3.5Screen && git rebase upstream/Official_Bleeding_Edge && git push --force origin Official_Bleeding_Edge_3.5Screen

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== ESP-Miner Upstream Rebase Script ===${NC}"
echo "This script will sync with upstream Official_Bleeding_Edge branch"
echo "while preserving your 3.5\" display adaptations on Official_Bleeding_Edge_3.5Screen"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a Git repository${NC}"
    exit 1
fi

# Check if remote exists, if not add it
if ! git remote | grep -q upstream; then
    echo -e "${YELLOW}Adding upstream remote...${NC}"
    git remote add upstream https://github.com/RedlineGT/ESP-Miner-Nerds.git
fi

# Fetch latest from upstream
echo -e "${YELLOW}Fetching from upstream...${NC}"
git fetch upstream Official_Bleeding_Edge

# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "Official_Bleeding_Edge_3.5Screen" ]; then
    echo -e "${YELLOW}Switching to Official_Bleeding_Edge_3.5Screen branch...${NC}"
    git checkout Official_Bleeding_Edge_3.5Screen
fi

# Show what's about to happen
echo ""
echo -e "${YELLOW}Status before rebase:${NC}"
git log --oneline -3

echo ""
echo -e "${YELLOW}Commits to be rebased:${NC}"
git log --oneline upstream/Official_Bleeding_Edge..HEAD

echo ""
read -p "Continue with rebase? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Rebase cancelled${NC}"
    exit 0
fi

# Start interactive rebase to handle conflicts manually if needed
echo -e "${YELLOW}Starting rebase...${NC}"
if git rebase upstream/Official_Bleeding_Edge; then
    echo -e "${GREEN}Rebase completed successfully!${NC}"
    echo ""
    echo "Display adaptation changes preserved on top of upstream updates:"
    git log --oneline -5
else
    echo -e "${RED}Rebase encountered conflicts!${NC}"
    echo ""
    echo "To resolve conflicts:"
    echo "1. Edit conflicted files"
    echo "2. Stage resolved files: git add <file>"
    echo "3. Continue rebase: git rebase --continue"
    echo "4. Or abort: git rebase --abort"
    exit 1
fi

echo ""
echo -e "${GREEN}Rebase complete!${NC}"
echo "Consider running: idf.py fullclean && idf.py build"
