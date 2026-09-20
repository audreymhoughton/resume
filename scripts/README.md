# Sync Resume to Profile Repository

Run this from the resume repository root:

```bash
bash scripts/sync-profile-resume.sh
```

By default, this will:

1. Use the existing local latest `AudreyHoughton_*.pdf` (no rebuild)
2. Clone your profile repo in a temporary folder
3. Copy the PDF to `AudreyHoughton_resume.pdf` in that repo
4. Commit and push if there is a change

## Optional custom settings

```bash
TARGET_REPO_URL=git@github.com:audreymhoughton/audreymhoughton.git \
TARGET_BRANCH=main \
TARGET_FILE_PATH=AudreyHoughton_resume.pdf \
COMMIT_MESSAGE="Update resume" \
BUILD_RESUME=1 \
BUILD_OUTPUT_NAME=AudreyHoughton \
bash scripts/sync-profile-resume.sh
```

If `TARGET_FILE_PATH` is omitted, it defaults to `AudreyHoughton_resume.pdf`.

## Rebuild Before Sync (Optional)

```bash
BUILD_RESUME=1 bash scripts/sync-profile-resume.sh
```

When rebuilding, output is date-stamped by default, for example:

`AudreyHoughton_05172026.pdf`

This behavior is controlled by the repository's `.latexmkrc`.

## Skip Build (Default)

```bash
BUILD_RESUME=0 bash scripts/sync-profile-resume.sh
```
