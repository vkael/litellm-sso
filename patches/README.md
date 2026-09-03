# LiteLLM fork patches

These patches keep the fork changes separate from the upstream source tree. Apply them from the repository root against the fork commit that removed `enterprise/`

```bash
./patches/apply.sh
```

To pull in the latest stable upstream release, drop `enterprise/` again, and reapply these patches on top, run:

```bash
./patches/update.sh
```

This adds an `upstream` remote pointing at `BerriAI/litellm` if it's not already there, fetches the latest `vX.Y.Z` tag, checks out that tree (leaving `patches/` untouched), updates the version note in the top-level `README.md`, and reruns `apply.sh`, which removes `enterprise/` and reapplies SSO patch. Review and commit the result afterward.

The SSO patch uses the existing generic OIDC flow. GitLab and other OIDC providers use the `GENERIC_*` settings, while Microsoft Azure AD uses the existing Microsoft settings

For GitLab, configure the OAuth application callback as `/sso/callback` and set:

```text
GENERIC_CLIENT_ID
GENERIC_CLIENT_SECRET
GENERIC_AUTHORIZATION_ENDPOINT=https://gitlab.com/oauth/authorize
GENERIC_TOKEN_ENDPOINT=https://gitlab.com/oauth/token
GENERIC_USERINFO_ENDPOINT=https://gitlab.com/oauth/userinfo
GENERIC_SCOPE=openid email profile
```

Use the corresponding authorization, token, and userinfo endpoints for a self-managed GitLab instance. Set `GENERIC_USER_*_ATTRIBUTE`, `GENERIC_ROLE_MAPPINGS_*`, and `GENERIC_TEAM_MAPPINGS_*` when the provider uses different claim names

For Azure AD, set `MICROSOFT_CLIENT_ID`, `MICROSOFT_CLIENT_SECRET`, and `MICROSOFT_TENANT`. The existing Microsoft endpoint override variables support compatible Azure environments
