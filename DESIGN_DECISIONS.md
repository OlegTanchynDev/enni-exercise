# Design decisions

The calls you made and why. Bullets are fine. This is where your thinking shows,
so it's worth a few minutes.

## Decisions and trade-offs

- **Task 1a (State Machine):** I added a second, named AASM state machine for `verification_status`. This cleanly separates the booking lifecycle from the verification lifecycle. The `CleaningVerification::Recorder` service was designed to be responsible only for the transition from `pending` to a final state (`verified` or `flagged`), adhering to the Single Responsibility Principle (SRP). The responsibility of moving a booking to `pending` is left to the calling context, which makes the `Recorder`'s role simpler and more predictable.

- **Task 1b (API Scoping):** To implement the tenant-scoped API feed, I fixed the Pundit `Scope`. The initial issue was calling role checks on the `UserContext` instead of the `current_user`. The subsequent database error (`missing FROM-clause`) was resolved by adding an explicit `joins(:operator)` and specifying the table in the `where` clause (`where(operators: { id: ... })`). This is a robust way to handle `has_one :through` associations. Finally, I corrected the controller to use `.map` with the PORO (Plain Old Ruby Object) serializer, as indicated by the serializer's own documentation.

- **Task 1c (Authorization):** I fixed an Insecure Direct Object Reference (IDOR) vulnerability in `BookingInstancePolicy`. The `verify?` method allowed `customer_service_operator?` users to act on any booking, regardless of tenant. I fixed this by adding the `&& operator_owns_record?` check, ensuring they can only act on bookings belonging to their own operator.

- **Task 3a (AI Classifier):** The key challenge was making the tests deterministic. I refactored the specs to mock the `Gemini::Client` and provide controlled responses for each scenario (pass, fail, malformed, server error). This allowed me to reliably test the classifier's logic. For error handling, I chose to have the service propagate `Gemini::Client` exceptions. This is a safer pattern than quietly returning a `fail` verdict, as it allows the calling context (e.g., a Sidekiq worker) to handle the failure explicitly, for instance by scheduling a retry.

- **Task 3b (AI-Generated Code Review):** I identified multiple critical issues in `AvailabilitySummary`: a data leak due to missing operator scoping, a major N+1 query problem, and a severe SRP violation where a read-only service was modifying database records (`auto_flag_stale!`). I refactored the service to be a performant, read-only query. The data modification logic was not only incorrect (it searched for past bookings in a future-dated list) but also misplaced. I extracted this logic into a new `FlagStaleBookingsJob` designed to be run hourly via a scheduler.

- **Task 4 (Infrastructure):**
    - **4a (CloudWatch Alarm):** I added an alarm for `FailedClassifications`. I justified the threshold of `>10` failures over 5 minutes as a sensitive trigger for a new system where the baseline should be near-zero. A sustained rate above this indicates a systemic issue, so I routed it to the `alerts` (sev-2) topic for investigation.
    - **4b (S3 Lifecycle):** I added a lifecycle rule to expire cleaning photos after 90 days to manage storage costs and automatically purge stale, time-sensitive data.
    - **4c (IAM Policy):** I tightened the `s3:*` policy to least privilege, separating permissions for the bucket (`s3:ListBucket`) and the objects within it (`s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`). This significantly reduces the potential blast radius in case of a security breach.

## What I left out, on purpose

- **I focused on a solid core to avoid over-engineering, but I know exactly how to scale it for production.**

## With more time

- **Real-time UI Updates:** I would enhance the Facility Verification Card from Task 2 to use Turbo Streams. This would allow verification badges to update in real-time as background jobs complete, providing a much better user experience.
- **`sidekiq-cron` Integration:** I created the `FlagStaleBookingsJob` and its schedule file. With more time, I would add the `sidekiq-cron` gem to the `Gemfile` and ensure the schedule is correctly loaded and running in a development environment.

## Anything you'd want a reviewer to know

- I fully validated the codebase: I ran and fixed all linter issues, verified Terraform configuration validity, and performed a security scan using Brakeman. Finally, I successfully tested the GET /api/v1/booking_instances API endpoint locally using Postman, authenticating with a Bearer Token.
- I believe I'm done home exercises with clean code, but also I leave some comments that explain the *why* behind a decision, as seen in the Terraform alarm justification and the IAM policy statements.
