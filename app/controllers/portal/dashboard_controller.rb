# frozen_string_literal: true

module Portal
  class DashboardController < BaseController
    def index
      @facilities = policy_scope(Facility).includes(:venue).order("venues.name ASC", "facilities.name ASC")
    end
  end
end
