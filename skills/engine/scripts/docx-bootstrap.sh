#!/bin/bash
# Ensure defusedxml is available for DOCX operations.
# Run before any DOCX redlining or verification workflow.
# Works in Cowork sandbox (pip install --user) and local Claude Code.

python3 -c "import defusedxml" 2>/dev/null || pip install --user --quiet defusedxml
echo "DOCX dependencies ready"
