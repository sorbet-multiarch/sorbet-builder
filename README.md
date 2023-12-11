# sorbet-builder
Build the Sorbet Ruby gem for the linux/arm64 platform.

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/sorbet-multiarch/sorbet-builder/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/sorbet-multiarch/sorbet-builder/tree/main)

## Usage
There are a couple of ways to use this repository: the gems published to Gemfury, or directly building your own.

### Gems on Gemfury
This repository is used to build and publish gems to Gemfury.
Just change your `Gemfile` like so:
```
source 'https://gem.fury.io/sorbet-multiarch/' do
  gem 'sorbet-static'
  gem 'sorbet'
end
```

Specific versions can be used too (when published):
```
source 'https://gem.fury.io/sorbet-multiarch/' do
  gem 'sorbet-static', '0.5.11150'
  gem 'sorbet', '0.5.11150'
end
```

### Build your own
Clone this repository, run the scripts to build the gems you need, upload the gems to your artifact repository.

## Requirements
1. An arm CPU (an Apple Silicon mac, other arm powered computer)
1. Docker

## Building sorbet-static
To build the latest version of Sorbet static gem: `./build.sh`

The result:
```
❯ tree output
output
├── build-static.log
└── sorbet-static-0.5.11150-aarch64-linux.gem

1 directory, 2 files
```

### Specific version
To build a **specific version** of the Sorbet static gem: `SORBET_VERSION=0.5.10993 ./build.sh`

The result:
```
❯ tree output
output
├── build-static-release.log
└── sorbet-static-0.5.10993-aarch64-linux.gem

1 directory, 2 files
```

## Disclaimer

This project is not affiliated with either [Sorbet](https://github.com/sorbet/) or [Stripe](https://stripe.com/).
