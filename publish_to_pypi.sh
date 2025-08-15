#!/usr/bin/env bash
set -euo pipefail

# setup.sh - Cross-platform setup for python projects

# Default mode: ask the user
FETCH_LATEST="interactive"
CI_MODE="no"

# Check if setup.json exists and has a repo_update_preference
if [ -f "publish_to_pypi.json" ]; then
  # Try to extract repo_update_preference using grep and sed
  # This avoids requiring jq or python for JSON parsing
  STORED_PREFERENCE=$(grep -o '"repo_update_preference"\s*:\s*"[^"]*"' publish_to_pypi.json 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/' || echo "")
  
  if [ -n "$STORED_PREFERENCE" ]; then
    echo "🔒 Using stored repository update preference: $STORED_PREFERENCE"
    FETCH_LATEST="$STORED_PREFERENCE"
  fi
fi

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  -u, --update       Automatically pull the latest publish_to_pypi.py (no prompt)
  -n, --no-update    Skip pulling the latest publish_to_pypi.py
  --ci               CI/CD mode (same as --update)
  -h, --help         Show this help message and exit
EOF
  exit 0
}

# --- parse command-line flags ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--update)      FETCH_LATEST="yes" ;;
    -n|--no-update)   FETCH_LATEST="no"  ;;
    --ci)             FETCH_LATEST="yes"; CI_MODE="yes" ;;
    -h|--help)        usage ;;
    *)  echo "Unknown option: $1" >&2
        usage
        ;;
  esac
  shift
done

# --- check if publish_to_pypi.py exists ---
if [ ! -f "publish_to_pypi.py" ]; then
  echo "🔍 publish_to_pypi.py not found. Will automatically download it."
  FETCH_LATEST="yes"
# --- interactive prompt if needed ---
elif [[ "$FETCH_LATEST" == "interactive" ]]; then
  read -r -p "Pull latest publish_to_pypi.py from repository? [y/N] " answer
  if [[ "$answer" =~ ^[Yy] ]]; then
    FETCH_LATEST="yes"
  else
    FETCH_LATEST="no"
  fi
fi

# --- fetch if requested ---
if [[ "$FETCH_LATEST" == "yes" ]]; then
  echo "🔄 Fetching latest publish_to_pypi.py..."
  curl -sSL \
    https://raw.githubusercontent.com/geekcafe/publish_to_pypi/main/publish_to_pypi.py \
    -o publish_to_pypi.py
fi

# --- run the Python installer ---
if [[ "$CI_MODE" == "yes" ]]; then
  echo "🤖 Running in CI/CD mode..."
  python3 publish_to_pypi.py --ci
else
  python3 publish_to_pypi.py
fi
