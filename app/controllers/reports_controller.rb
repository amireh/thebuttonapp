# sets 3 instance vars:
# => @sessions: [ WorkSession ]
# => @tags: [ Tag ]
# => @date: { b: DateTime, e: DateTime }
def generate_report()
  tags = []

  api_required!({
    project_id: lambda { |project_id|
      unless @project = @user.projects.get(project_id)
        return 'No such project.'
      end
    }
  })

  api_optional!({
    exclude: nil
  })

  if params[:tags] && params[:tags].is_a?(Array)
    params[:tags].each do |tag_id|
      tags << @user.tags.get(tag_id)
    end
  end # tag filters

  if api_param(:exclude) then
    tags = @user.tags - tags
  end


  date = { b: Time.now, e: Time.now }

  case params[:date][:range]
  when 'current_week'
    date[:b] = Time.now.beginning_of_week
    date[:e] = Time.now.end_of_week
  when 'current_month'
    date[:b] = Time.now.beginning_of_month
    date[:e] = Time.now.end_of_month
  when 'current_year'
    date[:b] = Time.now.beginning_of_year
    date[:e] = Time.now.end_of_year
  when 'last_week'
    date[:b] = 1.week.ago.beginning_of_week
    date[:e] = 1.week.ago.end_of_week
  when 'last_month'
    date[:b] = 1.month.ago.beginning_of_month
    date[:e] = 1.month.ago.end_of_month
  when 'last_year'
    date[:b] = 1.year.ago.beginning_of_year
    date[:e] = 1.year.ago.end_of_year
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

  q = {
    :started_at.gte => date[:b],
    :finished_at.lte => date[:e]
  }

  if params[:hide_short_sessions] == 'yes'
    q.merge!({ :duration.gte => 300 })
  end

  @sessions = @project.work_sessions(q.merge({ order: [ :started_at.asc ] }))

  if params[:hide_abandoned_tasks] == 'yes'
    @sessions.reject! { |ws| ws.task.abandoned? }
  end

  if params[:hide_active_tasks] == 'yes'
    @sessions.reject! { |ws| ws.task.status == :active }
  end

  if params[:hide_pending_tasks] == 'yes'
    @sessions.reject! { |ws| ws.task.status == :pending }
  end

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
end

post '/reports' do
  generate_report

  erb :"/reports/show"
end

post '/reports.pdf' do
  content_type :pdf

  generate_report

  footer_html = erb :'/reports/_pdf_footer', layout: false
  footer_path = File.join settings.tmp_folder, 'reports', "#{Time.now.to_i.to_s}_footer_#{Algol.tiny_salt}.html"
  footer_file = File.open(footer_path, 'w')
  footer_file.write(footer_html)
  footer_file.close

  # cover_html = erb :'/reports/_pdf_cover', layout: false
  # cover_path = File.join settings.tmp_folder, 'reports', "#{Time.now.to_i.to_s}_cover_#{ApplicationHelpers::Algol.tiny_salt}.html"
  # cover_file = File.open(cover_path, 'w')
  # cover_file.write(cover_html)
  # cover_file.close

  report_title = "Report #{@date[:b].strftime('%m-%d-%y')} - #{@date[:e].strftime('%m-%d-%y')}, #{@user.name}"
  report_path = File.join settings.tmp_folder, 'reports', "report_#{Algol.tiny_salt}.pdf"

  html = erb :"/reports/show"
  kit = PDFKit.new(html, {
    footer_html: footer_path,
    debug_javascript: true,
    # cover: cover_path,
    # allow: settings.public_folder,
    title: report_title
  })

  # kit.stylesheets << File.join(settings.public_folder, 'app.css')
  kit.stylesheets << File.join(settings.public_folder, 'app-pdf.css')
  kit.to_file(report_path)
  # pdf = kit.to_pdf
  File.delete(footer_path)
  # File.delete(cover_path)
  # pdf
  send_file(report_path, disposition: 'attachment', filename: report_title)
  File.delete(report_path)
end

get '/reports/new' do
  @tags = @user.tags
  orphaned_tags = []
  @tags.each { |tag|
    orphaned_tags << tag if tag.tasks.empty?
  }
  orphaned_tags.each { |t| t.destroy }

  erb :"reports/new"
end