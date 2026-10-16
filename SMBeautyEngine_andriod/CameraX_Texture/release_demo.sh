#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="CameraX_Texture"
OUT_DIR="${ROOT_DIR}/release"
STAMP="$(date +%Y%m%d_%H%M%S)"
ZIP_NAME="${PROJECT_NAME}_demo_${STAMP}.zip"
ZIP_PATH="${OUT_DIR}/${ZIP_NAME}"
STAGE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/${PROJECT_NAME}_release.XXXXXX")"
STAGE_PROJECT="${STAGE_DIR}/${PROJECT_NAME}"

cleanup() {
  rm -rf "${STAGE_DIR}"
}
trap cleanup EXIT

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "Missing required file: $1" >&2
    exit 1
  fi
}

require_file "${ROOT_DIR}/gradlew"
require_file "${ROOT_DIR}/settings.gradle"
require_file "${ROOT_DIR}/sdk-aar/lib_pixelFree.aar"
require_file "${ROOT_DIR}/sdk-aar/build.gradle"
require_file "${ROOT_DIR}/app/build.gradle"
require_file "${ROOT_DIR}/lib_pixelFree_uikit/build.gradle"

mkdir -p "${OUT_DIR}"

rsync -a "${ROOT_DIR}/" "${STAGE_PROJECT}/" \
  --exclude ".git/" \
  --exclude ".gradle/" \
  --exclude ".idea/" \
  --exclude ".cxx/" \
  --exclude ".externalNativeBuild/" \
  --exclude ".kotlin/" \
  --exclude "build/" \
  --exclude "*/build/" \
  --exclude "captures/" \
  --exclude "release/" \
  --exclude "recider/" \
  --exclude "local.properties" \
  --exclude "*.iml" \
  --exclude ".DS_Store" \
  --exclude "._*" \
  --exclude "*.log" \
  --exclude "*.tmp" \
  --exclude "*.swp" \
  --exclude "*.apk" \
  --exclude "*.aab" \
  --exclude "*.class"

find "${STAGE_PROJECT}" \
  \( -name ".DS_Store" -o -name "._*" -o -name "local.properties" -o -name "*.iml" -o -name "*.log" -o -name "*.tmp" -o -name "*.swp" \) \
  -print -delete

JUNK_LIST="$(find "${STAGE_PROJECT}" \
  \( -path "*/.gradle/*" \
  -o -path "*/.idea/*" \
  -o -path "*/.cxx/*" \
  -o -path "*/.externalNativeBuild/*" \
  -o -path "*/.kotlin/*" \
  -o -path "*/build/*" \
  -o -path "*/captures/*" \
  -o -path "*/release/*" \
  -o -path "*/recider/*" \
  -o -name ".DS_Store" \
  -o -name "._*" \
  -o -name "local.properties" \
  -o -name "*.iml" \
  -o -name "*.log" \
  -o -name "*.tmp" \
  -o -name "*.swp" \
  -o -name "*.apk" \
  -o -name "*.aab" \
  -o -name "*.class" \) \
  -print)"

if [[ -n "${JUNK_LIST}" ]]; then
  echo "Release check failed: unwanted files are still staged:" >&2
  printf '%s\n' "${JUNK_LIST}" >&2
  exit 1
fi

if grep -R "projectDir = file('../" "${STAGE_PROJECT}/settings.gradle" "${STAGE_PROJECT}"/*.gradle "${STAGE_PROJECT}"/app/*.gradle "${STAGE_PROJECT}"/lib_pixelFree_uikit/*.gradle >/dev/null 2>&1; then
  echo "Release check failed: project contains parent-directory module references." >&2
  exit 1
fi

if grep -R "project(':lib_pixelFree')" "${STAGE_PROJECT}/settings.gradle" "${STAGE_PROJECT}"/*.gradle "${STAGE_PROJECT}"/app/*.gradle "${STAGE_PROJECT}"/lib_pixelFree_uikit/*.gradle >/dev/null 2>&1; then
  echo "Release check failed: project still depends on lib_pixelFree source module." >&2
  exit 1
fi

(
  cd "${STAGE_DIR}"
  zip -qry "${ZIP_PATH}" "${PROJECT_NAME}"
)

echo "Created: ${ZIP_PATH}"
du -h "${ZIP_PATH}"
