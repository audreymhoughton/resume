# Resume Repository

This repository contains the LaTeX source and generated PDF for Audrey Houghton's resume.

## Files

- `main.tex`: Resume source
- `AudreyHoughton_MMDDYYYY.pdf`: Generated resume PDF (date-stamped)
- `scripts/sync-profile-resume.sh`: Syncs your resume PDF to your GitHub profile repo

## Build

Build the PDF directly:

```bash
latexmk -pdf -interaction=nonstopmode main.tex
```

The repository's `.latexmkrc` automatically:

- Writes output as `AudreyHoughton_MMDDYYYY.pdf`
- Deletes older `AudreyHoughton_*.pdf` files after a successful build

## Sync to Profile Repo

See `scripts/README.md` for full usage and options.
