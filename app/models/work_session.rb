class WorkSession
  include DataMapper::Resource

  default_scope(:default).update(:order => [ :started_at.asc ])

  property    :id,          Serial
  property    :started_at,  DateTime, default: lambda { |*_| DateTime.now }
  property    :finished_at, DateTime, default: lambda { |*_| DateTime.now }
  property    :duration,    Integer,  default: 0
  property    :active,      Boolean,  default: false
  property    :summary,     Text, default: ''

  belongs_to  :user,     required: true
  belongs_to  :task, required: true
  has n, :notes, :constraint => :destroy
  has n, :tags, :through => :task, :constraint => :skip

  def finish
    self.update({
      finished_at: DateTime.now,
      active: false,
      duration: DateTime.now.to_time.to_i - started_at.to_time.to_i
    })
  end

  def finished?
    started_at != finished_at
  end

  def active?
    !finished?
  end

  def duration
    saved_duration = attribute_get(:duration)

    if saved_duration == 0 # this is an active session
      offset = active? ? DateTime.now : finished_at
      offset.to_time.to_i - started_at.to_time.to_i
    else
      saved_duration
    end

  end

  def url
    "/work_sessions/#{id}"
  end
end