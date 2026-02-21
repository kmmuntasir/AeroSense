---
trigger: always_on
---

# MCP Server Usage Rules

- **context7**: Flutter/Dart docs, GetX API, package docs (pub.dev)
- **GitHub**: Remote only (issues, PRs, releases) - NOT for local git
- **Filesystem**: File operations, directory traversal
- **Memory**: Project patterns, user preferences across sessions

## When to Use Each MCP

### Context7 MCP
Flutter framework docs, GetX API reference, Dart syntax, package docs (Dio, geolocator, get_storage), Material Design 3

### GitHub MCP
Create/view issues/PRs on remote, view releases, repo metadata - **NOT** for local git

### Filesystem MCP
List directories, search files, read multiple files, get metadata

### Memory MCP
Remember architecture decisions, store common patterns/conventions, retain coding preferences, track shortcuts
