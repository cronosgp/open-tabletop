# Security Policy

## Supported versions

Open Tabletop is currently a pre-release prototype. Only the latest `main`
branch is supported.

| Version | Supported |
| --- | --- |
| `main` (prototype) | :white_check_mark: |
| Older tags/branches | :x: |

## Reporting a vulnerability

Please **do not** open a public issue for security vulnerabilities.

Instead, report them privately so they can be addressed before disclosure:

1. Use GitHub's private vulnerability reporting on the
   [Security tab](https://github.com/cronosgp/open-tabletop/security), or
2. Contact the maintainers directly through the repository.

Include:

- A description of the vulnerability and its impact.
- Steps to reproduce, or a proof of concept if available.
- The affected code paths or versions.

## Scope

Security reports are welcome for issues that affect the confidentiality,
integrity, or availability of the application or its users, for example:

- The authoritative host's validation and state replication.
- The session/challenge mechanism (`scripts/session_seat.gd`).
- Persistence, journal integrity, and save validation (`scripts/match_save.gd`,
  `scripts/match_journal.gd`).
- Networking and remote command handling.

Please note the project's stated boundary: the host is authoritative and is not
designed to protect against a malicious host.

## Disclosure

We aim to acknowledge reports promptly and to coordinate a fix and disclosure
with the reporter. This project has no formal SLA while it remains a prototype.
