migration 3, :move_tasks_to_projects do
  up do
    class Task
      belongs_to :user, required: false
    end

    User.each do |user|
      unless project = user.projects.first({ name: 'Default Project' })
        raise "User #{user.id} has no default project!"
      end

      tasks = DataMapper.repository.adapter.select(<<-SQL
        SELECT * FROM tasks WHERE
          user_id=#{user.id} AND
          project_id=0
      SQL
      )
      tasks.each do |task|
        Task.get(task.id).update!({ project_id: project.id })
      end
    end
  end

  down do
    class Task
      belongs_to :user, User, required: false
    end

    User.each do |user|
      if project = user.projects.first({ name: 'Default Project' })
        tasks = DataMapper.repository.adapter.select(<<-SQL
          SELECT * FROM tasks WHERE
            user_id=#{user.id} AND
            project_id=#{project.id}
        SQL
        )
        tasks.each do |task|
          Task.get(task.id).update!({ project_id: 0 })
        end
      end
    end
  end
end
