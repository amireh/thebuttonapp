post '/reports' do
  tags = []
  if params[:tags] && params[:tags].is_a?(Array)
    params[:tags].each do |tag_id|
      tags << @user.tags.get(tag_id)
    end
  end # tag filters

  date = { b: Time.now, e: Time.now }

  case params[:date][:range]
  when 'current_month'
    date[:b] = Timetastic.this.month
    date[:e] = Timetastic.next.month
  when 'current_year'
    date[:b] = Timetastic.this.year
    date[:e] = Timetastic.next.year
  when 'last_month'
    date[:b] = Timetastic.last.month
    date[:e] = Timetastic.last.month
  when 'last_year'
    date[:b] = Timetastic.last.year
    date[:e] = Timetastic.last.year
  when 'custom'
    begin
      date[:b] = params[:date][:from].to_date(false)
      date[:e] = params[:date][:to].to_date(false)
    rescue
      halt 400, "Invalid report date range"
    end
  end

  puts "Generating a report from #{date[:b].strftime('%d')} to #{date[:e].strftime('%d')}"
  puts "Filters: #{tags.collect { |t| t.name }.join(', ')}"

  @sessions = @user.work_sessions({
    :started_at.gte => date[:b],
    :finished_at.lte => date[:e]
  })

  tag_names = tags.collect { |t| t.name }

  unless tag_names.empty?
    @sessions.delete_if { |ws|
      has_any_tag = false
      ws.task.tags.each do |t|
        if tag_names.include?(t.name)
          has_any_tag = true
          break
        end
      end

      !has_any_tag
    }
  end

  @tags = tags
  if @tags.empty?
    @tags = @sessions.collect { |ws| ws.task.tags }.flatten.uniq
  end

  @date = date
  erb :"/reports/show"
end

get '/reports/new' do
  erb :"reports/new"
end