node(:tasks) do |tasks|
  @tasks.map do |task|
    partial "tasks/show", object: task
  end
end