# Example: Debugging with Competing Hypotheses

This example demonstrates using an agent team to debug a hard-to-reproduce issue by having multiple teammates test different theories in parallel — and actively challenge each other.

## The Problem

When the root cause is unclear, a single agent tends to find the first plausible explanation and stop looking. This is a form of anchoring: once one theory seems viable, subsequent investigation is biased toward confirming it rather than finding alternatives.

## The Solution

Assign each teammate a distinct hypothesis and require them to both investigate their own theory **and** actively try to disprove the others'. The theory that survives this adversarial process is much more likely to be the actual root cause.

## Example Bug

> Users report: the app exits after one message instead of staying connected. This happens intermittently — about 20% of sessions — and only after the first successful message exchange.

## Prompt

```text
Users report the app disconnects after the first message about 20% of the time.
Spawn 5 agent teammates to investigate competing hypotheses in parallel.

- Teammate 1 (Race condition): Investigate whether there's a timing issue between
  the message handler completing and the connection keepalive mechanism. Look at
  async/await chains in src/connection/ and check for unhandled promise rejections.

- Teammate 2 (Memory pressure): Check whether a memory leak causes the process
  to exceed limits after the first request cycle. Look at heap profiling data in
  logs/ and check for large object retention in message processing.

- Teammate 3 (Event loop blocking): Investigate whether a synchronous operation
  is blocking the event loop long enough to trigger connection timeouts. Look at
  src/handlers/ for any CPU-intensive synchronous code.

- Teammate 4 (Connection pool exhaustion): Check whether the connection pool is
  being exhausted on first use. Look at pool configuration and whether connections
  are being properly returned after message handling.

- Teammate 5 (Server-side timeout): Investigate whether the server has a short
  idle timeout that fires after the first message. Look at server config and
  any timeout middleware.

Rules:
1. Each teammate must gather evidence FOR their hypothesis from the codebase and logs
2. Each teammate must also look for evidence AGAINST the other hypotheses
3. Teammates should message each other directly to share evidence and challenge theories
4. Update FINDINGS.md as evidence accumulates

When consensus emerges, report the most likely root cause with supporting evidence.
If multiple causes are found, rank them by likelihood.
```

## FINDINGS.md Template

The team updates this file as investigation proceeds:

```markdown
# Bug Investigation: Connection Drop After First Message

## Status: In Progress

## Hypotheses Under Investigation

### H1: Race condition in connection handler
- **Evidence for**: [teammate 1 updates here]
- **Evidence against**: [other teammates contribute here]
- **Verdict**: TBD

### H2: Memory pressure
- **Evidence for**: [teammate 2 updates here]
- **Evidence against**: [other teammates contribute here]
- **Verdict**: TBD

### H3: Event loop blocking
...

## Consensus
[Lead synthesizes when debate converges]

## Root Cause
[Final determination with evidence]
```

## Why This Works Better Than Sequential Investigation

| Approach | Problem |
|----------|---------|
| Single agent | Finds first plausible explanation, stops looking |
| Sequential teammates | Later investigators are anchored by earlier findings |
| Adversarial parallel | Each hypothesis must survive active opposition from peers |

The adversarial structure is the key mechanism. A theory that teammates actively try to disprove — and fail — is much more credible than one that simply went unchallenged.

## Variation: Simpler Hypothesis Testing

For less complex bugs with a smaller hypothesis space:

```text
Three users report getting a 500 error when submitting the contact form. It doesn't
happen in dev, only in production. Spawn 3 teammates to investigate:

- Teammate 1: check environment differences (env vars, feature flags, config)
- Teammate 2: look at recent deploys and whether any migration is missing in prod
- Teammate 3: check the production error logs for stack traces from those user IDs

Have them share findings and identify the most likely cause.
```
