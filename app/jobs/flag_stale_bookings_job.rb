# frozen_string_literal: true

# This job runs periodically to find old, unverified bookings and flag them.
class FlagStaleBookingsJob
  include Sidekiq::Job

  def perform
    # 1. Find all bookings in the system that started more than 48 hours ago
    #    and still have the "unverified" status.
    stale_bookings = BookingInstance
                       .where("starts_at < ?", 48.hours.ago)
                       .where(verification_status: "unverified")

    # 2. Update their status to "flagged" in a single, efficient SQL query.
    #    We use update_all because we don't need to trigger any callbacks for this operation.
    stale_bookings.update_all(verification_status: "flagged")
  end
end
