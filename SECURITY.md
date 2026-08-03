# Security Policy

## Supported Versions

Security updates are applied on the active main branch.

| Branch | Supported          |
| ------ | ------------------ |
| main   | :white_check_mark: |
| others | :x:                |

## Reporting a Vulnerability

Report vulnerabilities privately to the maintainers through a private channel.

Please include:

- Affected feature and platform (Android, iOS, web, desktop)
- Reproduction steps
- Potential impact
- Suggested mitigation if available

Expected response timeline:

- Initial acknowledgement: within 72 hours
- Triage decision: within 7 days
- Fix window: based on severity and release impact

## Secret Management Rules

- Do not commit passwords, API keys, tokens, keystores, or certificate files.
- Rotate any credential immediately if it was shared in chat, email, or commit history.
- Keep local secrets in `.env` files (ignored by git) and only commit `.env.example` placeholders.
