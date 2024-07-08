class CommentsController < ApplicationController
  def self.initialize_me!
    control_access [:superadmin, :user] => :ALL
  end

  def create
    @comment = commentable.comments.build(new_comment_params)
    @comment.author = current_user

    if @comment.save
      flash[:notice] = 'Comment successfully saved!'.t

      index_upload(@comment)
    else
      flash[:warning] = 'There were errors saving your comment!'.t
    end

    redirect_to commentable_url_options.merge(anchor: @comment.anchor)
  end

  def update
    @comment = commentable.comments.find(params[:id])

    unless current_user.allowed?(@comment, :write)
      forbidden
      return
    end

    if @comment.update(comment_params)
      flash[:notice] = 'Comment successfully edited!'.t

      index_upload(@comment)
    else
      flash[:warning] = 'There were errors saving your comment!'.t
    end

    redirect_to commentable_url_options.merge(anchor: @comment.anchor)
  end

  def destroy
    @comment = commentable.comments.find(params[:id])

    unless current_user.allowed?(@comment, :delete)
      forbidden
      return
    end

    @comment.soft_delete!

    index_upload(@comment)

    flash[:notice] = 'Comment successfully deleted!'.t
    redirect_to commentable_url_options.merge(anchor: 'comments')
  end


  protected

    def comment_params
      params.fetch(:comment, {}).permit(:text)
    end

    def new_comment_params
      params.fetch(:comment, {}).permit(:text, :parent_id)
    end

    def commentable
      case params[:type]
      when 'collection' then Collection.find(params[:commentable_id])
      when 'image' then Image.find(params[:commentable_id])
      else
        raise Pandora::Exception, "unknown commentable type: #{params[:type]}"
      end
    end

    def commentable_url_options
      if commentable.is_a?(Collection)
        return {controller: 'collections', action: 'show', id: commentable.id}
      end

      if commentable.is_a?(Image)
        return {controller: 'images', action: 'show', id: commentable.id}
      end
    end

    def index_upload(comment)
      if comment.type == 'image'
        si = comment.image.super_image
        si.index_doc
      end
    end

    initialize_me!
end
