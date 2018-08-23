class TransferNote < ActiveRecord::Base
  include Audit
  include Stepable

  audited except: [:teacher_id, :recorded_at]
  has_associated_audits

  acts_as_copy_target

  attr_writer :unity_id

  belongs_to :classroom
  belongs_to :discipline
  belongs_to :school_calendar_step, -> { unscope(where: :active) }
  belongs_to :school_calendar_classroom_step, -> { unscope(where: :active) }
  belongs_to :student
  belongs_to :teacher

  has_many :daily_note_students, dependent: :destroy

  accepts_nested_attributes_for :daily_note_students, reject_if: proc { |attributes| attributes[:note].blank? }

  before_validation :set_transfer_date, on: [:create, :update]

  validates_presence_of :unity_id, :discipline_id, :student_id, :teacher
  validate :at_least_one_daily_note_student

  scope :by_classroom_description, lambda { |description|
    joins(:classroom).where('unaccent(classrooms.description) ILIKE unaccent(?)', "%#{description}%")
  }
  scope :by_discipline_description, lambda { |description|
    joins(:discipline).where('unaccent(disciplines.description) ILIKE unaccent(?)', "%#{description}%")
  }
  scope :by_student_name, lambda { |name|
    joins(:student).where('unaccent(students.name) ILIKE unaccent(?)', "%#{name}%")
  }
  scope :by_transfer_date, lambda { |transfer_date| where(transfer_date: transfer_date.to_date) }
  scope :by_teacher_id, lambda { |teacher_id| where(teacher_id: teacher_id) }
  scope :by_discipline_id, lambda { |discipline_id| where(discipline_id: discipline_id) }
  scope :by_classroom_id, lambda { |classroom_id| where(classroom_id: classroom_id) }
  scope :by_unity_id, lambda { |unity_id| joins(:classroom).where(classrooms: { unity_id: unity_id }) }

  delegate :unity, :unity_id, to: :classroom, allow_nil: true

  private

  def set_transfer_date
    self.transfer_date = recorded_at
  end

  def at_least_one_daily_note_student
    if daily_note_students.reject { |daily_note_student| daily_note_student.note.blank? }.empty?
      errors.add(:daily_note_students, :at_least_one_daily_note_student)
    end
  end
end
