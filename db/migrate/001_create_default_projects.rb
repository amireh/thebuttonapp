migration 2, :create_default_projects do
  up do
    User.each do |user|
      unless client = user.clients.first({ name: 'Default Client' })
        raise "User #{user.id} has no default client defined!"
      end

      client.projects.create({
        name: 'Default Project'
      })
    end
  end

  down do
    User.each do |user|
      if client = user.clients.first({ name: 'Default Client' })
        if project = client.projects.first({ name: 'Default Project' })
          project.destroy
        end
      end
    end
  end
end