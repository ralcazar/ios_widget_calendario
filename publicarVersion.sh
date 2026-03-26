#!/bin/bash
set -e

VERSION=$(cat VERSION.txt | tr -d '[:space:]')
MAJOR=$(echo $VERSION | cut -d. -f1)
MINOR=$(echo $VERSION | cut -d. -f2)

if [[ "$1" == "--major" ]]; then
  NEW="$((MAJOR + 1)).0"
else
  NEW="$MAJOR.$((MINOR + 1))"
fi

echo $NEW > VERSION.txt
git add VERSION.txt
git commit -m "chore: bump version to $NEW"
git push
echo "✓ $VERSION → $NEW"
