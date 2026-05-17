#!/usr/bin/env bash
set -euo pipefail

# Sync the generated resume PDF from this repository to a target GitHub repo.
# Defaults are set for Audrey's profile repository but can be overridden.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

BUILD_OUTPUT_NAME="${BUILD_OUTPUT_NAME:-AudreyHoughton}"
SOURCE_TEX="${SOURCE_TEX:-${ROOT_DIR}/main.tex}"
SOURCE_PDF="${SOURCE_PDF:-}"
TARGET_REPO_URL="${TARGET_REPO_URL:-git@github.com:audreymhoughton/audreymhoughton.git}"
TARGET_BRANCH="${TARGET_BRANCH:-main}"
TARGET_FILE_PATH="${TARGET_FILE_PATH:-}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Update resume PDF}"
BUILD_RESUME="${BUILD_RESUME:-0}"

detect_source_pdf() {
  local explicit_source_pdf="$1"
  local latest_pdf=""
  local pdf

  if [[ -n "${explicit_source_pdf}" ]]; then
    echo "${explicit_source_pdf}"
    return 0
  fi

  shopt -s nullglob
  for pdf in "${ROOT_DIR}/${BUILD_OUTPUT_NAME}"_*.pdf; do
    if [[ -z "${latest_pdf}" || "${pdf}" -nt "${latest_pdf}" ]]; then
      latest_pdf="${pdf}"
    fi
  done
  shopt -u nullglob

  if [[ -n "${latest_pdf}" ]]; then
    echo "${latest_pdf}"
    return 0
  fi

  echo "${ROOT_DIR}/${BUILD_OUTPUT_NAME}.pdf"
}

detect_target_file_path() {
  local repo_dir="$1"
  local explicit_target_path="$2"
  local -a found_pdf_paths=()
  local found_count
  local line

  if [[ -n "${explicit_target_path}" ]]; then
    echo "${explicit_target_path}"
    return 0
  fi

  while IFS= read -r line; do
    [[ -n "${line}" ]] && found_pdf_paths+=("${line}")
  done < <(cd "${repo_dir}" && git ls-files "*.pdf")
  found_count="${#found_pdf_paths[@]}"

  if [[ "${found_count}" -eq 1 ]]; then
    echo "${found_pdf_paths[0]}"
    return 0
  fi

  if [[ "${found_count}" -gt 1 ]]; then
    echo "Error: multiple tracked PDFs found in target repo. Set TARGET_FILE_PATH explicitly." >&2
    printf 'Found PDFs:\n' >&2
    printf '  - %s\n' "${found_pdf_paths[@]}" >&2
    exit 1
  fi

  echo "resume.pdf"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' is not installed." >&2
    exit 1
  fi
}

print_usage() {
  cat <<'EOF'
Usage:
  scripts/sync-profile-resume.sh

Optional environment variables:
  TARGET_REPO_URL   Git URL for destination repository
  TARGET_BRANCH     Branch to push to (default: main)
  TARGET_FILE_PATH  Path inside destination repo for PDF.
                    If unset, auto-detects existing tracked PDF filename;
                    falls back to resume.pdf when none exists.
  COMMIT_MESSAGE    Commit message for sync commit
  BUILD_RESUME      1 to run latex build first, 0 to skip (default: 0)
  BUILD_OUTPUT_NAME Build output filename without extension (default: AudreyHoughton)
  SOURCE_TEX        Path to source .tex file (default: ./main.tex)
  SOURCE_PDF        Path to source .pdf file (default: latest ./AudreyHoughton_*.pdf)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  print_usage
  exit 0
fi

require_command git
require_command latexmk

source_pdf_is_explicit=0
if [[ -n "${SOURCE_PDF}" ]]; then
  source_pdf_is_explicit=1
fi

if [[ "${BUILD_RESUME}" == "1" ]]; then
  echo "Building resume PDF from ${SOURCE_TEX}..."
  latexmk -pdf -interaction=nonstopmode "${SOURCE_TEX}"

  if [[ "${source_pdf_is_explicit}" == "0" ]]; then
    SOURCE_PDF="$(detect_source_pdf "")"
  fi
fi

if [[ -z "${SOURCE_PDF}" ]]; then
  SOURCE_PDF="$(detect_source_pdf "")"
fi

if [[ ! -f "${SOURCE_PDF}" ]]; then
  echo "Error: source PDF not found at ${SOURCE_PDF}" >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

echo "Cloning target repository into temporary directory..."
git clone --branch "${TARGET_BRANCH}" --depth 1 "${TARGET_REPO_URL}" "${tmp_dir}/target"

TARGET_FILE_PATH="$(detect_target_file_path "${tmp_dir}/target" "${TARGET_FILE_PATH}")"
echo "Syncing to target file path: ${TARGET_FILE_PATH}"

mkdir -p "$(dirname "${tmp_dir}/target/${TARGET_FILE_PATH}")"
cp "${SOURCE_PDF}" "${tmp_dir}/target/${TARGET_FILE_PATH}"

pushd "${tmp_dir}/target" >/dev/null

if git diff --quiet -- "${TARGET_FILE_PATH}"; then
  echo "No changes detected in ${TARGET_FILE_PATH}; nothing to commit."
  exit 0
fi

git add "${TARGET_FILE_PATH}"
git commit -m "${COMMIT_MESSAGE}"
git push origin "${TARGET_BRANCH}"

popd >/dev/null

echo "Resume synced to ${TARGET_REPO_URL}:${TARGET_FILE_PATH}"
