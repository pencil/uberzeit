class PublicHolidaysController < ApplicationController
  load_and_authorize_resource

  def index
    @year = (params[:year] || session[:year] || Time.current.year).to_i
    session[:year] = @year

    year_range = UberZeit.year_as_range(@year)
    @public_holidays = @public_holidays.where('start_date <= ? AND end_date >= ?', year_range.max, year_range.min)
  end

  def new
  end

  def edit
  end

  def show
  end

  def create
    @public_holiday = PublicHoliday.new(params[:public_holiday])
    if @public_holiday.save
      redirect_to public_holidays_path, :notice => 'Public Holiday was successfully created.'
    else
      render :action => 'new'
    end
  end

  def update
    @public_holiday = PublicHoliday.find(params[:id])
    if @public_holiday.update_attributes(params[:public_holiday])
      redirect_to public_holidays_path, :notice => 'Public Holiday was successfully updated.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @public_holiday = PublicHoliday.find(params[:id])
    if @public_holiday.destroy
      redirect_to public_holidays_path, :notice => 'Public Holiday was successfully deleted.'
    else
      render :action => 'edit'
    end
  end
end

