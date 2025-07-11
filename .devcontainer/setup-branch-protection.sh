#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🛡️  Setting up branch protection...${NC}"

# Function to check if we're in a git repository
is_git_repo() {
    git rev-parse --git-dir > /dev/null 2>&1
}

# Function to get the default branch name
get_default_branch() {
    # Try to get from remote first
    if git remote show origin >/dev/null 2>&1; then
        git remote show origin | grep 'HEAD branch' | cut -d' ' -f5
    else
        # Fallback to local detection
        if git rev-parse --verify main >/dev/null 2>&1; then
            echo "main"
        elif git rev-parse --verify master >/dev/null 2>&1; then
            echo "master"
        else
            echo "main" # Default to main
        fi
    fi
}

# Initialize git repo if not already initialized
if ! is_git_repo; then
    echo -e "${YELLOW}📂 Initializing git repository...${NC}"
    git init
    git branch -M main
fi

# Set up pre-commit hooks for local branch protection
echo -e "${GREEN}🔧 Setting up pre-commit hooks...${NC}"

# Install pre-commit hooks
if [ -f /workspace/.pre-commit-config.yaml ]; then
    pre-commit install
    echo -e "${GREEN}✅ Pre-commit hooks installed${NC}"
else
    echo -e "${YELLOW}⚠️  No .pre-commit-config.yaml found, skipping pre-commit setup${NC}"
fi

# Set up GitHub branch protection if authenticated
if gh auth status >/dev/null 2>&1; then
    echo -e "${GREEN}🔐 GitHub authentication detected${NC}"
    
    # Check if we have a remote origin
    if git remote get-url origin >/dev/null 2>&1; then
        REPO_URL=$(git remote get-url origin)
        
        # Extract owner/repo from URL
        if [[ $REPO_URL =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
            OWNER="${BASH_REMATCH[1]}"
            REPO="${BASH_REMATCH[2]}"
            
            echo -e "${GREEN}📦 Repository: ${OWNER}/${REPO}${NC}"
            
            # Check if branch protection rules config exists
            RULES_FILE="/workspace/.devcontainer/branch-protection-rules.json"
            if [ -f "$RULES_FILE" ]; then
                echo -e "${GREEN}📋 Found branch protection rules configuration${NC}"
                
                # Get protected branches from config
                BRANCHES=$(jq -r '.branches[]' "$RULES_FILE" 2>/dev/null || echo "main master develop staging")
                
                for BRANCH in $BRANCHES; do
                    # Check if branch exists on remote
                    if git ls-remote --heads origin "$BRANCH" | grep -q "$BRANCH"; then
                        echo -e "${GREEN}🔒 Setting up protection for branch: $BRANCH${NC}"
                        
                        # Apply branch protection using gh CLI
                        gh api repos/$OWNER/$REPO/branches/$BRANCH/protection \
                            --method PUT \
                            --input "$RULES_FILE" \
                            >/dev/null 2>&1 && \
                            echo -e "${GREEN}✅ Branch protection applied to $BRANCH${NC}" || \
                            echo -e "${YELLOW}⚠️  Could not apply protection to $BRANCH (may require admin access)${NC}"
                    else
                        echo -e "${YELLOW}⚠️  Branch $BRANCH does not exist on remote${NC}"
                    fi
                done
            else
                echo -e "${YELLOW}⚠️  No branch protection rules configuration found${NC}"
                echo -e "${YELLOW}   Create .devcontainer/branch-protection-rules.json to configure${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Could not parse repository information from remote URL${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  No remote origin found${NC}"
        echo -e "${YELLOW}   Branch protection will be applied when you add a remote${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  GitHub CLI not authenticated${NC}"
    echo -e "${YELLOW}   Run 'gh auth login' to enable remote branch protection${NC}"
fi

# Set up local git config for branch protection awareness
DEFAULT_BRANCH=$(get_default_branch)
git config --local branch.${DEFAULT_BRANCH}.protected true
git config --local branch.staging.protected true
git config --local branch.develop.protected true

echo -e "${GREEN}✅ Branch protection setup complete!${NC}"
echo -e "${GREEN}   Protected branches: ${DEFAULT_BRANCH}, staging, develop${NC}"
echo -e "${GREEN}   Local hooks will prevent direct commits to these branches${NC}"