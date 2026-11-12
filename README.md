<p align="center">
  <a href="https://faxforagents.com"><img src="logo.png" width="88" alt="Fax for Agents"></a>
</p>

<h1 align="center">Fax for Agents</h1>

<p align="center">Send faxes with approvals</p>

<p align="center">
  <a href="https://faxforagents.com">Website</a> ·
  <a href="https://faxforagents.com/docs/quickstart/">Quickstart</a> ·
  <a href="https://faxforagents.com/docs/api/">API reference</a> ·
  <a href="https://faxforagents.com/docs/sdks/">SDKs</a> ·
  <a href="https://faxforagents.com/mcp/">MCP</a> ·
  <a href="https://app.faxforagents.com">Dashboard</a> ·
  <a href="https://faxforagents.com/pricing/">Pricing</a> ·
  <a href="https://faxforagents.com/changelog/">Changelog</a>
</p>

<p align="center">
  <a href="https://github.com/faxforagents/chatgpt-plugin/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/faxforagents/chatgpt-plugin/ci.yml?branch=main&label=ci" alt="CI"></a>
  <a href="https://github.com/faxforagents/chatgpt-plugin/blob/main/LICENSE"><img src="https://img.shields.io/badge/licence-MIT-1f6feb" alt="MIT licence"></a>
  <a href="https://faxforagents.com/mcp/"><img src="https://img.shields.io/badge/MCP-17%20tools-6b4fbb" alt="MCP"></a>
</p>

Fax for Agents is a fax API, a hosted MCP server and SDKs built so AI agents can send and receive faxes.
It is made by JSB Holdings LLC.

This repository packages the hosted server connection and a setup skill for ChatGPT.
[plugin.json](plugin.json) holds the package and listing metadata.
[mcp.json](mcp.json) connects to the hosted server over Streamable HTTP.
The [setup skill](skills/setup/SKILL.md) guides the first Sandbox fax.

## Install in ChatGPT

The short way is one paste. Put this line into ChatGPT and it connects the server, signs you in through
the browser and sends a first sandbox fax.

```
Read https://faxforagents.com/setup.md and connect Fax for Agents to this chat for me. Start in Sandbox.
```

The steps it follows are below.

