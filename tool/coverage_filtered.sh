#!/usr/bin/env bash
set -euo pipefail

backup_dir=""
if [ -d coverage ]; then
  backup_dir="$(mktemp -d)"
  cp -R coverage "${backup_dir}/coverage"
fi

rm -rf coverage
if ! flutter test --coverage; then
  echo "Tests failed; coverage report not updated." 1>&2
  if [ -n "${backup_dir}" ] && [ -d "${backup_dir}/coverage" ]; then
    rm -rf coverage
    mv "${backup_dir}/coverage" coverage
    echo "Restored previous coverage/ output." 1>&2
  fi
  exit 1
fi

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
