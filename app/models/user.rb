# frozen_string_literal: true

# STI base. Subclasses: SystemAdmin, OperatorUser, Customer.
# Mirrors the real Enni model where SystemAdmin inherits from User and operator
# staff carry fine-grained roles.
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :operator, optional: true

  validates :name, presence: true

  def system_admin?
    is_a?(SystemAdmin)
  end

  def operator?
    is_a?(OperatorUser)
  end
  alias operator_user? operator?

  def customer?
    is_a?(Customer)
  end

  # Mirrors the real Enni ApplicationPolicy role check. `roles` is a Postgres
  # text[] column populated for operator staff (e.g. :operator_customer_service).
  def has_role?(role)
    roles.include?(role.to_s)
  end
end
