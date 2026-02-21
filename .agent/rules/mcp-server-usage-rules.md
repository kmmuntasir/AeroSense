---
trigger: always_on
---

# MCP Server Usage Rules

- Use the **context7 MCP server** to consult Flutter/Dart documentation, GetX API reference, or package documentation (pub.dev).
- Strictly use terminal commands for local `git` operations. The **GitHub MCP** should only be used when you need to work with data from the remote origin (issues, PRs, releases).
- Use **Filesystem MCP** for efficient file operations when dealing with complex file traversals.
- Use **Memory MCP** to retain important context about the project structure, patterns, and user preferences across sessions.
- **Removed**: Chakra UI MCP server (no longer applicable - this is a Flutter project, not React.js).

## When to Use Each MCP

### Context7 MCP
- Look up Flutter framework documentation
- GetX state management API reference
- Dart language syntax and features
- Package documentation (Dio, geolocator, get_storage, etc.)
- Material Design 3 guidelines

### GitHub MCP
- Create/view issues and pull requests on the remote repository
- View release information
- Repository analytics and metadata
- **DO NOT** use for local git operations (use terminal instead)

### Filesystem MCP
- List directory contents when exploring the project structure
- Search for files by pattern
- Read multiple files efficiently
- Get file metadata

### Memory MCP
- Remember project architecture decisions
- Store commonly used patterns and conventions
- Retain user preferences for coding style
- Keep track of project-specific shortcuts or aliases

## Available MCP Servers (Current Configuration)

Check `.agent/mcp.json` for the currently configured MCP servers.
