migration 1, :create_default_clients do
  up do
    User.each do |user|
      user.clients.create({
        name: 'Default Client'
      })
    end
  end

  down do
    User.each do |user|
      if client = user.clients.first({ name: 'Default Client' })
        client.destroy
      end
    end
  end
end