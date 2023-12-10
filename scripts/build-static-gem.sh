#!/usr/bin/env bash
#
# Builds the sorbet static gem, put's them in /output
#
# This script runs with the cwd of the sorbet repository

set -eou pipefail

git config --global --add safe.directory /app

echo "Running .buildkite/build-static-release.sh..."
.buildkite/build-static-release.sh | tee output/build-static-release.log
cp _out_/gems/sorbet-static-*.gem output/
rm -rf _out_
