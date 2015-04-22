class SchoolCalendar < ActiveRecord::Base
  acts_as_copy_target

  audited
  has_associated_audits

  include Audit

  has_many :steps, class_name: "SchoolCalendarStep", dependent: :destroy
  has_many :events, class_name: "SchoolCalendarEvent", dependent: :destroy

  validates :year, uniqueness: true
  validates :year, :number_of_classes, presence: true
  validate :at_least_one_assigned_step

  scope :ordered, -> { order(arel_table[:year]) }

  accepts_nested_attributes_for :steps, reject_if: :all_blank, allow_destroy: true

  def to_s
    year
  end

  def school_day? date
    return false if events.where(event_date: date, event_type: EventTypes::NO_SCHOOL).any?
    return true if events.where(event_date: date, event_type: EventTypes::EXTRA_SCHOOL).any?
    return false if steps.where(SchoolCalendarStep.arel_table[:start_at].lteq(date)).where(SchoolCalendarStep.arel_table[:end_at].gteq(date)).empty?
    ![0, 6].include? date.wday
  end

  private

  def at_least_one_assigned_step
    errors.add(:steps, :at_least_one_step) if steps.empty?
  end
end
