#!/usr/bin/env bash

#set -x
set -ueo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ${SCRIPT_DIR}/utils.sh

WORK_DIR="${SCRIPT_DIR}/.."
MELANGE_DIR="${WORK_DIR}/melange"
PACKAGES_DIR="${WORK_DIR}/packages"

MELANGE_ARGS=""

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

function usage() {
  cat <<USAGE

Usage:
    $(basename $0) [OPTIONS] <config.yaml>

Description:
    Build Wolfi packages using Melange.

OPTIONS:

    --arch
        Specify the target architecture.

    -h | --help
        Display this help message.
USAGE
}

# --- main
while (("$#")); do
  case "$1" in
  --arch)
    shift
    MELANGE_ARGS+="--arch=$1"
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    MELANGE_CONFIG="$@"
    break
    ;;
  esac
done

if [[ "$OS" == "darwin" ]]; then
  DOCKER_UID=0
else
  DOCKER_UID=$(id -u)
fi

# Keygen
if [[ ! -s "${PACKAGES_DIR}/melange.rsa" ]]; then
  docker run -it --rm --privileged -u ${DOCKER_UID} \
    -v ${PACKAGES_DIR}:/work -w /work \
    cgr.dev/chainguard/melange:latest \
      keygen
fi

for config in $MELANGE_CONFIG; do
  echo_step "Build $config package"
  docker run -it --rm --privileged -u ${DOCKER_UID} \
    -v ${WORK_DIR}:/work -w /work \
    cgr.dev/chainguard/melange:latest \
      build /work/melange/$(basename ${config}) \
        --signing-key=/work/packages/melange.rsa \
        --apk-cache-dir=/work/.cache/apk \
        --cache-dir=/work/.cache/melange \
        --out-dir=/work/packages $MELANGE_ARGS
  echo_ok
  echo
done
