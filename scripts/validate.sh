#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

python3 - <<'PY'
import json
from pathlib import Path
import re
import struct
import sys


def require(condition, message):
    if not condition:
        raise ValueError(message)


def object_fields(value, fields, label):
    require(isinstance(value, dict), f"{label} must be an object")
    for field in fields:
        require(field in value, f"{label}.{field} is required")
    return value


def text_field(value, limit, label, single_line=False):
    require(isinstance(value, str) and bool(value.strip()) and len(value) <= limit,
            f"{label} must contain 1 to {limit} characters")
    require(not single_line or value.splitlines() == [value], f"{label} must fit on one line")


def load(name):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            require(key not in result, f"{name}: duplicate field {key}")
            result[key] = value
        return result

    def invalid_constant(value):
        raise ValueError(f"{name}: invalid JSON constant {value}")

    return json.loads(Path(name).read_text(), object_pairs_hook=unique,
                      parse_constant=invalid_constant)


try:
    plugin = object_fields(load("plugin.json"),
        ("$schema", "name", "description", "version", "author", "homepage", "extensions"), "plugin")
    require(plugin["$schema"] == "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json", "Unexpected plugin schema")
    require(plugin["name"] == "fax-for-agents", "Unexpected package name")
    require(re.fullmatch(r"\d+\.\d+\.\d+", str(plugin["version"])) is not None, "Unexpected version")
    author = object_fields(plugin["author"], ("name",), "author")
    require(author["name"] == "JSB Holdings LLC", "Unexpected author")
    require(plugin["homepage"] == "https://faxforagents.com/", "Unexpected homepage")
    extension = object_fields(plugin["extensions"], ("com.openai",), "extensions")["com.openai"]
    object_fields(extension, ("interface", "onboardingSkill"), "com.openai")
    interface = object_fields(extension["interface"],
        ("displayName", "shortDescription", "longDescription", "developerName", "category",
         "websiteURL", "supportURL", "privacyPolicyURL", "termsOfServiceURL", "logo", "composerIcon",
         "capabilities"), "interface")
    expected = {
        "displayName": "Fax for Agents",
        "shortDescription": "Send faxes with approvals",
        "developerName": "JSB Holdings LLC",
        "websiteURL": "https://faxforagents.com/",
        "supportURL": "https://faxforagents.com/contact/",
        "privacyPolicyURL": "https://faxforagents.com/privacy/",
        "termsOfServiceURL": "https://faxforagents.com/terms/",
        "logo": "./logo.png",
        "composerIcon": "./logo.png",
    }
    for field, value in expected.items():
        require(interface[field] == value, f"Unexpected interface.{field}")
    require(isinstance(plugin["description"], str) and 0 < len(plugin["description"]) <= 4000,
            "Description must contain 1 to 4000 characters")
    require(interface["longDescription"] == plugin["description"], "Descriptions must match")
    for field, limit in (("displayName", 30), ("shortDescription", 30), ("developerName", 80)):
        text_field(interface[field], limit, f"interface.{field}", single_line=True)
    capabilities = interface["capabilities"]
    require(isinstance(capabilities, list) and len(capabilities) <= 20, "Expected at most 20 capabilities")
    for capability in capabilities:
        text_field(capability, 120, "Capability", single_line=True)
    require(interface["category"] == "Productivity", "Unexpected category")
    require(extension["onboardingSkill"] == "./skills/setup/SKILL.md", "Unexpected setup skill path")
    for path in (interface["logo"], interface["composerIcon"], extension["onboardingSkill"]):
        require(Path(path).is_file(), f"Missing package file: {path}")
    logo = Path(interface["logo"]).read_bytes()
    require(len(logo) <= 5 * 1024 * 1024, "Logo must not exceed 5 MiB")
    require(logo[:8] == b"\x89PNG\r\n\x1a\n" and len(logo) >= 24, "Logo must be a PNG")
    require(struct.unpack(">II", logo[16:24]) == (512, 512), "Logo must be 512 by 512")

    mcp = object_fields(load("mcp.json"), ("$schema", "mcpServers"), "mcp")
    require(mcp["$schema"] == "https://agent-plugins.org/schemas/1.0.0/mcp.schema.json", "Unexpected MCP schema")
    servers = object_fields(mcp["mcpServers"], ("fax-for-agents",), "mcpServers")
    require(len(servers) == 1, "Expected one hosted server")
    server = object_fields(servers["fax-for-agents"], ("type", "url", "extensions"), "server")
    require(server["type"] == "streamable-http", "Unexpected transport")
    require(server["url"] == "https://mcp.faxforagents.com/mcp", "Unexpected server URL")
    require(not server.get("headers"), "Do not embed credential headers")
    auth_extension = object_fields(server["extensions"], ("com.openai",), "server.extensions")["com.openai"]
    auth = object_fields(auth_extension, ("auth",), "server.com.openai")["auth"]
    require(auth == {"type": "mixed", "client": {"mode": "cimd"}}, "Expected mixed authentication with CIMD")

    review = object_fields(extension.get("review"),
        ("test_cases", "commerce", "commerce_description"), "review")
    cases = object_fields(review["test_cases"], ("positive", "negative"), "review.test_cases")
    for kind, count in (("positive", 5), ("negative", 3)):
        require(isinstance(cases[kind], list) and len(cases[kind]) == count,
                f"Expected {count} {kind} review cases")
        for case in cases[kind]:
            fields = ("description", "prompt", "expected_behavior")
            if kind == "positive":
                fields += ("tools_triggered",)
            object_fields(case, fields, f"{kind} case")
            for field in fields:
                require(isinstance(case[field], str) and bool(case[field].strip()),
                        f"{kind} case.{field} must be non-empty text")
            text_field(case["description"], 4000, f"{kind} case.description")
    require(review["commerce"] is False, "Unexpected commerce declaration")
    require(isinstance(review["commerce_description"], str) and bool(review["commerce_description"].strip()),
            "Expected commerce explanation")
    require("test_credentials" not in review and "reviewer_instructions" not in review,
            "Reviewer access belongs in the secure dashboard")
    publication = object_fields(extension.get("publication"), ("release_notes",), "publication")
    require(isinstance(publication["release_notes"], str)
            and plugin["version"] in publication["release_notes"], "Release notes must describe the current version")
    require(f"## {plugin['version']}" in Path("CHANGELOG.md").read_text(), "Missing changelog entry")

    # The portable package also works without an optional Git marketplace.
    catalog_path = Path(".agents/plugins/marketplace.json")
    if catalog_path.exists():
        catalog = object_fields(load(catalog_path), ("name", "interface", "plugins"), "marketplace")
        require(catalog["name"] == "fax-for-agents", "Unexpected marketplace name")
        catalog_interface = object_fields(catalog["interface"], ("displayName",), "marketplace.interface")
        require(catalog_interface["displayName"] == interface["displayName"], "Marketplace display name must match")
        require(isinstance(catalog["plugins"], list) and len(catalog["plugins"]) == 1,
                "Expected one marketplace plugin")
        entry = object_fields(catalog["plugins"][0], ("name", "source", "policy", "category"), "marketplace plugin")
        require(entry["name"] == plugin["name"], "Marketplace plugin name must match")
        require(entry["category"] == interface["category"], "Marketplace category must match")
        source = object_fields(entry["source"], ("source", "path"), "marketplace source")
        require(source == {"source": "local", "path": "./"}, "Marketplace must point to this package at ./")
        require((Path(source["path"]) / "plugin.json").resolve() == Path("plugin.json").resolve(),
                "Marketplace must resolve from the repository root")
        require(entry["policy"] == {"installation": "AVAILABLE", "authentication": "ON_INSTALL"},
                "Expected available installation with authentication on install")
        print("Codex marketplace validation passed.")
    else:
        print("Codex marketplace absent. Validating the portable package only.")

    skill = Path(extension["onboardingSkill"]).read_text()
    require(re.match(r"\A---\nname: setup\ndescription: [^\n]+\n---\n", skill), "Setup skill needs name and description frontmatter")
except (OSError, ValueError, TypeError, KeyError) as error:
    print(f"Validation failed: {error}", file=sys.stderr)
    sys.exit(1)

print("Package validation passed.")
PY
