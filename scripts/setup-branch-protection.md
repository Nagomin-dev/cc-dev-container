# Branch Protection Setup Guide

This guide explains how the automated branch protection system works in this Dev Container environment.

## Overview

The branch protection setup provides dual-layer protection:
1. **Remote Protection** - GitHub branch protection rules enforced server-side
2. **Local Protection** - Git hooks that help prevent accidental commits/pushes

## Features

### GitHub Branch Protection (Remote)
- Requires pull request reviews before merging
- Enforces status checks
- Prevents force pushes and branch deletions
- Requires code owner reviews
- Dismisses stale reviews on new commits

### Local Git Hooks (Pre-commit)
- Prevents direct commits to main/master branches
- Runs code quality checks (trailing whitespace, file size, etc.)
- Custom pre-push hook warns about pushing to protected branches

## Setup Process

### Automatic Setup
Branch protection is automatically configured when the Dev Container is created via the `postCreateCommand` in `devcontainer.json`.

### Manual Setup
To manually run the branch protection setup:
```bash
/workspace/.devcontainer/setup-branch-protection.sh
```

### Prerequisites for GitHub Protection
GitHub branch protection requires authentication:

```bash
# Option 1: Use GitHub CLI
gh auth login

# Option 2: Set environment variable
export GITHUB_TOKEN=your_personal_access_token
```

The token needs `repo` scope permissions.

## Configuration

### Customizing Protection Rules
Edit `.devcontainer/branch-protection-rules.json` to customize the protection rules:

```json
{
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "enforce_admins": false,
  "allow_force_pushes": false,
  "allow_deletions": false
}
```

### Customizing Pre-commit Hooks
Edit `.pre-commit-config.yaml` to add or modify hooks:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: no-commit-to-branch
        args: ['--branch', 'main', '--branch', 'master']
```

## Emergency Bypass

In emergency situations, you can bypass local hooks:

```bash
# Bypass pre-commit hooks
git commit --no-verify

# Bypass pre-push hooks
git push --no-verify
```

**Warning**: Use these only in emergencies. Always prefer using pull requests for protected branches.

## Troubleshooting

### GitHub Protection Not Applied
1. Check authentication: `gh auth status`
2. Verify repository permissions (need admin access)
3. Check if repository has a remote: `git remote -v`

### Local Hooks Not Working
1. Ensure pre-commit is installed: `which pre-commit`
2. Reinstall hooks: `pre-commit install`
3. Check hook files exist: `ls -la .git/hooks/`

### Checking Current Protection Status
```bash
# Check GitHub protection status
gh api repos/:owner/:repo/branches/main/protection

# Check local hooks
pre-commit --version
cat .git/hooks/pre-commit
```

## Best Practices

1. **Use Pull Requests**: Always use PRs for changes to protected branches
2. **Keep Rules Updated**: Regularly review and update protection rules
3. **Team Communication**: Ensure all team members understand the protection rules
4. **Token Security**: Store GitHub tokens securely, never commit them
5. **Regular Audits**: Periodically audit who has bypass permissions