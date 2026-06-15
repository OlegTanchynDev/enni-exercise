# frozen_string_literal: true

class BookingInstancePolicy < ApplicationPolicy
  def show?
    system_admin? || operator_owns_record?
  end

  # Who may record a verification on this booking (it writes audited data and
  # transitions state).
  def verify?
    system_admin? || customer_service_operator? || (admin_operator? && operator_owns_record?)
  end

  alias update? verify?

  # TASK 1b. Scope the API feed to the caller's operator (admins see all).
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.none # TASK 1b: replace with the tenant scope
    end
  end

  private

  def operator_owns_record?
    current_user = user_context.current_user
    current_user&.operator? && record.operator == current_user.operator
  end
end
