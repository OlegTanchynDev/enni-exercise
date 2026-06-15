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
        instances = paginate_api(policy_scope(BookingInstance))
        render json: instances.map { |instance| BookingInstanceSerializer.new(instance) }
      end
    end
  end
end
