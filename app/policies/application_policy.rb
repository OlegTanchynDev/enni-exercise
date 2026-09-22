# frozen_string_literal: true

# Pundit's policy `user` is a UserContext (see app/models/user_context.rb), so
# the real principal is always `user_context.current_user`. The role helpers
# below mirror the real Enni ApplicationPolicy.
class ApplicationPolicy
  attr_reader :user, :record

  alias user_context user

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?  = false
  def show?   = false
  def create? = false
  def new?    = create?
  def update? = false
  def edit?   = update?
  def destroy? = false

  def system_admin?(user = user_context.current_user)
    user.present? && user.system_admin?
  end

  def customer_service_operator?(user = user_context.current_user)
    user.present? && user.operator? && user.has_role?(:operator_customer_service)
  end

  def admin_operator?(user = user_context.current_user)
    user.present? && user.operator? && user.has_role?(:operator_admin)
  end

  # Default-deny scope. Concrete policies override resolve.
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.none
    end

    private

    attr_reader :user, :scope
  end
end
