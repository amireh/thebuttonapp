class Task
  include DataMapper::Resource

  Statuses = [ :active, :pending, :abandoned, :complete ]

  property    :id,          Serial
  property    :name,        Text, allow_blank: false
  property    :details,     Text, default: ''
  property    :created_at,  DateTime, default: lambda { |*_| DateTime.now }
  property    :flagged_at,  DateTime, default: lambda { |*_| DateTime.now }
  property    :status,      Enum[ :active, :pending, :abandoned, :complete ], default: :active

  belongs_to  :user,     required: true

  has n, :work_sessions,  :constraint => :destroy
  has n, :notes,          :constraint => :destroy
  has n, :tags, :through => Resource, :constraint => :skip

  before :destroy do
    TagTask.all({ task_id: self.id }).destroy
  end

  before :update do
    if attribute_dirty?(:status)
      self.flagged_at = DateTime.now
    end
  end

  def time_spent
    duration = 0
    self.work_sessions.each do |t|
      duration += t.duration
    end
    duration
  end

  def resumable?
    !([ :abandoned, :complete ].include? status)
  end
end