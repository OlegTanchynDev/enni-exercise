# frozen_string_literal: true

module Api
  module V1
    class BookingInstancesController < BaseController
      # Scope lives in the CHILD controller, not the base — see base_controller.
      before_action -> { doorkeeper_authorize! :read, :bookings }

      # TASK 1b. The tenant-scoped feed: paginate policy_scope(BookingInstance)
      # with paginate_api, serialize with BookingInstanceSerializer, keep
      # X-Total-Count opt-in. Contract: the request spec. (README has the detail.)
      def index
        raise NotImplementedError, "TASK 1b: implement the tenant-scoped booking_instances feed"
      end
    end
  end
end
