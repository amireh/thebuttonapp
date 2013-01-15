class WorkSession
  include DataMapper::Resource

  property    :id,          Serial
  property    :started_at,  DateTime, default: lambda { |*_| DateTime.now }
  property    :finished_at, DateTime, default: lambda { |*_| DateTime.now }
  property    :active,      Boolean,  default: false

  belongs_to  :user,     required: true
  belongs_to  :task, required: true
  has n, :notes, :constraint => :destroy

  def finish
    self.update({ finished_at: DateTime.now, active: false })
  end

  def duration
    offset = nil
    if active?
      offset = DateTime.now.to_time.to_i
    else
      offset = finished_at.to_time.to_i
    end
    offset - started_at.to_time.to_i
  end
end