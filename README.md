# Build Distroless images using APKO/Melange By Chainguard

## Requirements

Docker needs to be installed on your host.

## Build Packages

```shell
./scripts/melange.sh --arch x86_64 \
  melange/<config1.yaml> \
  melange/<config_2.yaml>
```

## Build image

```shell
./scripts/apko.sh \
  apko/<image>/<config.yaml> \
  <tag> \
  <output.tar>
```
