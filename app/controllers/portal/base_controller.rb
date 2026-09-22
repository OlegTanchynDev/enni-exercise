# frozen_string_literal: true

# The operator "portal" — the authenticated web UI an operator's staff use.
# Namespaced `Portal` rather than `Operator` because `Operator` is a model class
# (Zeitwerk won't let a constant be both a class and a namespace module).
module Portal
  class BaseController < ApplicationController
    before_action :require_operator

    private

    def require_operator
      return if current_user&.operator? || current_user&.system_admin?

      redirect_to root_path, alert: "Operator access only."
    end

    def current_operator
      current_user.operator
    end
    helper_method :current_operator
  end
end
