class DescriptiveExam < ActiveRecord::Base
  acts_as_copy_target

  audited
  has_associated_audits
  before_save :mark_students_for_removal

  include Audit

  belongs_to :classroom
  belongs_to :discipline
  belongs_to :school_calendar_step
  belongs_to :school_calendar_classroom_step

  delegate :unity, to: :classroom, allow_nil: true
  delegate :exam_rule, to: :classroom, allow_nil: true

  has_many :students, class_name: 'DescriptiveExamStudent', dependent: :destroy
  accepts_nested_attributes_for :students

  validates :unity, presence: true
  validates :classroom_id, presence: true
  validates :discipline_id, presence: true, if: :should_validate_presence_of_discipline
  validates :school_calendar_step_id, presence: true, if: :should_validate_presence_of_school_calendar_step
  validates :school_calendar_classroom_step_id, presence: true, unless: :school_calendar_step_id

  def mark_students_for_removal
    students.each do |student|
      student.mark_for_destruction if student.value.blank?
    end
  end

  private

  def should_validate_presence_of_discipline
    return unless exam_rule

    [OpinionTypes::BY_STEP_AND_DISCIPLINE, OpinionTypes::BY_YEAR_AND_DISCIPLINE].include? exam_rule.opinion_type
  end

  def should_validate_presence_of_school_calendar_step
    return unless exam_rule

    [OpinionTypes::BY_STEP_AND_DISCIPLINE, OpinionTypes::BY_STEP].include? exam_rule.opinion_type && school_calendar_classroom_step_id.blank?
  end
end
