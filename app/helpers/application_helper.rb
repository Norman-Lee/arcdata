module ApplicationHelper
  def editable_select(resource, name, options, is_boolean: false)
    model_name = resource.class.model_name.param_key
    attr_name = "#{model_name}_#{name}"
    value = resource.send(name.to_sym)
    if is_boolean
      value = value ? 1 : 0
    else
      value = value ? value.to_s : ""
    end
    str=<<-END
    <a href="#" id="#{attr_name}" data-name="#{name}" data-type="select" data-resource="#{model_name}" data-url="#{send "#{model_name}_path", resource}"></a>
    <script>
      $("##{attr_name}").editable({
        source: #{options.to_json},
        value: #{value.to_json}
      })
    </script>
    END
    str.html_safe
  end

  def has_admin_dashboard_access
    @_admin_access = current_user && current_user.has_role( 'chapter_config')
  end

  def current_messages
    if current_user and ENV['MOTD_ENABLED']
      @_current_messages ||= MOTD.active(current_chapter).to_a.select{|motd|
        motd.path_regex.nil? or motd.path_regex.match(request.fullpath)
      }
    else
      []
    end
  end

  def asset_url(*args)
    "#{request.protocol}#{request.host_with_port}#{asset_path(*args)}"
  end

  def branding(classes=[])
    request.env['HTTP_HOST'] =~ /arcbadat/i ? arcbadat_branding(classes) : dcsops_branding(classes)
  end

  def page_title
    request.env['HTTP_HOST'] =~ /arcbadat/i ? 'ARCBA DAT' : 'DCSOps'
  end

  def arcbadat_branding(classes=[])
    s = ActiveSupport::SafeBuffer.new
    s << "ARCBA"
    s << content_tag(:strong, "DAT", class: classes)
  end

  def dcsops_branding(classes=[])
    s = ActiveSupport::SafeBuffer.new
    s << "DCS"
    s << content_tag(:strong, "Ops", class: classes)
  end
end
