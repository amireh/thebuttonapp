module Sinatra
  module Templates
    def erb(template, options={}, locals={})
      render :erb, template.to_sym, { layout: @layout }.merge(options), locals
    end

    def partial(template, options={}, locals={})
      erb template.to_sym, options.merge({ layout: false }), locals.merge({ is_partial: true })
    end
  end
end