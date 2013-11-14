migration 4, :drop_task_users do
  up do
    modify_table :tasks do
      drop_column :user_id
    end
  end

  down do
    modify_table :tasks do
      add_column :user_id, Integer, :allow_nil => false
    end
  end
end
