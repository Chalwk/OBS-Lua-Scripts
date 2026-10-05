# Contributing

Bugs, ideas, and pull requests are welcome.

## Reporting a bug

Open an issue and include:

- Which script is misbehaving
- Your OBS Studio version
- The exact steps that trigger the problem
- Any error output from the OBS script log
- Your OS

## Reporting a security issue

**Do not open a public issue for security problems.**

Use the private [Report a vulnerability](https://github.com/Chalwk/OBS-Lua-Scripts/security/advisories/new)
flow on the Security tab, or see [SECURITY.md](https://github.com/Chalwk/OBS-Lua-Scripts/blob/main/SECURITY.md)
for the full policy.

## Suggesting a script or feature

Open an issue describing the problem you're trying to solve, not the solution
you have in mind. That gives more room to suggest something simpler.

## Pull requests

Before opening a PR, make sure:

- The script loads cleanly in OBS Studio
- No external dependencies unless absolutely necessary, and if so, document
  them at the top of the script
- Script settings are exposed through the OBS script properties where relevant
- No hardcoded paths, secrets, or personal data
- You've tested the script on a clean OBS profile

## Code style

There's no enforced linter, but the house style is:

- 4-space indentation
- Clear variable names; avoid single-letter names outside loop counters
- Comment non-obvious OBS API calls
- Keep each script focused on a single purpose

## Questions

Open a [GitHub Discussion](https://github.com/Chalwk/OBS-Lua-Scripts/discussions)
or find me on [Discord](https://discord.gg/VAEb4FXU5).
