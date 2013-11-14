AppName       = "thebuttonapp"
AppSlogan     = "Track your hours"
AppURL        = "http://www.thebuttonapp.com"
AppGithubURL  = "https://github.com/amireh/thebuttonapp"
AppIssueURL   = "#{AppGithubURL}/issues"

configure do |app|
  require "config/initializers/filesystem"
  require "config/initializers/cookies"
  require "config/initializers/datamapper"
  require "config/initializers/omniauth"
  require "config/initializers/pony"
  require "config/initializers/gravatarify"
  require "config/initializers/rabl"
  require "config/initializers/pdfkit"
end
