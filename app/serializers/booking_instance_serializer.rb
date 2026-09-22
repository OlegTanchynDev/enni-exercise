# frozen_string_literal: true

# Plain-Ruby serializer. The real Enni uses ActiveModelSerializers with the
# :attributes adapter (flat JSON); a PORO keeps the skeleton dependency-light and
# produces the same flat shape. Use it from the API index:
#   render json: records.map { BookingInstanceSerializer.new(_1) }
class BookingInstanceSerializer
  def initialize(booking_instance)
    @booking_instance = booking_instance
  end

  def as_json(*)
    booking_instance = @booking_instance
    {
      id: booking_instance.id,
      facility_id: booking_instance.facility_id,
      facility_name: booking_instance.facility.name,
      starts_at: booking_instance.starts_at.iso8601,
      ends_at: booking_instance.ends_at.iso8601,
      status: booking_instance.status,
      verification_status: booking_instance.verification_status
    }
  end
end
