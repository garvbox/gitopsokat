# AGENTS.md

## General

- This is a Flux GitOps repo managing 2 clusters: `deltasite`, `oaklodge-gammatron`
- Dependency chain per cluster: `infra-core-install` -> `infrastructure` -> `apps`
- Default branch is `main` -- never commit to it directly

## Version Control

- Commit messages should be imperative and short (e.g. "Update sonarr to 4.0.18", "Add cert-manager ClusterIssuer for deltasite")
- Always ask before committing

## Validation

- After any manifest change, run `flux build kustomization` for each active cluster and layer (`infra-core-install`, `infrastructure`, `apps`) to confirm the kustomization still renders
- `flux build kustomization` is read-only and local; it does not affect the cluster

## Project conventions

### App layout
- `apps/base/<app>.yaml` -- generic HelmRelease using `bjw-s/app-template` chart
- `apps/<cluster>/<app>/` -- site-specific overlay with Kustomize patch, PVCs, and secrets
- New apps: add base YAML first, then per-cluster overlay if needed

### Infrastructure layout
- `infrastructure/core-install/` -- shared bootstrap (cert-manager, metallb)
- `infrastructure/base/` -- shared components (traefik, coredns, discord notifications, etc.)
- `infrastructure/extras/<component>/` -- optional components, wire into cluster via its kustomization.yaml
- `infrastructure/deltasite/` / `infrastructure/oaklodge-gammatron/` -- site-specific infra and secrets

### Clusters
- `clusters/<name>/flux-system/` -- Flux bootstrap manifests (auto-generated, do not edit manually)
- `clusters/<name>/infra-core-install.yaml` -- Flux Kustomization referencing core install
- `clusters/<name>/infrastructure.yaml` -- Flux Kustomization referencing site infra
- `clusters/<name>/apps.yaml` -- Flux Kustomization referencing site apps
- Do not edit `gotk-components.yaml` or any flux system component manually
- Secrets must be encrypted with SOPS (GPG for deltasite, Age for oaklodge-gammatron)

## YAML style

- Use `!reference` patches via `patchesStrategicMerge` rather than inline patches
- HelmRelease values use `${cluster_ext_domain}`, `${metallb_ip_*}` variables for substitution
- Prefer `bjw-s/app-template` chart for new apps unless a dedicated chart exists
- Use kebab-case for resource names
- Avoid adding unnecessary comments -- YAML is self-documenting with good naming
- Do not add section divider comments (e.g. `# --- Apps ---`)
