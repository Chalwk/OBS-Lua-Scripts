# Security Policy

OBS-Lua-Scripts is a collection of Lua scripts for OBS Studio. This document
explains how to report a vulnerability and what to expect.

## Supported Versions

Fixes are applied to the latest version on `main`.

| Version          | Supported |
| ---------------- | --------- |
| Latest on `main` | Yes       |
| Older commits    | No        |
| Forks            | No        |

## Reporting a Vulnerability

**Please do not open a public issue for security problems.**

1. **GitHub Private Vulnerability Reporting** (preferred). Use the
   [Report a vulnerability](https://github.com/Chalwk/OBS-Lua-Scripts/security/advisories/new)
   button on the Security tab.
2. **Email**. Email [chalwk.dev@gmail.com](mailto:chalwk.dev@gmail.com) with
   "SECURITY" in the subject line.

### What to include

- The script name
- A clear description of the issue
- Steps to reproduce
- The impact you believe it has
- Your OBS Studio version

Redact any real API keys, tokens, or personal data from what you send.

## Scope

### In scope

- Scripts that execute unexpected shell commands or load external code
- Hardcoded secrets or API keys
- File writes outside the expected OBS config or script data directories
- Network calls that leak stream keys or credentials
- Unsafe handling of user-supplied input from OBS script properties

### Out of scope

- Issues in OBS Studio itself (report those upstream)
- Issues in third-party plugins or Lua libraries
- Cosmetic bugs or feature requests
- Findings from automated scanners with no demonstrated impact

## What to expect

- **Acknowledgement:** within 7 days
- **Initial assessment:** within 14 days
- **Fix:** usually within 30 days for confirmed issues
- **Public disclosure:** coordinated with you

## Using these scripts safely

- Read any script before adding it to OBS.
- Check what files and network endpoints it touches.
- Don't paste secrets into script properties. Use environment variables or a
  config file.
- Keep OBS Studio up to date.

## Automated security

- Dependabot alerts and security updates
- Secret scanning with push protection
