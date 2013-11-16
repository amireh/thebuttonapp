module JavaScriptHelpers
  def js_env(opts = {})
    @@js_injections ||= 0
    @@js_injections += 1

    injection_id = "injection_#{@@js_injections}"
    injection = opts.map do |k,v|
      "window.ENV['#{k.upcase}'] = #{v};"
    end.join("\n")

    content_for :js_injections do
      """
      <script id=\"#{injection_id}\">
        window.ENV = window.ENV || {};
        #{injection}
        document.getElementById('#{injection_id}').remove();
      </script>
      """
    end
  end

  def js_inject(resource)
    @injected ||= {}
    name = resource.class.name.underscore.to_sym

    unless @injected[name]
      injections = {}
      injections[name] = rabl(:"#{name.to_s.to_plural}/show", object: resource)
      js_env(injections)

      @injected[name] = true
    end

  end

end

helpers JavaScriptHelpers