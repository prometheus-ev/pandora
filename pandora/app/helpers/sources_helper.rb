module SourcesHelper

  def is_dbuser_profile?
    current_user && current_user.dbuser? && @source && current_user ==@source.dbuser
  end

end