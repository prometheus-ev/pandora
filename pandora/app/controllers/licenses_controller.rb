class LicensesController < ApplicationController

  def self.initialize_me!  # :nodoc:
    control_access [:superadmin, :admin] => :ALL
  end

  def destroy
    @license = License.find(params[:id])

    if @license.valid_from < Time.now
      flash[:warning] = 'You can only delete upcoming Licenses.'.t
    elsif @license.destroy
      flash[:notice] = 'License successfully deleted!'.t
    end

    redirect_to institution_path(@license.institution)
  end

  initialize_me!

end
