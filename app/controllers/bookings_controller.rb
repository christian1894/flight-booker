class BookingsController < ApplicationController
  before_action :set_booking, only: [:show, :edit, :update, :destroy]

  # GET /bookings
  # GET /bookings.json
  def index
    @bookings = Booking.all
  end

  # GET /bookings/1
  # GET /bookings/1.json
  def show
  end

  # GET /bookings/new
  def new
    @booking = Booking.new(flight_id: booking_params[:flight_id])
    unless @booking.flight
      redirect_back fallback_location: root_path, flash: {danger: "Please choose a flight."} 
    else
      number_of_passengers = booking_params[:number_of_passengers].to_i
      number_of_passengers.times do
        @booking.passengers.build
      end
    end
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings
  # POST /bookings.json
  def create
    @booking = Booking.new(create_booking_params)

    respond_to do |format|
      if @booking.save
        @flight = @booking.flight
        @booking.passengers.each do|passenger|
          PassengerMailer.booking_mail(passenger, @flight, @booking).deliver_now!
        end
        format.html { redirect_to @booking, success: 'Booking was successfully created.' }
        format.json { render :show, status: :created, location: @booking }
      else
        format.html { render :new }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update(booking_params)
        format.html { redirect_to @booking, notice: 'Booking was successfully updated.' }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    @booking.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url, notice: 'Booking was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    # Only allow a list of trusted parameters through.

    def booking_params
      params.require(:booking).permit(:flight_id, :number_of_passengers)
    end

    def create_booking_params
      params.require(:booking).permit(:flight_id, passengers_attributes: [:name, :email])
    end
end
