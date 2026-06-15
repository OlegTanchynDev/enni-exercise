# AI log

Roughly how you used AI on this exercise. No required format or length. What's
useful to us is the judgement: what you took, and what you changed, threw out, or
corrected, and why. If you did something by hand instead, say so.

> I used Gemini 2.5 Flash in Agent mode within my IDE to demonstrate my ability to deliver results using standard, accessible LLMs. This ensures that the code quality remains high regardless of the tool, though switching to advanced models like Claude Sonnet or similar could streamline the process even further.

## `CleaningVerification::AvailabilitySummary` (Task 3b)

I reviewed the AI-generated service and found several critical issues:

1.  **Incorrect Scoping / Data Leak:** The original code did not scope the `BookingInstance` query to the provided `operator`. It selected bookings across all operators within the date range, which is a major data leak.
2.  **N+1 Query Problem:** The `map` block accessed associated records (`booking_instance.facility.venue.name` and `booking_instance.facility.venue.operator.name`) for each booking, which would trigger a cascade of database queries (one for the facility, one for the venue, one for the operator for *each* booking).
3.  **Single Responsibility Principle (SRP) Violation:** The service included a private method `auto_flag_stale!` that modified data (`update_all`). A service named `AvailabilitySummary` should only be responsible for reading and summarizing data, not writing or updating it.
4.  **Non-Existent Method Call:** The code called `BookingInstance.in_date_range`, which is not a defined scope or method on the model, causing an immediate crash.
5.  **Faulty Logic in Side-Effect:** The `auto_flag_stale!` method attempted to find past bookings (`starts_at < 48.hours.ago`) within a collection of future bookings, meaning it would almost never work as intended.

**Remediation:** The summary service was rewritten to be a read-only, performant query. The data-writing logic was extracted into a separate background job (`FlagStaleBookingsJob`) and can be scheduled to run hourly.
