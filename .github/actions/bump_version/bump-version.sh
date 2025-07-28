#!/usr/bin/env bash
set -e
VERSION_FILE=".github/.version"
DATE=$(date +%Y-%m-%d)
LEVEL="$1"
read -r MAJOR MINOR PATCH <<< "$(cat $VERSION_FILE | tr '.' ' ')"
case "$LEVEL" in
  patch) PATCH=$((PATCH + 1));;
  minor) MINOR=$((MINOR + 1)); PATCH=0;;
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0;;
  *) echo "❌ Unknown bump level: $LEVEL"; exit 1;;
esac
NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "$NEW_VERSION" > "$VERSION_FILE"
echo "✅ Bumped version to $NEW_VERSION"
[ -f package.json ] && jq --arg v "$NEW_VERSION" '.version = $v' package.json > tmp.json && mv tmp.json package.json
[ -f pyproject.toml ] && sed -i -E "s/^version\s*=\s*\"[0-9]+\.[0-9]+\.[0-9]+\"/version = \"$NEW_VERSION\"/" pyproject.toml
if [ -f CHANGELOG.md ]; then
  echo "## [v$NEW_VERSION] - $DATE" > .changelog.tmp
  git log -1 --pretty=format:"- %s" >> .changelog.tmp
  echo "" >> .changelog.tmp
  cat CHANGELOG.md >> .changelog.tmp
  mv .changelog.tmp CHANGELOG.md
fi
git config user.name "github-actions"
git config user.email "bot@users.noreply.github.com"
git add "$VERSION_FILE"
[ -f package.json ] && git add package.json
[ -f pyproject.toml ] && git add pyproject.toml
[ -f CHANGELOG.md ] && git add CHANGELOG.md
git commit -m "🔖 Bump version to $NEW_VERSION"
git push
