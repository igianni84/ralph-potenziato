#!/bin/bash
# =============================================================================
# Project Template Init
# Quick setup check and guided start for new projects.
# =============================================================================

set -e

echo "================================================"
echo "  Claude Code Project Template"
echo "================================================"
echo ""

# Check prerequisites
MISSING=""

if ! command -v claude &> /dev/null; then
    MISSING="${MISSING}  - claude (Claude Code CLI): https://docs.anthropic.com/en/docs/claude-code\n"
fi

if ! command -v jq &> /dev/null; then
    MISSING="${MISSING}  - jq (JSON processor): brew install jq\n"
fi

if [ -n "$MISSING" ]; then
    echo "Missing prerequisites:"
    echo -e "$MISSING"
fi

# Initialize git if needed
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    echo "Git repository initialized."
    echo ""
fi

# Ensure project directories exist
for dir in tasks decisions plans knowledge docs; do
  [ ! -d "$dir" ] && mkdir -p "$dir"
done

# Make ralph.sh executable
chmod +x ralph.sh 2>/dev/null || true

echo "Template is ready."
echo ""
echo "Next steps:"
echo "  1. Start Claude Code:   claude"
echo "  2. Set up your project: /setup"
echo "     (Interviews you about project, stack, rules — configures everything)"
echo "  3. Create first PRD:    /prd-product then /prd-tech"
echo "  4. Run Ralph:           /ralph then ./ralph.sh"
echo ""
echo "Or configure manually:"
echo "  - Edit CLAUDE.md with your project details"
echo "  - Add stack-specific skills to .claude/skills/"
echo "  - Configure .claude/settings.local.json permissions"
echo ""
