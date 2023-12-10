#!/usr/bin/env bash
#
# Publishes the gems from ./output to Gemfury
#
# usage: GEMFURY_TOKEN=... ./publish.sh

set -eou pipefail

GEMFURY_USERNAME=sorbet-multiarch

for gem in output/*.gem; do
  echo "Publishing $gem"
  curl -F package=@$gem https://${GEMFURY_TOKEN}@push.fury.io/${GEMFURY_USERNAME}/
done
