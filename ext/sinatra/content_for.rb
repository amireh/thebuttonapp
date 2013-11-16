module Sinatra
  module ContentFor
    def yield_with_default(key, &default)
      unless default
        raise RuntimeError.new "Missing required default block"
      end

      if !content_for?(key)
        content_for(key.to_sym, &default)
      end

      yield_content(key)
    end

    def content_for?(key)
      content_blocks[key.to_sym].any?
    end
  end
end