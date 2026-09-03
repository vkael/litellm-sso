> This is a fork of [BerriAI/litellm](https://github.com/BerriAI/litellm.git) that blindly follows upstream, currently synced to [v1.99.1](https://github.com/BerriAI/litellm/releases/tag/v1.99.1). It carries no changes of its own beyond dropping the non-MIT `enterprise/` folder and the SSO patches in [`patches/`](patches/), which are reapplied on top of every upstream sync. See the [original README](https://github.com/BerriAI/litellm/blob/v1.99.1/README.md) for the unmodified project docs.

# Build

## non-root

`podman build  -f docker/Dockerfile.non_root -t litellm-sso:v1.99.1-non-root-sso`

## root

`podman build  -f Dockerfile -t litellm-sso:v1.99.1-sso`

---
