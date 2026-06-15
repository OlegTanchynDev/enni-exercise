# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      DEFAULT_PER_PAGE = 50
      MAX_PER_PAGE = 200

      # doorkeeper_authorize! is intentionally NOT called here. Each child
      # controller calls it with the scopes it needs (e.g. :read, :bookings).
      # Calling it here without scopes would force the default scope on every
      # endpoint and break resource-scoped tokens.
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      rescue_from Pundit::NotAuthorizedError, with: :forbidden
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from Doorkeeper::Errors::DoorkeeperError, with: :unauthorized
      rescue_from ArgumentError, with: :bad_request

      private

      def pundit_user
        @pundit_user ||= UserContext.new(current_user: current_resource_owner, true_user: current_resource_owner)
      end

      def current_resource_owner
        return @current_resource_owner if defined?(@current_resource_owner)

        @current_resource_owner = User.find_by(id: doorkeeper_token&.resource_owner_id)
      end

      # Pagination that avoids a COUNT(*) on the hot path: fetch per_page + 1 rows
      # to derive X-Has-More without a second query. X-Total-Count is OPT-IN
      # (?include_total=true) because an always-on COUNT(*) once took the
      # production database to 100% CPU. Returns a plain Array so callers can't
      # accidentally trigger a COUNT by calling .count/.size on the result.
      def paginate_api(scope, include_total: false)
        per_page = parse_per_page(params[:per_page])
        page = [params.fetch(:page, 1).to_i, 1].max

        rows = scope.offset((page - 1) * per_page).limit(per_page + 1).to_a
        has_more = rows.size > per_page

        response.headers["X-Page"] = page.to_s
        response.headers["X-Per-Page"] = per_page.to_s
        response.headers["X-Has-More"] = has_more.to_s
        if include_total || ActiveModel::Type::Boolean.new.cast(params[:include_total])
          response.headers["X-Total-Count"] = scope.except(:offset, :limit).count.to_s
        end

        rows.first(per_page)
      end

      def parse_per_page(raw)
        return DEFAULT_PER_PAGE if raw.blank?
        raise ArgumentError, "per_page must be a positive integer" unless raw.to_s.match?(/\A\d+\z/)

        raw.to_i.clamp(1, MAX_PER_PAGE)
      end

      def unauthorized(_exception = nil)
        render json: { error: "unauthorized" }, status: :unauthorized
      end

      def forbidden(_exception = nil)
        render json: { error: "forbidden" }, status: :forbidden
      end

      def not_found(_exception = nil)
        render json: { error: "not_found" }, status: :not_found
      end

      def bad_request(exception)
        render json: { error: "bad_request", message: exception.message }, status: :bad_request
      end
    end
  end
end
