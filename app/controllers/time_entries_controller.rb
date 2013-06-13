class TimeEntriesController < ApplicationController
  load_and_authorize_resource :time_sheet
  load_and_authorize_resource :time_entry, through: :time_sheet

  respond_to :html, :json, :js

  before_filter :load_time_types

  def index
    respond_with(@time_entries)
  end

  def new
    if params[:date]
      @time_entry.start_date = params[:date]
    end
  end

  def edit
  end

  def create
    if @time_entry.timer?
      @time_entry.start_date = Date.current
    end

    if @time_entry.ends && @time_entry.starts && @time_entry.ends < @time_entry.starts
      @time_entry.ends = @time_entry.starts + 1.day
    end
    @time_entry.save

    respond_with @time_entry, location: default_return_location
  end

  def update
    @time_entry.update_attributes(params[:time_entry])
    respond_with @time_entry, location: default_return_location
  end

  def destroy
    @time_entry.destroy
    respond_with(@time_entry, location: default_return_location) do |format|
      format.js { render nothing: true }
    end
  end

  private
  def default_return_location
    time_sheet_path(@time_sheet)
  end

  def load_time_types
    @time_types = TimeType.work
  end
end
