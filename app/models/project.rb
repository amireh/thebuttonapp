class Project
  include DataMapper::Resource

  default_scope(:default).update(:order => [ :name.asc ])

  BillingBases = %w[
    per_hour
    per_task
  ]

  property :id, Serial
  property :name, String
  property :created_at,  DateTime, default: lambda { |*_| DateTime.now }
  property :billing_rate, Float, default: 0
  property :billing_currency, String, default: 'USD'
  property :billing_basis, String, default: 'per_hour'

  belongs_to :client
  has n, :tasks, :constraint => :destroy
  has n, :work_sessions, :through => :tasks, :constraint => :skip

  validates_presence_of :name, message: 'You must name this project.'
  validates_uniqueness_of :name, :scope => [ :client_id ],
    message: 'You already have such a project.'

  before :save do
    unless BillingBases.include?(self.billing_basis)
      errors.add :billing_basis, "Invalid billing frequency '#{self.billing_basis}'"
      throw :halt
    end
  end

  def url(root = false)
    prefix = root ? "" : client.url(true)
    "#{prefix}/projects/#{id}"
  end

  # def current_task
  #   current_session && current_session.task
  # end

  def active_tasks
    tasks.all({ :status.not => [ :complete, :abandoned ] })
  end

  def inactive_tasks
    tasks.all({ :status => [ :complete, :abandoned ] })
  end
end