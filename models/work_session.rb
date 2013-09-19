class WorkSession
  include DataMapper::Resource

  property    :id,          Serial
  property    :started_at,  DateTime, default: lambda { |*_| DateTime.now }
  property    :finished_at, DateTime, default: lambda { |*_| DateTime.now }
  property    :duration,    Integer,  default: 0
  property    :active,      Boolean,  default: false

  belongs_to  :user,     required: true
  belongs_to  :task, required: true
  has n, :notes, :constraint => :destroy

  def finish
    self.update({
      finished_at: DateTime.now,
      active: false,
      duration: DateTime.now.to_time.to_i - started_at.to_time.to_i
    })
  end

  def duration
    saved_duration = attribute_get(:duration)
    if saved_duration == 0 # this is an active session
      offset = nil
      if active?
        offset = DateTime.now.to_time.to_i
      else
        offset = finished_at.to_time.to_i
      end
      offset - started_at.to_time.to_i
    else
      saved_duration
    end
  end

  def url
    "/work_sessions/#{id}"
  end
end