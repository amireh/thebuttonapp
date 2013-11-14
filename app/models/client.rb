class Client
  include DataMapper::Resource

  default_scope(:default).update(:order => [ :name.asc ])

  property :id, Serial
  property :name, String
  property :created_at,  DateTime, default: lambda { |*_| DateTime.now }

  belongs_to :user, required: true
  has n, :projects, :constraint => :destroy

  validates_presence_of :name, message: 'You must name this client.'
  validates_uniqueness_of :name, :scope => [ :user_id ],
    message: 'You already have such a client.'

  def url(root = true)
    prefix = root ? "" : user.url(true)

    "#{prefix}/clients/#{id}"
  end
end