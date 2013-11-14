node(:work_sessions) do |work_sessions|
  @work_sessions.map do |work_session|
    partial "work_sessions/show", object: work_session
  end
end