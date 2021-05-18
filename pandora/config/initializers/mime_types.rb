# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

# handle special MIME types image/pjpeg and image/x-png used by IE
Mime::Type.register 'image/x-png', :png
Mime::Type.register 'image/pjpeg', :jpg
Mime::Type.register 'image/jpeg', :jpg
Mime::Type.register 'application/octet-stream', :blob
Mime::Type.register 'application/zip', :zip
