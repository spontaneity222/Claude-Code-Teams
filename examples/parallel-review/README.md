# Example: Parallel Code Review

This example demonstrates using an agent team to review a pull request from multiple perspectives simultaneously.

## The Problem

A single reviewer tends to focus on one type of issue at a time. When reviewing a large PR, they might catch security issues but miss performance regressions, or notice test gaps but overlook edge cases in error handling.

## The Solution

Split review criteria into independent domains and assign each to a separate teammate. Since reviewers operate in parallel and don't step on each other's work, all domains get thorough attention at the same time.

## Prompt

```text
Create an agent team to review the changes in the current branch compared to main.
Spawn three reviewers:

- Security reviewer: Check for injection vulnerabilities, improper input validation,
  authentication flaws, sensitive data exposure in logs or API responses, and any
  use of unsafe functions or libraries.

- Performance reviewer: Identify N+1 database queries, inefficient algorithms
  (focus on anything worse than O(n log n) in hot paths), excessive memory
  allocation, missing indexes, and synchronous operations that should be async.

- Test coverage reviewer: Check that new code paths are tested, edge cases are
  covered, error conditions have tests, and integration test scenarios are realistic.

Have each reviewer work independently, then compile their findings. When all three
are done, synthesize into a prioritized list: Critical → High → Medium → Low.
Group issues by theme rather than by reviewer.
```

## How It Works

1. The lead creates the team and spawns three reviewer teammates
2. Each reviewer reads the same diff but applies a different lens
3. Reviewers work independently — no waiting on each other
4. Each produces a structured findings report
5. The lead synthesizes all three reports into a single prioritized list

## Expected Output

The lead produces a consolidated review like:

```markdown
## PR Review: Consolidated Findings

### Critical
- [Security] SQL injection risk in UserController.search() — user input passed
  directly to raw query at line 47

### High
- [Performance] N+1 query in OrderService.getOrdersWithItems() — missing eager
  load for items relation
- [Security] JWT secret falls back to hardcoded value when env var is missing

### Medium
- [Tests] No test for the case where payment provider returns a 429 rate limit
- [Performance] Synchronous file write in audit logger blocks request thread

### Low
- [Tests] Integration test uses real timestamps instead of mocked time
```

## Variation: Targeted Review

For a more focused review, you can give each teammate specific files to examine:

```text
Create a review team for the authentication refactor:

- Teammate 1: review src/auth/jwt.ts and src/auth/session.ts for security issues
- Teammate 2: review src/api/auth-routes.ts for input validation and error handling
- Teammate 3: review tests/auth/ and check that edge cases are covered

Each teammate should produce a structured report. The lead synthesizes all reports.
```
