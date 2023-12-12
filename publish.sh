#!/usr/bin/env bash
#
# Publishes the arm64 built gem from ./output to Gemfury, along with a
# mirror of the other Sorbet gems.
#
# usage: GEMFURY_TOKEN=... ./publish.sh

set -eou pipefail

GEMFURY_USERNAME=${GEMFURY_USERNAME:-sorbet-multiarch}

function mirror_to_gemfury() {
  GEM_FILENAME=$1

  TMPDIR=$(mktemp -d)
  OUTPUT_PATH="${TMPDIR}/${GEM_FILENAME}"

  echo "Mirroring $GEM_FILENAME"
  curl \
    --silent \
    --output "$OUTPUT_PATH" \
    https://rubygems.org/downloads/$GEM_FILENAME

  curl -F package=@$OUTPUT_PATH https://${GEMFURY_TOKEN}@push.fury.io/${GEMFURY_USERNAME}/
}

function mirror_static_darwin_to_gemfury() {
  VERSION=$1

  MINOR=$(echo $VERSION | cut -d '.' -f 2)
  PATCH=$(echo $VERSION | cut -d '.' -f 3)

  # Switched a single macOS release: https://github.com/sorbet/sorbet/pull/7292
  if [ $PATCH >= 11010 ]; then
    mirror_to_gemfury "sorbet-static-${VERSION}-universal-darwin.gem"
  else
    # The Darwin versions for recent-ish Sorbet builds
    for DARWIN_VERSION in 14 15 16 17 18 19 20 21 22; do
      mirror_to_gemfury "sorbet-static-${VERSION}-universal-darwin-${DARWIN_VERSION}.gem"
    done
  fi
}

for GEM in output/*.gem; do
  VERSION=$(echo $GEM | sed -e 's/output\///' -e 's/sorbet-static-//' -e 's/-aarch64-linux.gem//')

  echo "Mirroring Sorbet gems for ${VERSION} to Gemfury"

  # Mirror the static binary gems
  mirror_to_gemfury "sorbet-static-${VERSION}-x86_64-linux.gem"
  mirror_to_gemfury "sorbet-static-${VERSION}-java.gem"
  mirror_static_darwin_to_gemfury $VERSION

  # Mirror remaining Sorbet gems
  mirror_to_gemfury "sorbet-${VERSION}.gem"
  mirror_to_gemfury "sorbet-runtime-${VERSION}.gem"
  mirror_to_gemfury "sorbet-static-and-runtime-${VERSION}.gem"

  echo "Publishing $GEM"
  curl -F package=@$GEM https://${GEMFURY_TOKEN}@push.fury.io/${GEMFURY_USERNAME}/
done
