#!/usr/bin/env bash
#
# Publishes the arm64 built gem from ./output to Gemfury, along with a
# mirror of the other Sorbet gems.
#
# usage: GEMFURY_TOKEN=... ./publish.sh

set -eou pipefail

GEMFURY_USERNAME=sorbet-multiarch

function mirror_to_gemfury() {
  GEM_FILENAME=$1

  TMPDIR=$(mktemp -d)
  OUTPUT_PATH="${TMPDIR}/1${GEM_FILENAME}"

  echo "Mirroring $GEM_FILENAME"
  curl \
    --silent \
    --output "$OUTPUT_PATH" \
    https://rubygems.org/downloads/$GEM_FILENAME

  curl -F package=@$OUTPUT_PATH https://${GEMFURY_TOKEN}@push.fury.io/${GEMFURY_USERNAME}/
}

for GEM in output/*.gem; do
  VERSION=$(echo $GEM | sed -e 's/output\///' -e 's/sorbet-static-//' -e 's/-aarch64-linux.gem//')

  echo "Mirroring Sorbet gems for ${VERSION} to Gemfury"

  # Mirror the platform+architecture specific static gems
  mirror_to_gemfury "sorbet-static-${VERSION}-x86_64-linux.gem"
  mirror_to_gemfury "sorbet-static-${VERSION}-java.gem"
  mirror_to_gemfury "sorbet-static-${VERSION}-universal-darwin.gem"

  # Mirror remaining Sorbet gems
  mirror_to_gemfury "sorbet-${VERSION}.gem"
  mirror_to_gemfury "sorbet-runtime-${VERSION}.gem"
  mirror_to_gemfury "sorbet-static-and-runtime-${VERSION}.gem"

  echo "Publishing $GEM"
  curl -F package=@$GEM https://${GEMFURY_TOKEN}@push.fury.io/${GEMFURY_USERNAME}/
done
