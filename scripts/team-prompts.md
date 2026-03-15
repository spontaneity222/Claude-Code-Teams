# Agent Team Prompt Templates

Ready-to-use prompts for common agent team workflows. Copy and adapt these for your use case.

---

## Parallel Code Review

Best for: reviewing PRs where you want independent eyes on security, performance, and correctness simultaneously.

```text
Create an agent team to review PR #<NUMBER>. Spawn three reviewers:
- One focused on security implications (injection vulnerabilities, auth flaws, data exposure)
- One checking performance impact (algorithmic complexity, N+1 queries, memory usage)
- One validating test coverage (edge cases, error paths, regression coverage)

Have them each independently review and compile findings. When all three are done,
synthesize their reports into a single prioritized list of issues.
```

---

## Competing Hypothesis Debugging

Best for: bugs where the root cause is unclear and you want to explore multiple theories in parallel.

```text
Users report: <DESCRIBE THE BUG>

Spawn 5 agent teammates to investigate different hypotheses:
- Teammate 1: <HYPOTHESIS A>
- Teammate 2: <HYPOTHESIS B>
- Teammate 3: <HYPOTHESIS C>
- Teammate 4: <HYPOTHESIS D>
- Teammate 5: <HYPOTHESIS E>

Have them each gather evidence for their hypothesis AND actively try to disprove
the others' theories, like a scientific debate. Update FINDINGS.md with the
evidence and reasoning as it accumulates. When consensus emerges on the most
likely root cause, report it to me with supporting evidence.
```

---

## Parallel Feature Implementation

Best for: features that span multiple layers (API, UI, tests) that can be built independently.

```text
Create a team with 3 teammates to implement <FEATURE NAME>. Require plan approval
before any teammate makes code changes.

- Teammate A: implement the backend API endpoints in src/api/
  - Create the route handlers
  - Add input validation
  - Write unit tests for the handlers

- Teammate B: build the frontend UI in src/components/
  - Create the <ComponentName> component
  - Wire up API calls using our existing fetch utility
  - Add loading and error states

- Teammate C: write integration tests in tests/integration/
  - Wait for Teammates A and B to finish their plan approvals
  - Write end-to-end tests covering the happy path and key error cases

Use Sonnet for each teammate. Teammates A and B can work in parallel.
Teammate C should wait for the others before starting.
```

---

## Multi-perspective Research

Best for: exploring a new technology, architecture decision, or design problem from multiple angles.

```text
I'm evaluating <TECHNOLOGY/APPROACH> for <USE CASE>. Create an agent team to
research this from different angles:

- Proponent: make the strongest case for adopting it, focusing on benefits,
  ecosystem maturity, and fit with our stack
- Skeptic: identify risks, limitations, hidden costs, and better alternatives
- Pragmatist: focus on migration path, learning curve, and operational overhead

Have them each research independently, then discuss and challenge each other's
findings. Synthesize the debate into a recommendation with clear tradeoffs.
```

---

## Cross-codebase Refactor

Best for: large refactors where different modules can be updated independently.

```text
We need to refactor <DESCRIBE CHANGE> across the codebase. The changes are
independent per module, so teammates can work in parallel without conflicts.

Create a team to handle this:
- Teammate 1: update src/auth/ — <specific change>
- Teammate 2: update src/api/ — <specific change>
- Teammate 3: update src/models/ — <specific change>
- Teammate 4: update tests/ to match the new interfaces

Teammates 1–3 can work in parallel. Teammate 4 depends on all three finishing.
After all changes are done, run the test suite and fix any failures.
```

---

## Security Audit

Best for: deep security review of a codebase or specific component.

```text
Spawn a security audit team to review <TARGET: e.g., "the authentication module at src/auth/">

- Teammate 1 (Input Validation): check for injection vulnerabilities, XSS,
  parameter tampering, and improper input sanitization
- Teammate 2 (Auth & Session): review token handling, session management,
  privilege escalation risks, and access control logic
- Teammate 3 (Data Exposure): identify sensitive data in logs, error messages,
  API responses, and insecure storage patterns

Have each teammate produce a report with findings rated by severity
(Critical/High/Medium/Low) and concrete remediation steps. Compile into
a final security report with items ranked by priority.
```

---

## Tips for Writing Team Prompts

1. **Define clear ownership**: each teammate should own distinct files or concerns to avoid conflicts
2. **Specify dependencies**: if Teammate C needs Teammate A to finish first, say so explicitly
3. **State the deliverable**: what should each teammate produce? A report? Code changes? A test file?
4. **Request plan approval for risky work**: add "Require plan approval before making any changes" for production code
5. **Limit team size**: 3–5 teammates works best; 5–6 tasks per teammate is a good ratio
6. **Set model preferences if needed**: "Use Sonnet for each teammate" or "Use Opus for the architect teammate"
