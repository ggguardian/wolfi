# dependabot-updater

## Build Packages

```shell
./scripts/melange.sh \
  melange/git-shim.yaml \
  melange/py3-mercurial.yaml \
  melange/py3-pdm.yaml \
  melange/dependabot-updater.yaml
```

## Build images

- Build `prod` image:

```shell
./scripts/apko.sh \
  apko/dependabot-updater/base.yaml \
  ggguardian/dependabot-updater:latest \
  dependabot-updater-latest.tar
```

- Build `dev` image:

```shell
./scripts/apko.sh \
  apko/dependabot-updater/dev.yaml \
  ggguardian/dependabot-updater:latest-dev \
  dependabot-updater-latest-dev.tar
```

## Load images

- Load `dev` image:

```shell
docker load --input images/dependabot-updater-latest-dev.tar
```

- Load `prod` image:

```shell
docker load --input images/dependabot-updater-latest.tar
```

## Publish images

- Publish `prod` image:

```shell
./scripts/apko.sh --publish \
  apko/dependabot-updater/base.yaml \
  ggguardian/dependabot-updater:latest
```

- Publish `dev` image:

```shell
./scripts/apko.sh --publish \
  apko/dependabot-updater/dev.yaml \
  ggguardian/dependabot-updater:latest-dev
```

## Use with dependabot CLI

```shell
dependabot update go_modules rsc/quote --updater-image ggguardian/dependabot-updater:latest-dev-amd64
```
