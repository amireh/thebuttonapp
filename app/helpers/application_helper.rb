module ApplicationHelpers
  def js_view(id)
    @js_views ||= []
    @js_views << """
      <script>
        var Global = this;

        require([ 'views/#{id}' ], function(View) {
          Global.View = new View();

          if (Global.View.render) {
            Global.View.render();
          }
        });
      </script>
    """
  end

  def tag_collection(*taggables)
    tags = taggables.flatten.map { |taggable| taggable.tags }.flatten.uniq
    tags.collect { |tag| tagify "##{tag.name}" }
  end

  def pdf?
    (request && request.content_type && request.content_type =~ /pdf/) ||
    (response && response.content_type && response.content_type =~ /pdf/)
  end

  # Used in the generation of email verification links
  def __host
    request.referer && request.referer.scan(/http:\/\/[^\/]*\//).first[0..-2]
  end

  def current_page(page = nil)
    session[:current_page] = page if page
    session[:current_page]
  end

  def provider_name(p)
    provider = ''
    if p.is_a?(User)
      provider = p.provider
    else
      provider = p
    end

    case provider.to_s
    when 'algol';         AppName
    when 'facebook';      'Facebook'
    when 'twitter';       'Twitter'
    when 'github';        'GitHub'
    when 'google_oauth2'; 'Google'
    end
  end

  # Loads the user's preferences merging them with the defaults
  # for any that were not overridden.
  #
  # Side-effects:
  # => @preferences will be overridden with the current user's settings
  def preferences(user = nil)
    user ||= current_user

    if !user
      return settings.default_preferences
    elsif @preferences
      return @preferences
    end

    @preferences = {}
    prefs = user.settings
    if prefs && !prefs.empty?
      begin; @preferences = JSON.parse(prefs); rescue; @preferences = {}; end
    end

    defaults = settings.default_preferences.dup
    @preferences = defaults.deep_merge(@preferences)
    @preferences
  end

  def pretty_time(datetime)
    datetime.strftime("%D")
  end

  def natural_join(ary, delim, last_delim, affixes = [])
    c = ''
    ary.each_with_index { |s, i|
      affixed_s = case affixes.empty?
      when true;  s
      when false; "#{affixes.first}#{s}#{affixes.last}"
      end

      d = case i
      when 0; ''
      when ary.length - 1; last_delim
      else; delim
      end

      c << "#{d}#{affixed_s}"
    }
    c
  end

  def to_jQueryUI_date(d)
    d.strftime("%m/%d/%Y")
  end

  # Disabled: Is::Locatable
  #
  # def actions_for(r)
  #   html = ''
  #   if r.is_locatable?
  #     html << "<a href=\"#{url_for(r, :edit)}\">Edit</a>"
  #     html << " <a href=\"#{url_for(r, :destroy)}\" class=\"bad\">Delete</a>"
  #     if r.is_a?(Recurring)
  #       action = r.active? ? 'Deactivate' : 'Activate'
  #       html << " <a href=\"#{url_for(r, :toggle_activity)}\">#{action}</a>"
  #     end
  #   end
  #   html
  # end

  def actions_for(r)
    html = ''
    if r.respond_to?(:url)
      html << "<a href=\"#{r.url}/edit\">Edit</a>"

      if r.is_a?(Recurring)
        action = r.active? ? 'Deactivate' : 'Activate'
        html << " <a href=\"#{r.url}/toggle_activity\">#{action}</a>"
      end

      html << " <a href=\"#{r.url}/destroy\" class=\"bad\">Delete</a>"
    end

    html
  end

  def md(s)
    s.to_markdown
  end

  def tagify(s)
    s.gsub(/#\S+/) { |match|
      name = match.strip.gsub('#', '')
      t = current_user.tags.first({ name: name })
      if t
        "<a href=\"/tags/#{t.id}\">##{t.name}</a>"
      else
        match
      end
    }
  end

  def unlink(str)
    str.gsub(/<a.*>.*<\/a>/, '')
  end

  def ws_summary(ws)
    value = ws.summary

    if !value || value.empty?
      value = '<em class="item-missing">Summary not available.</em>'
    end

    value
  end

  def pretty_time(a)
    minutes = (a/60).to_i
    minutes.to_s + ' ' + (minutes == 1 ? 'minute' : 'minutes')
  end

  def time_in_hours(a)
    ((a+99)/3600).to_i.to_s+ ' hours'
  end

  def really_pretty_time(a)
    case a
      when 0 then 'hardly a second!'
      when 1 then 'a second'
      when 2..59 then a.to_s + ' seconds'
      when 60..119 then 'a minute' #120 = 2 minutes
      when 120..3540 then (a/60).to_i.to_s+' minutes'
      when 3541..7100 then 'an hour' # 3600 = 1 hour
      when 7101..82800 then ((a+99)/3600).to_i.to_s+ ' hours'
      when 82801..172000 then 'a day' # 86400 = 1 day
      when 172001..518400 then ((a+800)/(60*60*24)).to_i.to_s + ' days'
      when 518400..1036800 then 'a week'
      else ((a+180000)/(60*60*24*7)).to_i.to_s + ' weeks'
    end
  end

  def breadcrumbs(*items)
    html = '<div id="breadcrumbs">'

    html += items.map do |item|
      label, href = *item
      "<a href=\"#{href}\">#{label}</a>"
    end.join('')

    html += '</div>'
  end

  def colorize_progress(ratio)
    case ratio
    when 0..24
      'progress-bar-danger'
    when 25..49
      'progress-bar-warning'
    when 50..74
      'progress-bar-info'
    else
      'progress-bar-success'
    end
  end

  def group_by_weeks(collection, field = :started_at)
    collection.group_by do |item|
      case item.send(field).day
      when 0..7;    1
      when 8..15;   2
      when 16..23;  3
      else;         4
      end
    end
  end

  def total_work_sessions_duration(collection)
    seconds = collection.map(&:duration).reduce(&:+) || 0
    (seconds / 3600).round(2)
  end

  def colorize_task_status(status)
    case status.to_s.downcase
    when 'active'
      'info'
    when 'complete'
      'success'
    when 'abandoned'
      'danger'
    when 'pending'
      'warning'
    end
  end
end

helpers ApplicationHelpers