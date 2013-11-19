class Task
  include DataMapper::Resource

  default_scope(:default).update(:order => [ :flagged_at.desc, :name.asc ])

  Statuses = [ :active, :pending, :abandoned, :complete ]

  property :id,          Serial
  property :name,        Text, allow_blank: false
  property :details,     Text, default: ''
  property :created_at,  DateTime, default: lambda { |*_| DateTime.now }
  property :flagged_at,  DateTime, default: lambda { |*_| DateTime.now }
  property :status,      Enum[ :active, :pending, :abandoned, :complete ], default: :active

  belongs_to :project, required: true

  has n, :work_sessions, :constraint => :destroy
  # has n, :notes, :through => :work_sessions, :constraint => :destroy
  has n, :tags, :through => Resource, :constraint => :skip

  before :destroy do
    TagTask.all({ task_id: self.id }).destroy
  end

  before :update do
    if attribute_dirty?(:status)
      self.flagged_at = DateTime.now
    end
  end

  def billing_estimate
    rate = self.project.billing_rate
    basis = self.project.billing_basis

    case basis
    when 'per_task'
      1
    when 'per_hour'
      estimate = ( self.time_spent / 3600.0 ).ceil
      estimate *= rate
      estimate.round(2)
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

  def abandoned?
    status == :abandoned
  end

  def url(root = false)
    prefix = root ? "" : project.url(true)
    "#{prefix}/tasks/#{id}"
  end
end