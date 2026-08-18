# Tuist Agent Plugin

An [Agent Plugin](https://agent-plugins.org) for [Tuist](https://tuist.dev), the infrastructure that speeds up build and test toolchains. It bundles Agent Skills for common Tuist workflows together with the Tuist MCP server, so coding agents can read the build, test, bundle, and cache data your toolchain reports and act on it.

Tuist plugs into the Xcode and Gradle projects you already have. Generated projects are one of its features, not a prerequisite, so most of what this plugin offers applies whatever your project layout looks like.

Agent Plugins is an open, vendor-neutral standard for packaging reusable agent components. Packaging the skills and the MCP server together means one install wires up both, in any client that speaks the standard.

## What's inside

```text
agent-plugin/
├── plugin.json   # Plugin manifest (Agent Plugins 1.0.0)
├── mcp.json      # Tuist's remote MCP server
└── skills/       # Agent Skills
```

### Skills

| Skill | Description |
| --- | --- |
| `migrate` | Migrates existing Xcode projects to Tuist generated workspaces, with build and run validation, external dependency mapping, and migration checklists. |
| `generated-projects` | Guides day-to-day work in generated workspaces: generation, build and test commands, and buildable folders. |
| `debug-generated-project` | Reproduces and triages issues with generated projects, building Tuist from source when needed. |
| `fix-flaky-tests` | Analyzes failure patterns from Tuist test insights, identifies root causes, and applies targeted corrections. |
| `analyze-selective-testing` | Explains which test targets were skipped or ran for a test run, and diagnoses regressions in test selection. |
| `compare-builds` | Compares two Xcode build runs for duration regressions, cache changes, and new issues. |
| `compare-gradle-builds` | Compares two Gradle build runs for duration regressions, cache changes, and task outcome differences. |
| `compare-test-runs` | Compares two test runs for new failures, newly flaky tests, fixed tests, and duration regressions. |
| `compare-test-case` | Compares a single test case's behavior across two branches: status, duration, flakiness, and failure details. |
| `compare-bundles` | Compares two app bundles for size changes, new or removed artifacts, and platform differences. |
| `compare-generations` | Compares two `tuist generate` runs for cache hit rate changes and cache invalidation root causes. |
| `compare-cache-runs` | Compares two `tuist cache` runs for cache effectiveness changes and target-level regressions. |

Skills that read project data (everything except `migrate`, `generated-projects`, and `debug-generated-project`) need either the [Tuist CLI](https://tuist.dev/en/docs/guides/install-tuist) authenticated against your account, or the MCP server below.

### MCP server

`mcp.json` declares Tuist's remote MCP server at `https://tuist.dev/mcp` over Streamable HTTP. It exposes read-only tools for projects, Xcode and Gradle builds, test runs and test cases, bundles, generations, and cache runs, plus account setup tools for creating organizations and projects.

The endpoint uses the `mcp` scope group, which grants read-only access to your projects. Tuist advertises OAuth discovery metadata as well as an `auth.md` file at `https://tuist.dev/auth.md`, so clients can authenticate in the browser, and agents that support `auth.md` can register without one. See the [MCP documentation](https://tuist.dev/en/docs/guides/features/agentic-coding/mcp) for the full tool and prompt reference.

## Installation

### Clients that support Agent Plugins

Point your client at this repository. It will read `plugin.json`, load every skill under `skills/`, and register the MCP server from `mcp.json`.

```bash
git clone https://github.com/tuist/agent-plugin.git
```

Consult your client's documentation for where to place or reference a plugin directory.

### Skills only

If your agent supports Agent Skills but not Agent Plugins yet, install the skills with the [`skills`](https://github.com/vercel-labs/skills) CLI, which detects your agents and places the `SKILL.md` files in the right location:

```bash
npx skills add tuist/agent-skills
```

The [tuist/agent-skills](https://github.com/tuist/agent-skills) repository holds the same skills without the plugin packaging. See the [Skills documentation](https://tuist.dev/en/docs/guides/features/agentic-coding/skills) for per-agent manual installation.

### MCP only

Add `https://tuist.dev/mcp` as a remote MCP server. For Claude Code:

```bash
claude mcp add --transport http tuist https://tuist.dev/mcp
```

Other clients are covered in the [MCP documentation](https://tuist.dev/en/docs/guides/features/agentic-coding/mcp).

## MCP or skills

The MCP tools and some of the skills overlap in what they can do. Pick one per workflow and stay consistent rather than mixing both in the same flow.

## Contributing

The skills live in [tuist/tuist](https://github.com/tuist/tuist) under `skills/skills`, and this repository is updated from there. Open pull requests against the monorepo.

To check the plugin against the specification, run:

```bash
./scripts/validate.sh
```

It validates `plugin.json` and `mcp.json` against the published Agent Plugins schemas, and checks that every skill directory has a `SKILL.md` whose `name` matches the directory.

## License

MIT. See [LICENSE.md](LICENSE.md).
