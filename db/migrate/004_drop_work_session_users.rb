migration 5, :drop_work_session_users do
  up do
    modify_table :work_sessions do
      drop_column :user_id
    end
  end

  down do
    modify_table :work_sessions do
      add_column :user_id, Integer, :allow_nil => false
    end
  end
end
