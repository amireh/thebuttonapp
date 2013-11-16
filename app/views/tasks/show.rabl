object @task => ""

attributes :id, :name, :details, :status, :flagged_at, :created_at, :project_id

node :work_sessions do |task|
  task.work_sessions.map do |work_session|
    partial "work_sessions/show", object: work_session
  end
end

node(:media) do |task|
  {
    url: task.url,
    work_sessions: {
      url: task.url(true) + '/work_sessions'
    }
  }
end