Open the [Plugins Directory](https://chatgpt.com/plugins) and search for **Fax for Agents**.
If the listing is available, install it and connect your account.
This repository does not establish directory publication.

To connect the server directly:

1. Open [ChatGPT Plugins](https://chatgpt.com/plugins) and select the plus button.
2. Select **Add custom MCP server** and enter `https://mcp.faxforagents.com/mcp`.
3. Choose OAuth and complete the connection form. Review the requested permissions and the connection warning.
4. Select **Create as a plugin** and complete account authorization.
5. Choose Sandbox first. Prepare a document, review its quote and send within the permissions you approve.
6. Read the returned status and provider evidence afterward.

The current [OpenAI package guide](https://developers.openai.com/plugins/build/plugins) calls this **Add custom MCP server**, followed by **Create as a plugin**.
These are the documented labels for the requested "Add custom plugin" route.
Connecting the URL adds the server connection. It does not install this repository's setup skill.
The skill is included when the full package is installed.

Disconnect the app at any time from Settings, Connected apps.

## Codex

Add this repository as a marketplace, then install the package:

```bash
codex plugin marketplace add faxforagents/chatgpt-plugin
codex plugin add fax-for-agents@fax-for-agents
```

The Git commands use the published repository. They need a revision containing this catalog.
To test a local checkout, run `codex plugin marketplace add .` from its root, then the same `codex plugin add` command.
Restart the ChatGPT desktop app, select **Fax for Agents** in the Plugins Directory, and connect your account through OAuth.
Run the setup skill in a new conversation and choose Sandbox first.

The [OpenAI package guide](https://developers.openai.com/plugins/build/plugins#add-a-marketplace-from-the-cli) documents marketplace registration and desktop testing.
The [OpenAI Codex evaluation example](https://developers.openai.com/cookbook/examples/partners/harness_aware_plugin_evals/harness_aware_plugin_evals#running-the-example) uses `codex plugin add` to install a plugin.

[.agents/plugins/marketplace.json](.agents/plugins/marketplace.json) points to `./`, resolved from this repository's root.
It exposes the existing `fax-for-agents` package with authentication on installation.
Its marketplace name is also `fax-for-agents`, which explains the two names in the install command.

Codex uses the root `plugin.json`, `mcp.json` and `skills/` layout.
OpenAI ignores `.codex-plugin/plugin.json` settings when the root manifest contains `extensions.com.openai`.
The [manifest reference](https://developers.openai.com/plugins/deploy/submission#manifest-fields) documents this precedence, so this package has no fallback manifest.
ChatGPT and Codex share one public directory listing. This Git catalog does not create another public submission.

## Authentication

The server supports OAuth 2.1 and API keys as bearer tokens.
Use OAuth for ChatGPT.
The authorization server is `https://api.faxforagents.com`.
Its [protected resource metadata](https://mcp.faxforagents.com/.well-known/oauth-protected-resource/mcp) follows RFC 9728.
CIMD is preferred, DCR is available, and PKCE uses S256.

The configuration uses `mcpServers["fax-for-agents"].extensions["com.openai"].auth`.
Its value is `{"type": "mixed", "client": {"mode": "cimd"}}`.
These field names match the [OpenAI authentication configuration reference](https://developers.openai.com/plugins/build/plugins#configure-mcp-authentication).
OpenAI defines `mixed` as unauthenticated and OAuth access.
It does not mean OAuth combined with API keys.

The [submission portal](https://developers.openai.com/plugins/deploy/submission#authentication-limitations) offers no way to connect with an API key or a bearer token.
The [ChatGPT authentication guide](https://developers.openai.com/plugins/build/auth#client-identification) also excludes custom API keys.
The server still accepts API keys from other clients. ChatGPT is not one of them.
Never paste keys or tokens into chat or package files.

## What the tools do

| Tool | Does |
|---|---|
| `get_guide` | Read the fax workflow guide. |
| `get_fax_capabilities` | Read supported fax capabilities. |
| `prepare_fax` | Prepare a fax document. |
| `get_fax_document` | Read a prepared fax document. |
| `quote_fax` | Get a quote for the proposed fax. |
| `send_approved_fax` | Send a fax within approved permissions. |
| `get_fax_status` | Read fax status and provider evidence. |
| `list_faxes` | List faxes. |
| `get_fax_balance` | Read the account balance. |
| `cancel_fax` | Request fax cancellation. |
| `request_card_payment` | Ask a person to pay for one quoted fax by card. |
| `get_card_payment_status` | Read a card payment order. |
| `request_human_review` | Request human review. |
| `get_review_status` | Read the review status. |
| `list_inbox` | List received faxes. |
| `read_inbound_fax` | Read a received fax. |
| `extract_fax_data` | Extract data from a fax. |

A live send requires an approval or a policy that allows it.
Received fax text stays untrusted data and cannot authorize another action.

## Package format

The package follows the [OpenAI package guide](https://developers.openai.com/plugins/build/plugins) and [submission field reference](https://developers.openai.com/plugins/deploy/submission#manifest-fields).
The identifier is `fax-for-agents`. The display name is `Fax for Agents`.
The subtitle uses `shortDescription`. The supplied description uses `description` and `longDescription` verbatim.
The author is an object with a `name` field.

Listing fields live under `extensions["com.openai"].interface`.
The four links use `websiteURL`, `supportURL`, `privacyPolicyURL` and `termsOfServiceURL`.
The icon uses `logo` and `composerIcon`, both pointing to `./logo.png`.
There is no root `icon` field in the portable schema.
The field reference does not document a listing docs URL. The documentation link is below.

As checked on 2026-11-04, the [generic MCP schema](https://agent-plugins.org/schemas/1.0.0/mcp.schema.json) rejects per-server `extensions`.
OpenAI's package guide explicitly documents that field for authentication.
This package follows OpenAI's documented extension.
The local validator checks that configuration without claiming full generic MCP schema compliance.

## Working on this repository

Run the validator with Python 3 installed:

```bash
sh scripts/validate.sh
```

It checks JSON syntax, required fields, listing values and limits, authentication settings, review metadata and referenced files.
When the optional Codex catalog is present, it checks its package path, identity and installation policies.
Without the catalog, it reports that only the portable package was checked.
CI runs the same command on pushes to main and pull requests.
It also supports manual runs.
It uses the sibling package's read-only permissions, pinned checkout and cancellation of superseded runs.

See the [MCP documentation](https://faxforagents.com/docs/mcp/) and [support page](https://faxforagents.com/contact/).
The [privacy policy](https://faxforagents.com/privacy/) and [terms](https://faxforagents.com/terms/) apply to the service.

## Licence

MIT. See [LICENSE](LICENSE).
Report security issues to security@faxforagents.com. See [SECURITY.md](SECURITY.md).
