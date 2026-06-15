# frozen_string_literal: true

module VerificationHelper
  # icon + text + colour for each verification state — triple-redundant so the
  # status is never communicated by colour alone (accessibility). Mirrors the
  # mapping behind the real Enni _ai_classification_badge.
  VERIFICATION_BADGE = {
    "verified" => { css: "bg-success", icon: "bi-check-circle-fill", label: "Verified" },
    "flagged" => { css: "bg-warning text-dark", icon: "bi-exclamation-triangle-fill", label: "Flagged" },
    "pending" => { css: "bg-info text-dark", icon: "bi-hourglass-split", label: "Pending" },
    "unverified" => { css: "bg-light text-dark border", icon: "bi-dash-circle", label: "Unverified" }
  }.freeze

  def verification_badge(status)
    VERIFICATION_BADGE.fetch(status.to_s, VERIFICATION_BADGE.fetch("unverified"))
  end
end
