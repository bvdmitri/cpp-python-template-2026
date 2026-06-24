# Security Policy

## Reporting a vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, use **[GitHub's private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)**
(the "Report a vulnerability" button under the repository's *Security* tab), or
email the maintainers at `security@example.com`.

Please include:
- a description of the vulnerability and its impact,
- steps to reproduce (ideally a minimal example),
- affected version(s) / commit.

You can expect an acknowledgement within **48 hours** and a more detailed
response within a week, including a remediation timeline. We will credit you in
the release notes unless you prefer to remain anonymous.

## Supported versions

While `0.x`, only the latest released minor version receives security fixes.
Once `1.0` is reached, this section will list the supported version range.

## Scope

This library performs no I/O, networking, or cryptography in its current form. As
the API grows, keep this policy and the threat model up to date.
