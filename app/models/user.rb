class User < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :ldap_id, :name, :time_zone

  before_save :set_default_time_zone
  
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  has_many :sheets, class_name: 'TimeSheet'
  has_many :employments

  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.zones_map { |m| m.name }, :message => "is not a valid Time Zone"

  def subordinates
    # method chaining LIKE A BOSS
    teams.select{ |t| t.has_leader?(self) }.collect{ |t| t.members }.flatten.uniq
  end

  def ensure_timesheet_and_employment_exist
    # ensure a valid timesheet and a employment entry exists
    self.sheets << TimeSheet.new if self.sheets.empty?
    self.employments << Employment.default if self.employments.empty?
    save! if changed?
  end

  private

  def set_default_time_zone
    self.time_zone ||= Time.zone.name
  end
end
