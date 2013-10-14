class FindDailyAbsences
  attr_reader :users, :range

  def initialize(users, range)
    @users = users
    @range = range
  end

  def result
    @result ||= Absence.joins(:time_spans).where(time_spans: {id: find_time_spans}).uniq
  end

  def result_grouped_by_date
    @result_grouped_by_date ||= begin
      grouped_time_spans = find_time_spans.group_by { |ts| ts.date }
      Hash[grouped_time_spans.collect{ |date, time_spans| [date, Absence.joins(:time_spans).where(time_spans: {id: time_spans})] }]
    end
  end

  private

  def find_time_spans
    TimeSpan.absences.for_user(users).with_date(range)
  end
end
