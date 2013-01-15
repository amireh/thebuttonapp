class Tag
  include DataMapper::Resource

  property  :id,          Serial
  property  :name,        String, length: 255,
    required: true,
    messages: {
      presence: 'You must provide a name for the tag!'
    }

  property  :created_at,  DateTime, default: lambda { |*_| DateTime.now }

  belongs_to  :user, required: true

  has n, :tasks, :through => Resource, :constraint => :skip

  validates_uniqueness_of :name, :scope => [ :user_id ],
    message: 'You already have such a tag!'

  before :destroy do
    TagTask.all({ tag_id: self.id }).destroy
  end

  def time_spent
    duration = 0
    self.tasks.each do |t|
      duration += t.time_spent
    end
    duration
  end
end