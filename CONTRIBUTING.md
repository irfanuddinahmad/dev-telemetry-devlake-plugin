# Contributing to Developer Telemetry Plugin

Thank you for your interest in contributing to the Developer Telemetry Plugin for Apache DevLake!

## Code of Conduct

This project follows the Apache Software Foundation Code of Conduct. Be respectful and inclusive.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin.git
   cd dev-telemetry-devlake-plugin
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/my-awesome-feature
   ```

## Development Setup

### Prerequisites

- Go 1.21 or later
- Access to Apache DevLake source code
- MySQL 8.0+ or PostgreSQL 13+
- golangci-lint (for linting)

### Building

Since this plugin depends on DevLake internal packages, you must build from within DevLake:

```bash
# Navigate to DevLake backend
cd /path/to/devlake/backend

# Copy plugin source
cp -r /path/to/dev-telemetry-devlake-plugin/plugins/developer_telemetry plugins/

# Build
DEVLAKE_PLUGINS=developer_telemetry scripts/build-plugins.sh
```

### Running Tests

```bash
cd /path/to/devlake/backend
go test ./plugins/developer_telemetry/...
```

### Code Formatting

```bash
# Format code
gofmt -w plugins/developer_telemetry

# Or use make
make fmt
```

## Making Changes

### Code Style

- Follow standard Go conventions
- Run `gofmt` before committing
- Keep functions small and focused
- Add comments for exported functions
- Use meaningful variable names

### Documentation

- Update README.md if adding features
- Add examples to QUICKSTART.md if applicable
- Update API.md for API changes
- Include inline code comments

### Testing

- Add unit tests for new features
- Ensure existing tests pass
- Test with both MySQL and PostgreSQL
- Test error cases

## Submitting Changes

### Before You Submit

1. **Format your code**:
   ```bash
   make fmt
   ```

2. **Run linter**:
   ```bash
   make lint
   ```

3. **Run tests**:
   ```bash
   go test ./plugins/developer_telemetry/...
   ```

4. **Update documentation** as needed

5. **Update CHANGELOG.md**:
   ```markdown
   ## [Unreleased]
   
   ### Added
   - Your new feature description
   ```

### Creating a Pull Request

1. **Push your changes**:
   ```bash
   git push origin feature/my-awesome-feature
   ```

2. **Open a Pull Request** on GitHub

3. **Fill in the PR template**:
   - Description of changes
   - Related issue number (if applicable)
   - Testing performed
   - Screenshots (if UI changes)

4. **Wait for review** from maintainers

### Pull Request Guidelines

- **One feature per PR** - Keep PRs focused
- **Clear title** - Describe what the PR does
- **Detailed description** - Explain why and how
- **Link issues** - Reference related issues
- **Pass CI checks** - Ensure all tests pass
- **Respond to feedback** - Address review comments

## Reporting Bugs

### Before Reporting

- Search existing issues to avoid duplicates
- Verify the bug exists in the latest version
- Collect relevant information

### Bug Report Template

Use [GitHub Issues](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/issues/new) and include:

```markdown
**Description**
Clear description of the bug

**To Reproduce**
1. Step one
2. Step two
3. See error

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- DevLake Version: v0.20.0
- Plugin Version: v0.1.0
- Database: MySQL 8.0
- OS: macOS 13
- Go Version: 1.21.5

**Logs**
```
Paste relevant logs here
```

**Additional Context**
Any other relevant information
```

## Feature Requests

Use [GitHub Discussions](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/discussions) for feature requests.

Include:
- **Use case** - Why is this needed?
- **Proposed solution** - How should it work?
- **Alternatives** - What other options did you consider?
- **Examples** - Show similar features in other tools

## Development Workflow

### Branch Naming

- `feature/` - New features
- `bugfix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions/improvements

Examples:
- `feature/add-authentication`
- `bugfix/fix-date-parsing`
- `docs/update-api-guide`

### Commit Messages

Follow conventional commits:

```
type(scope): subject

body

footer
```

Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting
- `refactor:` - Code restructuring
- `test:` - Adding tests
- `chore:` - Maintenance

Examples:
```
feat(api): add batch telemetry endpoint

Added new endpoint to accept multiple telemetry reports in one request.
This improves performance for collectors sending data for multiple developers.

Closes #123
```

```
fix(migration): correct date column type

Changed date column from DATETIME to DATE to match model definition.
This fixes query issues when checking for existing records.

Fixes #456
```

## Code Review Process

### What We Look For

- **Correctness** - Does it work as intended?
- **Testing** - Are there sufficient tests?
- **Documentation** - Is it well documented?
- **Code quality** - Is it clean and maintainable?
- **Performance** - Does it scale reasonably?
- **Security** - Are there any vulnerabilities?

### Response Time

- Initial review: Within 3-5 days
- Follow-up reviews: Within 2-3 days
- For urgent fixes: Within 24 hours

## Community

### Communication Channels

- **GitHub Issues** - Bug reports and tasks
- **GitHub Discussions** - Questions and ideas
- **Pull Requests** - Code contributions

### Getting Help

- Read the [documentation](README.md)
- Check [existing issues](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/issues)
- Ask in [discussions](https://github.com/YOUR_USERNAME/dev-telemetry-devlake-plugin/discussions)
- Reference [DevLake docs](https://devlake.apache.org/)

## Recognition

Contributors will be:
- Listed in release notes
- Mentioned in CHANGELOG.md
- Added to CONTRIBUTORS.md (if you make significant contributions)

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

---

Thank you for contributing! Every contribution, no matter how small, helps make this plugin better. 🚀
