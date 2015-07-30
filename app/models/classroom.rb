class Classroom < ActiveRecord::Base
  acts_as_copy_target

  belongs_to :unity
  belongs_to :exam_rule
  has_many :teacher_discipline_classrooms, dependent: :destroy

  validates :description, :api_code, :unity_code, :year, presence: true
  validates :api_code, uniqueness: true

  scope :ordered, -> { order(arel_table[:description].asc) }
  scope :by_unity_and_teacher, lambda { |unity_id, teacher_id| joins(:teacher_discipline_classrooms).where(unity_id: unity_id, teacher_discipline_classrooms: { teacher_id: teacher_id}) }

  def to_s
    description
  end
end