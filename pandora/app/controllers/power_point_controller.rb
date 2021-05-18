class PowerPointController < ApplicationController
  def self.initialize_me!
    control_access [:superadmin, :admin, :ipuser, :user] => :ALL
  end

  def collection
    @collection = Collection.find(params[:collection_id])

    if current_user.allowed?(@collection, :read)
      send_data(
        Pandora::PowerPoint.from_collection(@collection).data,
        content_type: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        filename: 'presentation.pptx',
        disposition: 'attachment'
      )
    else
      permission_denied
    end
  end

  initialize_me!
end
