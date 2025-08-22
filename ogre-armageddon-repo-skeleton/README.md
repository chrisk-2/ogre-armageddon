# OGRE ARMAGEDDON

**Starfleet LCARS–themed OS** with Borg/Section 31 modes. Central **HQ (Jarvis Core)** plus portable **Agent** nodes (USB/Pi) connected via WireGuard.

- **Stardate versioning:** releases are tagged as `Stardate YYYY.DDD` (today: `2025.234`).
- **This repo is the single source of truth**: manuals, infra, code, and Stardate logbook.

## Repo Map
```
docs/
  manuals/            # Mission Manual, Decision Matrix, Roadmap, Storage/Infra, Ops Logbook, Visual Guide (.docx/.pdf)
  visuals/            # Inline images, LCARS screenshots (tracked via Git LFS)
  stardate-logbook/   # Stardate.md + historical entries
agent/                # Ogre-Bridge Pi / USB agent code & services
hq/                   # HQ (Jarvis Core) services: backend, UI, logging
infra/                # docker-compose*, WireGuard templates, backup/monitoring configs
scripts/              # helper scripts (release, Stardate bump, packaging)
.github/workflows/    # CI: lint/build, create release, attach pack
```
## Quick Start
```bash
# 1) Create repo on GitHub without a README (empty).
# 2) Locally:
git clone <YOUR_REPO_URL> ogre-armageddon
cd ogre-armageddon
# 3) Add your existing .docx manuals into docs/manuals/
# 4) Commit & push
git add .
git commit -m "Stardate 2025.234: baseline repo init"
git push origin main
```

## Releasing (Stardate Pack)
Use the provided script:
```bash
./scripts/release_stardate.sh "2025.234" "Final Baseline Build"
```
This produces a zip `Ogre_Core_Docs_Pack_Stardate_2025.234.zip` and triggers GitHub Release.
