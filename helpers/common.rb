helpers do

  module Algol
    def self.password_salt()
      rand(36**16).to_s(32)[0..6]
    end

    def self.tiny_salt(r = 3)
      Base64.urlsafe_encode64 Random.rand(1234 * (10**r)).to_s(8)
    end

    def self.sane_salt(pepper)
      Base64.urlsafe_encode64( pepper + Time.now.to_s)
    end

    def self.salt(pepper = "")
      pepper = Random.rand(12345 * 1000).to_s if pepper.empty?
      pepper = pepper + Random.rand(1234).to_s
      sane_salt(pepper)
    end
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

  def colored_pm(pm)
    "<span style=\"color: ##{pm.color};\">#{pm.name}</span>"
  end

  def tx_to_html(t)
    "[ #{t.withdrawal? ? '-' : '+'} ] #{t.currency} #{t.amount.to_f} #{t.categories.collect { |c| c.name }} on #{pretty_time t.occured_on} - #{t.note}"
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

  def natural_recurrence_date(recurring_tx)
    case recurring_tx.frequency
    when :monthly; "The #{recurring_tx.recurs_on.day.ordinalize} of every month"
    when :yearly;  "The #{recurring_tx.recurs_on.day.ordinalize} of #{recurring_tx.recurs_on.strftime("%B")}"
    end
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

  def pretty_time(a)
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

end

