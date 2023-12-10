# sorbet-builder
Builds the Sorbet Ruby gem for the linux/arm64 platform.

## Requirements
1. An arm CPU (an Apple Silicon mac, other arm powered computer)
1. Docker

## Usage
To build the latest version of Sorbet: `./build.sh`

The result:
```
❯ tree output
output
├── build-static.log
└── sorbet-static-0.5.11150-aarch64-linux.gem

1 directory, 2 files
```

### Specific version
To build a specific version of Sorbet: `SORBET_VERSION=0.5.10993 ./build.sh`

The result:
```
❯ tree output
output
├── build-static-release.log
└── sorbet-static-0.5.10993-aarch64-linux.gem

1 directory, 2 files
```
