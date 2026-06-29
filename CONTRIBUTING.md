# Contributing

## Branch naming

Use short, descriptive branch names.

Format:

```text
<type>/<short-description>
```

Examples:

```text
feat/add-json-decoder
fix/handle-empty-input
docs/update-readme
refactor/simplify-parser
test/add-parser-cases
chore/update-ci
```

Allowed branch types:

```text
feat      new functionality
fix       bug fix
docs      documentation only
refactor  code change without behavior change
test      tests only
chore     maintenance, tooling, CI, dependencies
```

Use lowercase words separated by hyphens.

Avoid:

```text
my-branch
new-stuff
fix
wip
final-version
```

## Commit messages

Use Conventional Commits:

```text
<type>: <short description>
```

Examples:

```text
feat: add JSON decoder
fix: handle empty input
docs: update installation section
refactor: simplify parser pipeline
test: add parser edge cases
chore: update GitHub Actions
```

Use imperative mood when possible:

```text
fix: handle nil values
```

Not:

```text
fixed nil values
fixes nil values
handling nil values
```

## Commit types

Allowed commit types:

```text
feat      new functionality
fix       bug fix
docs      documentation only
refactor  internal code change without behavior change
test      adding or updating tests
chore     maintenance, tooling, CI, dependencies
perf      performance improvement
ci        CI configuration
build     build system or packaging changes
```

## Breaking changes

For breaking API changes, use `!` after the type:

```text
feat!: change parser return format
```

Also describe the breaking change in the commit body:

```text
BREAKING CHANGE: parse/1 now returns {:ok, result} | {:error, reason}
instead of raising exceptions.
```

## Release commits

Release commits should use the following format:

```text
chore: release v0.4.0
```

A release commit should usually include:

* version bump in `mix.exs`
* updated `CHANGELOG.md`
* any release-related metadata

After merging the release commit into `main`, create a git tag:

```bash
git tag v0.4.0
git push origin v0.4.0
```

## Pull requests

All changes should go through a pull request.

Before opening a PR, run CI on PR or:

```bash
mix format
mix credo --strict
mix test
```

Before pushing your changes.

A PR should be small and focused. Prefer several small PRs over one large PR.

## Main branch

The `main` branch should always be stable and releasable.

Do not merge unfinished work into `main`. Keep unfinished features in separate branches until they are ready.
