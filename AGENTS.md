# Global Coding Preferences

These preferences apply to coding tasks unless a repository-level instruction
or the current user request says otherwise.

- Do not create overloads unless explicitly requested.
- Do not create backward-compatible wrapper APIs, aliases, or convenience
  variants unless explicitly requested.
- Prefer one explicit, narrowly named API and update current call sites
  directly.
- For random/noise-dependent algorithms, require explicit RNG/seeding from the
  caller; do not add hidden default RNG helpers unless explicitly requested.
