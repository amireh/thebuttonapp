object @user => ""

attributes :id, :name
node :clients do |user|
  user.clients.map do |client|
    partial "clients/show", object: client
  end
end
