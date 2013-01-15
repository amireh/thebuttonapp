route_namespace '/tags' do
  condition do restrict_to(:user) end

  get '/:id' do |tag_id|
    unless @tag = @user.tags.get(tag_id.to_i)
      halt 400, 'No such tag'
    end

    @tasks = @tag.tasks

    erb :"/tags/show"
  end
end