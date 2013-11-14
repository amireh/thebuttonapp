object @work_session => ""

attributes :id, :summary, :active, :started_at, :finished_at, :duration

node :notes do |work_session|
  work_session.notes.map do |note|
    partial "notes/show", object: note
  end
end

node(:media) do |work_session|
  {
    url: work_session.url,
    notes: {
      url: work_session.url(true) + '/notes'
    }
  }
end
