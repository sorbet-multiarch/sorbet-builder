#!/usr/bin/env bash
#
# Builds the sorbet-static gem from upstream source to ./output
#
# usage: ./build.sh
# usage: SORBET_VERSION=0.5.10983 ./build.sh

set -eoux pipefail

function current_architecture() {
  case "$(uname -m)" in
    x86_64)
      echo "amd64"
      ;;
    aarch64|arm64)
      echo "arm64"
      ;;
    *)
      echo "unknown architecture: $(uname -m)"
      exit 1
      ;;
  esac
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

CURRENT_ARCH=$(current_architecture)

# Update local sorbet source mirror
if [ ! -d sorbet-mirror ]; then
  git clone git@github.com:sorbet/sorbet.git sorbet-mirror
else
  git -C sorbet-mirror pull
fi

# Prepare sorbet for building.
# It needs to be a clean git repo for:
# 1. versioning to work
# 2. the build to succeed
rm -rf sorbet
if [ ! -d sorbet ]; then
  git clone ./sorbet-mirror sorbet
fi

pushd sorbet

# (Optionally) build a specific version
if [ "${SORBET_VERSION:-}" != "" ]; then
  echo "Finding tag for $SORBET_VERSION"
  tag=$(git tag -l "${SORBET_VERSION}.*")
  commit_sha=$(git rev-list -n 1 "$tag")
  echo "Found $tag for $commit_sha"

  git checkout $commit_sha

  # point master at $commit_sha
  git branch -D master
  git checkout -b master
fi

if [ "${CURRENT_ARCH}" == "arm64" ]; then
  # sorbet will currently not build currently unmodified, as the
  # `--copt=-march=sandybridge` flags cause a failure.
  git apply ../fix-arm64-build.patch
fi

popd

# Optimize bazel building with caches
# Very helpful during development, less so in production
VOL_BINARIES=sorbet_bazel_binaries_${CURRENT_ARCH}
VOL_CACHE=sorbet_bazel_cache_${CURRENT_ARCH}
docker volume create $VOL_BINARIES &> /dev/null
docker volume create $VOL_CACHE &> /dev/null

OUTPUT_DIR=output
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

IMAGE="ghcr.io/sorbet-multiarch/sorbet-build-image:latest-${CURRENT_ARCH}"
docker run --rm \
  --platform "linux/${CURRENT_ARCH}" \
  -v $VOL_BINARIES:/root/.bazel_binaries \
  -v $VOL_CACHE:/usr/local/var/bazelcache \
  -v "${DIR}/sorbet":/app \
  -v "${DIR}/${OUTPUT_DIR}":/app/output \
  -v "${DIR}/scripts":/scripts \
  --workdir /app \
  "$IMAGE" /scripts/build-static-gem.sh
