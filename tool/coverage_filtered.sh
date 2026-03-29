#!/usr/bin/env bash
set -euo pipefail

rm -rf coverage
flutter test --coverage

if command -v lcov >/dev/null 2>&1; then
  lcov \
    --quiet \
    --remove coverage/lcov.info \
    "lib/screens/*" \
    "lib/src/core/presentation/*" \
    "lib/src/**/presentation/*" \
    -o coverage/lcov.filtered.info
  genhtml coverage/lcov.filtered.info -o coverage/html --ignore-errors range
else
  echo "lcov not found; generating full report instead." 1>&2
  genhtml coverage/lcov.info -o coverage/html --ignore-errors range
fi

echo "Open: coverage/html/index.html"

