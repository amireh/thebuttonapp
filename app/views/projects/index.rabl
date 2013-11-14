node(:projects) do |project|
  # projects.map do |project|
    partial "projects/show", object: project
  # end
end