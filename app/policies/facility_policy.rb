# frozen_string_literal: true

# Provided (correct) — the operator portal lists a facility's verification card.
class FacilityPolicy < ApplicationPolicy
  def show?
    current_user = user_context.current_user
    system_admin? || (current_user&.operator? && record.operator == current_user.operator)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      current_user = user.current_user
      return scope.all if current_user&.system_admin?
      return scope.none unless current_user&.operator?

      scope.joins(:venue).where(venues: { operator_id: current_user.operator_id })
    end
  end
end
