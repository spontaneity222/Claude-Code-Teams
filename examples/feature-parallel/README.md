# Example: Parallel Feature Implementation

This example demonstrates using an agent team to build a new feature across multiple layers of the stack simultaneously, with each teammate owning a distinct, non-overlapping part.

## The Problem

Building a full-stack feature sequentially means the backend developer must finish before the frontend developer can start, which must finish before the test writer can start. This is often unnecessary — the interfaces can be agreed upfront and the layers built in parallel.

## The Solution

Define clear interfaces and file ownership upfront, then assign each layer to a separate teammate. Since teammates own non-overlapping files, there are no merge conflicts. The lead synthesizes results and runs a final integration check.

## Example Feature: User Notification System

The team will build a notification system with three independent workstreams:

1. **Backend API** — new endpoints for creating, listing, and marking notifications as read
2. **Frontend UI** — a notification bell component that fetches and displays notifications
3. **Integration tests** — end-to-end tests covering the full notification flow

## Prompt

```text
Create a team to implement the user notification system. Three teammates can work
in parallel on non-overlapping parts. Require plan approval before any teammate
makes code changes.

## Interface Agreement (all teammates must follow this)

API endpoints:
  GET    /api/notifications         → { notifications: Notification[], unreadCount: number }
  POST   /api/notifications/read    → { success: boolean } (marks all as read)
  POST   /api/notifications/:id/read → { notification: Notification }

Notification shape:
  { id: string, userId: string, type: string, message: string, read: boolean, createdAt: string }

---

Teammate A (Backend): implement the API endpoints in src/api/notifications/
  - Create route handlers for GET /api/notifications, POST /api/notifications/read,
    POST /api/notifications/:id/read
  - Add a Notification model in src/models/notification.ts (use our existing
    Prisma setup — see schema.prisma for pattern)
  - Add input validation and proper error responses
  - Write unit tests in tests/unit/api/notifications.test.ts

Teammate B (Frontend): build the notification UI in src/components/Notifications/
  - Create NotificationBell.tsx — bell icon with unread count badge
  - Create NotificationList.tsx — dropdown list of recent notifications
  - Create useNotifications.ts hook — polls GET /api/notifications every 30s,
    exposes markAsRead() and markAllAsRead()
  - Use our existing fetchJson() utility in src/utils/fetch.ts for API calls
  - Add loading and empty states

Teammate C (Integration tests): write integration tests in tests/integration/notifications/
  - Wait for Teammates A and B to complete and have their plans approved
  - Write tests covering:
    - Full flow: create notification → it appears for the user → mark as read
    - Unread count updates correctly
    - Polling behavior (mock the timer)
    - Error handling when API is unreachable

After all teammates finish, the lead should run `npm test` and fix any failures.
```

## Task Dependencies

The task list for this feature looks like:

```
Task 001: [Backend] Create Notification model          [no deps]
Task 002: [Backend] Implement GET /api/notifications   [deps: 001]
Task 003: [Backend] Implement POST mark-as-read        [deps: 001]
Task 004: [Backend] Write unit tests                   [deps: 002, 003]
Task 005: [Frontend] Create useNotifications hook      [no deps]
Task 006: [Frontend] Create NotificationBell component [deps: 005]
Task 007: [Frontend] Create NotificationList component [deps: 005]
Task 008: [Integration] Write integration tests        [deps: 004, 007]
Task 009: [Lead] Run tests and fix failures            [deps: 008]
```

Tasks 001–007 can progress in parallel. Task 008 waits for both layers to be ready. Task 009 runs last.

## Plan Approval Flow

When Teammate A submits their plan, the lead reviews it against the interface agreement:

- Does the API shape match the agreed contract?
- Does the Prisma model include the required fields?
- Are unit tests included?

The lead approves plans that match the agreement and rejects plans that deviate, with feedback explaining what needs to change.

## Best Practices for This Pattern

1. **Agree on interfaces first** — put them in the prompt so all teammates start from the same contract
2. **Assign file ownership clearly** — "Teammate A owns src/api/", "Teammate B owns src/components/"
3. **Use plan approval for implementation** — catch interface mismatches before code is written
4. **Specify waiting behavior** — "Teammate C should wait for A and B to finish their plans"
5. **End with an integration step** — run tests and have the lead fix cross-layer issues
