class UserMetadataController < ApplicationController
  def self.initialize_me!
    control_access([:user] => :ALL)
  end

  def update
    @user_metadata = UserMetadata.upsert(params[:pid], user_metadata_params)

    if @user_metadata.save
      @user_metadata.to_elastic

      render json: {message: 'value has been stored'.t}
    else
      render json: @user_metadata.errors, status: 422
    end
  end


  protected

    def user_metadata_params
      result = params.
        permit(:field, :position, :value).
        merge(account: current_user)

      if result[:position]
        result[:position] = result[:position].to_i
      end

      result
    end

    def original_value
      super_image = Pandora::SuperImage.find(params[:pid])

      if Indexing::IndexFields.index.include?(params[:field])
        super_image.send(params[:field])
      end
    rescue ActiveRecord::RecordNotFound => e
      nil
    end
end