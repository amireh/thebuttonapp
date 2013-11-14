object @project

attributes :id, :name, :billing_rate, :billing_currency, :billing_basis

node :tasks do |project|
  project.tasks.map do |task|
    partial "tasks/show", object: task
  end
end

node(:media) do |project|
  {
    url: project.url,
    tasks: {
      url: project.url(true) + '/tasks'
    }
  }
end
