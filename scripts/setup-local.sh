#!/bin/sh
set -eu

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

git remote set-url origin git@github-second:snail-step/daily-finance-report-claude.git
git config user.name snail-step
git config user.email snail.juku@yahoo.com

echo "Configured origin: $(git remote get-url origin)"
echo "Configured author: $(git config user.name) <$(git config user.email)>"
ssh -o BatchMode=yes -o StrictHostKeyChecking=yes -T git@github-second 2>&1 | grep 'Hi snail-step!'
git push --dry-run origin HEAD:main
