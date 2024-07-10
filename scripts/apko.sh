#!/usr/bin/env bash

#set -x
set -ueo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ${SCRIPT_DIR}/utils.sh

WORK_DIR="${SCRIPT_DIR}/.."
APKO_DIR="${WORK_DIR}/apko"
PACKAGES_DIR="${WORK_DIR}/packages"

APKO_CMD="build"
APKO_ARGS=""
APKO_CONFIG=""
APKO_TAG=""
APKO_OUTPUT_TAR=""

IMAGE=""
TARGET="dev"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

function usage() {
  cat <<USAGE

Usage:
    $(basename $0) [OPTIONS] <config.yaml> <tag> <output.tar>

Description:
    Build a Docker image using APKO.

OPTIONS:

    --arch
        Specify the target architecture.

    -p | --publish
        Publish image with the specified tag.

    -h | --help
        Display this help message
USAGE
}

# --- main
while (("$#")); do
  case "$1" in
  -p | --publish)
    APKO_CMD="publish"
    shift
    ;;
  --arch)
    shift
    APKO_ARGS+="--arch=$1"
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    if [[ -z "$APKO_CONFIG" ]]; then
      APKO_CONFIG="$1"
      shift
    elif [[ -z "$APKO_TAG" ]]; then
      APKO_TAG="$1"
      shift
    elif [[ -z "$APKO_OUTPUT_TAR" ]]; then
      APKO_OUTPUT_TAR="$1"
      shift
    else
      usage
      exit 1
    fi
    ;;
  esac
done

if [[ "$OS" == "darwin" ]]; then
  DOCKER_UID=0
else
  DOCKER_UID=$(id -u)
fi

docker run -it --rm --privileged -u ${DOCKER_UID} \
  -v ${WORK_DIR}:/work -w /work \
  cgr.dev/chainguard/apko:latest \
    $APKO_CMD $APKO_ARGS \
      --sbom=false \
      --cache-dir=/work/.cache/apk \
      --workdir=/work/apko/$(basename $(dirname $APKO_CONFIG)) \
      $(basename $APKO_CONFIG) $APKO_TAG /work/images/${APKO_OUTPUT_TAR}
