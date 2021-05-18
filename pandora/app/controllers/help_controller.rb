class HelpController < ApplicationController

  skip_before_action :login_required

  helper_method :pages, :previous_page, :next_page

  def show
    if params[:section].blank?
      render action: 'show'
      return
    end

    i = pages.find_index{|page| page[:section] == params[:section]}
    unless i.nil?
      render action: params[:section]
      return
    end

    flash[:info] = 'There currently exists no help page for %s.' / params[:section].humanize.t
    render action: 'show'
  end


  protected

    def pages
      @pages ||= [
        {section: 'signup', label: 'Signup'.t},
        {section: 'login', label: 'Login'.t},
        {section: 'search', label: 'Search'.t},
        {section: 'syntax', label: 'Query syntax'.t},
        {section: 'results', label: 'Results list'.t},
        {section: 'copyright_and_publication', label: 'Copyright and publication'.t},
        {section: 'collection', label: 'Collection'.t},
        {section: 'uploads', label: 'My Uploads'.t},
        {section: 'sidebar', label: 'Sidebar'.t},
        {
          section: 'administration',
          label: 'Administration'.t,
          sub_pages: (
            current_user && current_user.useradmin_like? ?
            [
              {section: 'administration', anchor: 'personal_account', label: 'Managing your personal account'.t},
              {section: 'administration', anchor: 'management', label: 'Administrator management'.t}
            ] :
            nil
          )
        },
        {section: 'profile', label: 'Profile'.t}
      ]
    end

    def previous_page
      i = pages.find_index{|page| page[:section] == params[:section]}
      return nil if i == nil
      i == 0 ? nil : pages[i - 1]
    end

    def next_page
      i = pages.find_index{|page| page[:section] == params[:section]}
      return nil if i == nil
      i == pages.size - 1 ? nil : pages[i + 1]
    end

end
