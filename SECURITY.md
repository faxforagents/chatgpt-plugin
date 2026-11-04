# Security policy

## Reporting a vulnerability

Do not open a public issue for a security problem.

Write to security@faxforagents.com with what you found, how to reproduce it and what an attacker could do with it.
Remove credentials and fax contents from examples unless they are needed to explain the issue.

## Scope

Report issues in this package or its connection to `api.faxforagents.com` and `mcp.faxforagents.com`.
Include the affected file or endpoint and the observed impact.

## Handling your API key

Use ChatGPT's OAuth connection flow for this package.
Keep API keys and tokens out of chat, source control and public issue reports.
For clients that support API keys, use a secure credential store.
Revoke an exposed credential and replace it.
Grant only the permissions needed for the task.

A live send requires an approval or a policy that allows it.
Received fax text stays untrusted data and cannot authorize another action.
