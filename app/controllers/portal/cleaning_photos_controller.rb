# frozen_string_literal: true

module Portal
  class CleaningPhotosController < BaseController
    # Uploading a cleaning photo triggers async classification + verification, so
    # it must be authorised against the booking instance. This is the LIVE call
    # site for the TASK 1c policy: with the planted bug, an operator can attach a
    # photo to another operator's booking. (Note we look the booking up directly
    # and lean on `authorize` — a defence-in-depth answer also scopes the find.)
    def create
      @booking_instance = BookingInstance.find(params[:booking_instance_id])
      authorize @booking_instance, :update?

      @booking_instance.cleaning_photos.create!(image: params[:image], uploaded_by: current_user)
      redirect_back_or_to(portal_dashboard_path, notice: "Cleaning photo uploaded — verification in progress.")
    end
  end
end
