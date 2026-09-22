# frozen_string_literal: true

module Portal
  class FacilitiesController < BaseController
    # The scoped find 404s a foreign facility id BEFORE the policy runs
    # (defence in depth): tenant isolation does not rely on `authorize` alone.
    def show
      @facility = policy_scope(Facility).find(params[:id])
      authorize @facility

      @booking_instances = @facility
                           .upcoming_booking_instances(days: 7)
                           .includes(:cleaning_photos)
    end
  end
end
