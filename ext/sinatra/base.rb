module Sinatra
  class Base
    class << self
      # for every DELETE route defined, a "legacy" GET equivalent route is defined
      # at @{path}/destroy for compatibility with browsers that do  not support
      # XMLHttpRequest and thus the DELETE HTTP method
      def delete(path, opts={}, &bk)
        route 'GET'   , "#{path}/destroy",  opts, &bk
        route 'DELETE', path,               opts, &bk
      end

      def put(path, opts={}, &bk)
        route 'PUT' , path,  opts, &bk
        route 'POST', path,  opts, &bk
        route 'PATCH', path,  opts, &bk
      end
    end
  end
end