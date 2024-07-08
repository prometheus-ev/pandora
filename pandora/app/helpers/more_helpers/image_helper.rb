module MoreHelpers
  module ImageHelper
    def image_tag_for(image, size = :small, options = {}, cachable = false)
      si = Pandora::SuperImage.from(image)

      # cachable is always false, so we can
      # options[:src] = cachable ? image.data_uri(size) : si.image_url(size)
      options[:src] = si.image_url(size)
      options[:alt] ||= "[#{'Not available'.t}]"

      if options.delete(:size) =~ /\A(\d+)x(\d+)\z/
        options[:width], options[:height] = $1, $2
      end

      tag('img', options)
    end

    def link_to_image_record_by_name(image, name, options = {}, html_options = {})
      si = Pandora::SuperImage.from(image)
      image_title = hover_over_image_title(si)
      if name.blank?
        name = image_title
      end

      link_to_if(
        si.has_record?,
        name,
        {:controller => 'images', :action => 'show', :id => si.pid}.reverse_merge(options),
        {:title => image_title}.merge(html_options)
      )
    end

    def link_to_image_record(image, img_size = :small, options = {}, cachable = false, img_options = {}, html_options = {})
      link_to_image_record_by_name(
        image,
        image_tag_for(image, img_size, img_options, cachable),
        options,
        html_options
      )
    end

    def link_to_zoomable_image(image, zoom_size = :medium, img_size = :small, options = {}, img_options = {}, html_options = {})
      si = Pandora::SuperImage.from(image)

      link_to_image_record(
        image,
        img_size,
        options,
        false,
        img_options.merge(:_zoom_src => si.image_url(zoom_size)),
        html_options
      )
    end

    def hover_over_image_title(super_image)
      image_title = super_image.artist.blank? ? "" : super_image.artist
      if super_image.title.blank?
        image_title += ""
      else
        if image_title.blank?
          image_title += super_image.title
        else
          image_title += ": #{super_image.title}"
        end
      end
      if super_image.location.blank?
        image_title += ""
      else
        if image_title.blank?
          image_title += super_image.location
        else
          image_title += ", #{super_image.location}"
        end
      end
    end

    def upload_image(image, icons = false, edit = false, delete = false)
      res = <<-EOT
        <div class="upload-item">
      EOT
      res << <<-EOT if icons
          <div class="icons">#{image_controls(image)}</div>
      EOT
      res << <<-EOT
          <div class="image_wrap">
            <div class="image">#{link_to_zoomable_image(image, 280)}</div>
            <div class="dim">#{link_to_rating(image)} (#{image.votes})</div>
          </div>
      EOT

      res << upload_image_manipulation_icons(image, edit, delete)
      res << '</div>'

      res.html_safe
    end

    def upload_image_manipulation_icons(image, edit = false, delete = false)
      return '' unless image.upload_record? && (edit || delete)

      res = <<-EOT
        <div class="icons dim">
      EOT
      res << <<-EOT if delete
          <div>#{link_to(image_tag('icon/delete.gif', :class => 'icon upload-icon delete-icon upload-delete-icon', :title => 'Delete image from database'.t), {:controller => 'uploads', :action => 'destroy', :id => image.upload.id}, method: 'delete', :confirm => 'Are you sure?'.t)}</div>
      EOT
      res << <<-EOT if edit
          <div>#{link_to(image_tag('icon/edit.gif', :class => "icon upload-icon upload-edit-icon"), {:controller => 'uploads', :action => 'edit', :id => image.upload.id}, :title => 'Edit upload'.t)}</div>
      EOT
      res << <<-EOT if !image.upload.approved_record
          <div class="upload-icon-div">#{image_tag('misc/access_status_private.gif', :class => "upload-approval-icon", :title => 'This image of your database is not available to public collections and presentations until approval of the prometheus office.'.t)}</div>
      EOT
      res << <<-EOT if image.upload.approved_record
          <div class="upload-icon-div">#{image_tag('misc/access_status_readable.gif', :class => "upload-approval-icon", :title => 'This image of your database has been approved by the prometheus office.'.t)}</div>
      EOT
      res << '</div>'

      res.html_safe
    end
  end
end
