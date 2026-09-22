# frozen_string_literal: true

# A member of an operator's staff. Scoped to a single operator; sees only that
# operator's venues. Carries roles like :operator_customer_service.
class OperatorUser < User
  validates :operator, presence: true
end
