# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API V1 booking_instances", type: :request do
  let_it_be(:operator) { create(:operator) }
  let_it_be(:other_operator) { create(:operator) }
  let_it_be(:operator_user) { create(:operator_user, operator: operator, role: :operator_customer_service) }
  let_it_be(:own_booking) do
    create(:booking_instance, :completed, facility: create(:facility, venue: create(:venue, operator: operator)))
  end
  let_it_be(:foreign_booking) do
    create(:booking_instance, :completed, facility: create(:facility, venue: create(:venue, operator: other_operator)))
  end

  let(:token) do
    app = Doorkeeper::Application.create!(name: "test", redirect_uri: "https://example.test/cb")
    Doorkeeper::AccessToken.create!(application: app, resource_owner_id: operator_user.id, scopes: "read bookings")
  end

  def auth_headers
    { "Authorization" => "Bearer #{token.token}" }
  end

  describe "GET /api/v1/booking_instances" do
    it "401s without a token" do
      get "/api/v1/booking_instances"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns only the caller operator's bookings (tenant isolation)" do
      get "/api/v1/booking_instances", headers: auth_headers
      expect(response).to have_http_status(:ok)
      ids = response.parsed_body.pluck("id")
      expect(ids).to include(own_booking.id)
      expect(ids).not_to include(foreign_booking.id)
    end

    it "keeps X-Total-Count opt-in" do
      get "/api/v1/booking_instances", headers: auth_headers
      expect(response.headers["X-Total-Count"]).to be_nil

      get "/api/v1/booking_instances", params: { include_total: "true" }, headers: auth_headers
      expect(response.headers["X-Total-Count"]).to eq("1")
    end
  end
end
