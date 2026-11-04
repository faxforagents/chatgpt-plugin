# Fax for Agents package

Built version 1.0.0 for `faxforagents/chatgpt-plugin` on 2026-11-04.

The package includes `plugin.json`, `mcp.json`, the supplied logo and `skills/setup/SKILL.md`.
It also includes the README, MIT licence, security policy, changelog, ignore rules and executable validator.
The supplied description appears verbatim in both description fields.
The README lists all 15 supplied tool names, including `get_fax_document`.
The commit message is in `.coding-agent/commit-message.txt`.

The setup skill starts with Sandbox and requires approved permissions before sending.
It covers human review, status, provider evidence and untrusted received text.
Credentials stay outside the package and chat.

## Sources and verified fields

Read these exact requested URLs over the network:

| Requested URL | Fields or requirements verified |
|---|---|
| https://developers.openai.com/plugins/build/plugins | Root `plugin.json` and `mcp.json`, `$schema`, `name`, `version`, `description`, `extensions`, `com.openai`, `interface`, `onboardingSkill`. Server fields `mcpServers`, `type`, `url`, `auth`, `client`, `mode`. |
| https://developers.openai.com/plugins/plugin-guidelines | Brand naming, accurate listing text, account access rules, permissions and treatment of untrusted content. |
| https://developers.openai.com/apps-sdk/deploy/submission | `author.name`, `homepage`, `displayName`, `shortDescription`, `longDescription`, `developerName`, `category`, `websiteURL`, `supportURL`, `privacyPolicyURL`, `termsOfServiceURL`, `logo`, `composerIcon`. |
| https://developers.openai.com/apps-sdk/build/auth | `resource`, `authorization_servers`, `client_id_metadata_document_supported`, `registration_endpoint`, `code_challenge_methods_supported` and S256. |

The submission URL redirects to https://developers.openai.com/plugins/deploy/submission.
The authentication URL redirects to https://developers.openai.com/plugins/build/auth.
Fetched the Markdown version of each page by appending `.md`.
The browser tool rejected that content type, so Python retrieved those versions successfully.

Also fetched the linked schemas:

| URL | Result |
|---|---|
| https://agent-plugins.org/schemas/1.0.0/plugin.schema.json | The manifest passes this schema. `author` is an object. No root `icon` field exists. |
| https://agent-plugins.org/schemas/1.0.0/mcp.schema.json | The generic schema rejects the per-server `extensions` documented by OpenAI. |

## Format decisions

The stable package identifier is `fax-for-agents`. The display name is `Fax for Agents`.
The subtitle uses `shortDescription`.
Both `logo` and `composerIcon` reference `./logo.png`.
The four listing URLs belong in `extensions["com.openai"].interface`.
The field reference has no listing documentation URL field. The README links to the supplied documentation URL.

The MCP entry uses `type: "streamable-http"` and the exact supplied server URL.
Its `extensions["com.openai"].auth` is `{"type": "mixed", "client": {"mode": "cimd"}}`.
The names match OpenAI's guide.
OpenAI defines `mixed` as public and OAuth access. It does not combine OAuth with fixed API keys.
The README explains that ChatGPT uses OAuth and has no custom API-key connection flow.
The generic MCP schema mismatch is documented. The local validator checks the documented OpenAI extension directly.

The documented custom connection labels are "Add custom MCP server" and "Create as a plugin".
The README explains the difference from the requested "Add custom plugin" label.
It also distinguishes connecting the server URL from installing the bundled skill.
Directory installation is conditional on the listing being available.

## Sibling conventions

Read the sibling README, licence, security policy and both workflows.
Kept the centered logo, title, pitch, navigation row and badge arrangement.
Adapted the title and links to this repository and used the supplied local logo.
Omitted the commercial navigation entry under the package content rule.
No answer arrived to the optional question about that conflicting header requirement before completion.
The sibling GitLab link has no established destination for this repository, so it was omitted.

Copied the MIT licence byte for byte, including its standard legal terms.
Kept the security policy structure and used `security@faxforagents.com`.
Omitted sibling service promises and detailed credential behavior absent from the supplied product facts.

CI keeps the sibling's events, read-only permissions, pinned action, runner and concurrency behavior.
One job runs the package validator. Claude-specific checks do not apply to this package.
The sibling mirror workflow was not copied because it publishes to a separate repository and requires an external secret.

## Verification

Commands below ran from this repository unless stated otherwise.
Inline Python checks used `python3 -` with a heredoc.

| Command or check | Last output or result |
|---|---|
| Python retrieval of the four Markdown pages | `Saved all four OpenAI documentation pages.` |
| `sh scripts/validate.sh` | `Package validation passed.` |
| `bash -n scripts/validate.sh` | No output, exit 0. |
| `cmp LICENSE ../claude-code-plugin/LICENSE` | No output, exit 0. |
| Python schema and workflow checks | `Workflow YAML parsed. Shell syntax and sibling licence checks passed.` |
| Python temporary-package checks | `Validator passed from another directory and rejected 9 invalid package cases.` |
| Python product copy checks | `Verbatim description, 15 tool names, copy rules and commit message checks passed.` |
| `git diff --check` | No output, exit 0. All package files are new and untracked. |
| `git log --oneline -20` | `fatal: your current branch 'master' does not have any commits yet` |

The temporary-package checks removed required nested fields, broke JSON, repeated a field, inserted NaN and removed the logo.
Each invalid package failed with a validation error.
The valid copy also passed when invoked outside the repository.

The first copy check mistook the technical word "checkout" for a transaction reference.
The corrected check checks links for transaction destinations and passes.
The supplied legal text was excluded from promotional-language checks.

Writing checks ran with:

```bash
python3 /home/ben/.agents/skills/human-writing/scripts/hw_lint.py -c docs --allow 'align="center"' --allow 'API-key connection' --allow 'API-key support' README.md SECURITY.md CHANGELOG.md skills/setup/SKILL.md
python3 /home/ben/.agents/skills/human-writing/scripts/hw_lint.py -c commit .coding-agent/commit-message.txt
```

The last lines reported zero BLOCK and zero FIX results.
The remaining CHECK results concern real workflow lists, the ChatGPT proper noun and the inherited header structure.
The allow entries preserve an HTML attribute and technical API terminology.
An initial run flagged those same literal terms before the allow entries were supplied.

## CI audit

Ran the required audit before adding the workflow and again after writing it:

```bash
python3 /home/ben/.agents/skills/ci-speedup/scripts/run.py --root . --repo faxforagents/chatgpt-plugin --out /tmp/faxforagents-ci-before.json
python3 /home/ben/.agents/skills/ci-speedup/scripts/run.py --root . --repo faxforagents/chatgpt-plugin --out /tmp/faxforagents-ci-after.json
```

Both attempts failed to fetch the GitHub workflow list.
Both ended by printing a report-render command. No measured CI savings are available.
Rendered both reports with `scripts/blocking_path.py` and checked them with `tests/verify_report.py` from the ci-speedup skill.
Both report checks returned exit 0. Their final text was "all checks passed" after a status symbol.
Those checks validate the reports' disclosures. They do not establish successful GitHub execution.

The static scan flagged missing path filters.
Two independent reviewers rejected the unproven assumption that this validator is expensive.
It uses Python's standard library with no installation or network calls.
Kept the existing trigger shape because required-check settings and measured durations are unavailable.

## Limits

No authenticated ChatGPT installation, OAuth round trip or fax send was performed.
No GitHub Actions run or directory submission was performed.
Publication still requires OpenAI's review flow and an authenticated integration test.
No commit or push was made.
