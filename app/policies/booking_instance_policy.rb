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
      current_user = user.current_user
      if current_user.system_admin?
        scope.all
      elsif current_user.operator?
        scope.joins(:operator).where(operators: { id: current_user.operator.id })
      else
        scope.none
      end
    end
  end

  private

  def operator_owns_record?
    current_user = user_context.current_user
    current_user&.operator? && record.operator == current_user.operator
  end
end
