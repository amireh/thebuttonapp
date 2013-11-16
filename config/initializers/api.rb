configure do
  register Sinatra::API

  Sinatra::API.configure({
    with_parameter_validation: true
  })
end