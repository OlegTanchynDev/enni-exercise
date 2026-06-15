# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Portal", type: :request do
  let_it_be(:operator) { create(:operator) }
  let_it_be(:user) { create(:operator_user, operator: operator) }
  let_it_be(:facility) { create(:facility, venue: create(:venue, operator: operator)) }

  before { sign_in user }

  it "renders the home page" do
    get root_path
    expect(response).to have_http_status(:ok)
  end

  it "renders the dashboard listing the operator's facilities" do
    get portal_dashboard_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(facility.name)
  end

  it "renders a facility's verification page with badges" do
    create(:booking_instance, :verified, facility: facility)
    get portal_facility_path(facility)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Verified")
  end

  it "404s a facility belonging to another operator (tenant isolation, defence in depth)" do
    foreign = create(:facility, venue: create(:venue, operator: create(:operator)))
    get portal_facility_path(foreign)
    expect(response).to have_http_status(:not_found)
  end
end
