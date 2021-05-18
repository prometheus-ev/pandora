class AdministrationController < ApplicationController
  def self.initialize_me!  # :nodoc:
    control_access [:superadmin, :admin] => :ALL,
                   [:useradmin, :user, :dbadmin] => :index
  end

  def index
    unless current_user.admin_or_superadmin?
      redirect_to controller: 'accounts'
    end
  end

  initialize_me!

end
