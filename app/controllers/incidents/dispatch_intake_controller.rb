class Incidents::DispatchIntakeController < Incidents::BaseController
  inherit_resources
  defaults resource_class: Incidents::CallLog, collection_name: :call_logs, route_instance_name: :dispatch_intake
  belongs_to :chapter, parent_class: Incidents::Scope, finder: :find_by_url_slug!

  load_and_authorize_resource class: "Incidents::CallLog"

  before_filter :authorize_dispatch_console!

  actions :new, :create, :show

  def create
    create! { resource.call_type == 'referral' ? incidents_chapter_dispatch_index_path(parent) : smart_resource_url }
  end

  protected

  def collection
    super.where{status == 'open'}
  end

  def create_resource obj
    super(obj).tap do |success|
      if success && obj.call_type == 'incident'
        Incidents::NewDispatchService.create obj
      end
    end
  end

  def resource_params
    [params.fetch(:incidents_call_log, {}).permit(:call_type, :call_start, :contact_name, :contact_number, :address_entry,
      :address, :city, :state, :zip, :county, :lat, :lng, :chapter_id, :territory_id,
      :incident_type, :services_requested, :num_displaced, :referral_reason).merge(dispatching_chapter_id: current_chapter.id, creator_id: current_user.id)]
  end

  def authorize_dispatch_console!
    authorize! :dispatch_console, parent
  end

end