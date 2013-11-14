namespace :tba do
  desc 'work sessions without a summary'
  task :ws_without_summary => :environment do
    work_sessions = WorkSession.all.select { |ws|
      !ws.summary || ws.summary.empty?
    }

    puts "#{WorkSession.all.length} work sessions in total."
    puts "\t#{work_sessions.length} don't have a summary."
    work_sessions_with_notes = work_sessions.select { |ws| ws.notes.any? }
    puts "\t#{work_sessions_with_notes.length} of them have notes"

    class Task
      has n, :notes, :constraint => :destroy
    end

    tasks_with_notes = Task.all.select { |t| t.notes.any? }
    puts "\t#{tasks_with_notes.length} tasks with a note"
  end

  desc 'moves task notes to work sessions'
  task :move_task_notes_to_work_sessions => :ws_without_summary do
    class Task
      has n, :notes, :constraint => :destroy
    end

    tasks = Task.all.select { |t| t.notes.any? }
    fixmap = []
    tasks.each do |task|
      task.notes.each do |note|
        timestamp = note.created_at

        ws = task.work_sessions.first({
          :started_at.lte => timestamp,
          :finished_at.gte => timestamp
        })

        if ws
          fixmap << { note_id: note.id, work_session_id: ws.id }
        end
      end
    end

    fixmap.each do |entry|
      note = Note.get(entry[:note_id])
      ws = WorkSession.get(entry[:work_session_id])
      task = note.task

      ws.notes << note
      ws.save

      note = note.refresh
      note.task = nil
      note.save

      task = task.refresh
      task.notes.delete(note)
      task.save
    end

    puts "#{fixmap.length} notes have been moved."
  end

  desc 'moves work session notes to summary'
  task :ws_summaries => :move_task_notes_to_work_sessions do
    work_sessions = WorkSession.all.select { |ws|
      (!ws.summary || ws.summary.empty?) && !ws.notes.empty?
    }

    work_sessions.each do |ws|
      ws.update({ summary: ws.notes.first.content })
      ws.notes.first.destroy
    end

    puts "#{work_sessions.length} work sessions fixed."
  end
end