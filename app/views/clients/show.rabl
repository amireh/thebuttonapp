object @client

attributes :id, :name

node :projects do |client|
  client.projects.map do |project|
    partial "projects/show", object: project
  end
end

node(:media) do |client|
  {
    url: client.url,
    projects: {
      url: client.url(true) + '/projects'
    }
  }
end
