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
         "websiteURL", "supportURL", "privacyPolicyURL", "termsOfServiceURL", "logo", "composerIcon"), "interface")
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
    require(interface["category"] == "Productivity", "Unexpected category")
    require(extension["onboardingSkill"] == "./skills/setup/SKILL.md", "Unexpected setup skill path")
    for path in (interface["logo"], interface["composerIcon"], extension["onboardingSkill"]):
        require(Path(path).is_file(), f"Missing package file: {path}")
    logo = Path(interface["logo"]).read_bytes()
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

    skill = Path(extension["onboardingSkill"]).read_text()
    require(re.match(r"\A---\nname: setup\ndescription: [^\n]+\n---\n", skill), "Setup skill needs name and description frontmatter")
except (OSError, ValueError, TypeError, KeyError) as error:
    print(f"Validation failed: {error}", file=sys.stderr)
    sys.exit(1)

print("Package validation passed.")
PY
