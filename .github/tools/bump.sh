#!/usr/bin/env bash
set -e
VERSION_FILE=".github/.version"
DATE=$(date +%Y-%m-%d)
usage() { echo "Usage: $0 [patch|minor|major|tag|release|version|changelog]"; exit 1; }
get_version() { cat "$VERSION_FILE"; }

bump() {
  read -r MAJOR MINOR PATCH <<< "$(get_version | tr '.' ' ')"
  case "$1" in
    patch) PATCH=$((PATCH+1));;
    minor) MINOR=$((MINOR+1)); PATCH=0;;
    major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0;;
    *) usage;;
  esac
  V="$MAJOR.$MINOR.$PATCH"
  echo "$V" > "$VERSION_FILE"
  echo "✅ Bumped to $V"
  [ -f package.json ] && jq --arg v "$V" '.version=$v' package.json > tmp && mv tmp package.json
  [ -f pyproject.toml ] && sed -i -E "s/^version\s*=.*/version = \"$V\"/" pyproject.toml
  git add "$VERSION_FILE" package.json pyproject.toml 2>/dev/null || true
  git commit -m "🔖 Bump version to $V"
  git push
}

case "$1" in
  patch|minor|major) bump "$1" ;;
  tag) git tag "v$(get_version)"; git push --tags ;;
  release) ./bump.sh tag && gh release create "v$(get_version)" --generate-notes ;;
  changelog) echo -e "## [v$(get_version)] - $DATE\n- $(git log -1 --pretty=format:"%s")\n" | cat - CHANGELOG.md > tmp && mv tmp CHANGELOG.md ;;
  version) get_version ;;
  *) usage ;;
esac
