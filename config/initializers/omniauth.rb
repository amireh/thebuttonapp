configure :development, :production do |settings|
  use OmniAuth::Builder do
    OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }

    provider :developer if settings.development?
    provider :facebook, settings.credentials['facebook']['key'], settings.credentials['facebook']['secret']
    # provider :twitter,  settings.credentials['twitter']['key'],  settings.credentials['twitter']['secret']
    provider :google_oauth2,
      settings.credentials['google']['key'],
      settings.credentials['google']['secret'],
      { access_type: "offline", approval_prompt: "" }
    provider :github,   settings.credentials['github']['key'],  settings.credentials['github']['secret']
  end
end