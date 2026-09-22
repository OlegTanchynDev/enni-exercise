# Enni — engineering exercise

This is a cut-down version of the Enni codebase: a Rails booking platform with a
JSON API, an AI photo-classification feature, a small web UI, and its own
Terraform/AWS setup. The real system has one engineer on it, which would be you.

So we're not that interested in how much code you can turn out; AI can turn out
plenty. We're interested in judgement. Do you catch the security bug. Do you
understand a guardrail before you change it. Do you push back when the AI is
wrong. Use AI however you normally would, and we'll go through your decisions
together afterwards.

## Running it

```bash
docker compose up
```

The app comes up on http://localhost:3000. The database is created, migrated and
seeded on first boot. (If you add or change a gem, rebuild the image with
`docker compose build` so the container picks it up.)

Log in with one of these (password `password123`):

- `staff@acme.test` — operator staff. Start here.
- `staff@borough.test` — a second operator, useful for checking tenant isolation.
- `admin@enni.test` — a system admin.

The seed run also prints an API token for the Acme operator (scopes
`read bookings`); it's in the boot logs, or fetch it again with:

```bash
docker compose run --rm web bin/rails runner "puts Doorkeeper::AccessToken.last.token"
```

The UI loads Bootstrap and the font from a CDN, so the styling needs network
access on first load.

Tests, linters and Terraform run the same way CI does:

```bash
docker compose run --rm web bin/rails db:test:prepare   # first run only: create the test DB
docker compose run --rm web bundle exec rspec
docker compose run --rm web bundle exec rubocop
docker compose run --rm web bundle exec haml-lint app/views
docker compose run --rm web bundle exec brakeman -q
cd terraform/enni && terraform init -backend=false && terraform validate
```

A fresh checkout passes locally with several pending examples; each names the
task it belongs to. CI is stricter: it fails until you've removed those
`skip "TASK ..."` markers, so "done" means the specs actually pass, not just that
they're skipped.

## The work

It's one feature. After a booking finishes, staff upload a photo of the cleaned
facility, a classifier scores it, the booking's verification status updates, and
the result shows up in the operator portal and over the API. Most of the wiring
is already done. The parts left to you are marked with `TASK` comments, so grep
for `TASK`. There are four areas.

**1. Rails and the API**

- `1a` — Add a verification state machine to `BookingInstance` and a
  `CleaningVerification::Recorder` that drives it from a classifier result.
  (`app/models/booking_instance.rb`, `app/services/cleaning_verification/recorder.rb`)
- `1b` — Build `GET /api/v1/booking_instances` and `BookingInstancePolicy::Scope`
  so an operator only sees its own bookings. Use the `paginate_api` helper that's
  already there, and read why `X-Total-Count` is opt-in before you change it.
  (`app/controllers/api/v1/booking_instances_controller.rb`)
- `1c` — There's an authorization bug in `BookingInstancePolicy` that lets one
  operator act on another's bookings. Find it, fix it, and turn the pending spec
  green.

**2. The UI**

Build the facility verification card: a facility's next seven days of bookings
and their status. (`app/views/portal/facilities/show.html.haml`) HAML, Bootstrap
utilities and Stimulus; no inline styles, no ERB. We'll look at layout,
responsiveness, accessibility (don't lean on colour alone, and keyboard
navigation should work), and how you handle the empty and loading states. If you
want to go further, update a badge live over Turbo Stream with a polling fallback.

**3. The AI feature**

- `3a` — Build `CleaningPhotoClassifier`. It reads the criteria in
  `config/cleaning_criteria.yml`, calls the stubbed `Gemini::Client`, parses the
  response (which isn't always clean JSON), and returns a pass/fail verdict. The
  stub can time out, return a 5xx, or hand back malformed JSON; decide what each
  of those should do. A failed classification must never come back as a pass.
- `3b` — `app/services/cleaning_verification/availability_summary.rb` was written
  by an AI and pasted in without anyone reading it. Read it the way you'd read a
  colleague's PR; there's more than one thing wrong. Fix it, turn its pending
  spec green, and note what you found in `AI_LOG.md`.

**4. Infrastructure**

Three small Terraform changes in `terraform/enni/`: a CloudWatch alarm, an S3
lifecycle rule, and tightening an over-broad IAM policy. Graded offline with
`terraform validate`. Details in `terraform/enni/TASK.md`.

You don't need to finish all of it. We'd rather see a few things done well and
explained than everything done in a hurry.

## Sending it back

This zip has no git history, so start with `git init` and commit as you go.
When you're done, send it back as a bundle (one file that keeps your history):

```bash
git bundle create enni-submission.bundle HEAD
```

Include:

- Your commits. Small, readable commits with messages that explain why are part
  of what we read.
- `AI_LOG.md` — roughly how you used AI, and the suggestions you changed or threw
  out, and why. "I did this by hand because…" is a fine entry.
- `DESIGN_DECISIONS.md` — the calls you made, what you left out on purpose, and
  what you'd do with more time.

## The follow-up

If we go ahead, we'll spend 45 to 60 minutes going through your code together,
and you'll make a small change or two while we watch.

## Housekeeping

- It's a made-up problem, not real Enni work. You keep the IP. We only use your
  submission to assess this application, and we delete it within three months.
- A person reviews every submission. Nothing is auto-rejected, and you'll get
  written feedback and a short call either way.
- If extra time, or a live session instead of doing it async, would help, just
  tell us and we'll sort it out. You don't need to give a reason.
