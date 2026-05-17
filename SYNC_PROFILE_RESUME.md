# Sync Resume to Profile Repository

Run this from the resume repository root:

```bash
bash scripts/sync-profile-resume.sh
```

This will:

1. Build `AudreyHoughton.pdf` from `main.tex`
2. Clone your profile repo in a temporary folder
3. Copy the PDF to the existing tracked PDF path in that repo (or `resume.pdf` if none exists)
4. Commit and push if there is a change

## Optional custom settings

```bash
TARGET_REPO_URL=git@github.com:audreymhoughton/audreymhoughton.git \
TARGET_BRANCH=main \
TARGET_FILE_PATH=resume.pdf \
COMMIT_MESSAGE="Update resume" \
BUILD_RESUME=1 \
BUILD_OUTPUT_NAME=AudreyHoughton \
bash scripts/sync-profile-resume.sh
```

If `TARGET_FILE_PATH` is omitted, the script auto-detects the existing tracked PDF filename in the target repo.
If there are multiple tracked PDFs, it will stop and ask you to set `TARGET_FILE_PATH` explicitly.

## Skip LaTeX build

```bash
BUILD_RESUME=0 bash scripts/sync-profile-resume.sh
```

By default, the script expects `AudreyHoughton.pdf` as the local source PDF.
