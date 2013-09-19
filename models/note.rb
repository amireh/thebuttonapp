class Note
  include DataMapper::Resource

  property    :id,          Serial
  property    :content,     Text
  property    :created_at,  DateTime, default: lambda { |*_| DateTime.now }

  belongs_to :task,         required: false
  belongs_to :work_session, required: false

  def url
    prefix = work_session ?
      work_session.url :
      task ?
        task.url :
        ''

    "#{prefix}/notes/#{id}"
  end
end