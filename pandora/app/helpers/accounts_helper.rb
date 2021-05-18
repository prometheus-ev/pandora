module AccountsHelper

  # TODO: Perhaps move to controller if we refactor resourceful.
  def object_name_for_controller
    :user
  end

  def link_to_delete(user)
    return if !current_user.admin_or_superadmin? && !user.enabled?

    action = (user.disabled? ? 'destroy' : 'disable')

    link_to(image_tag(
      # REWRITE: the title attribute should be on <a> not the <img>
      # 'icon/delete.gif', :class => 'icon delete-icon', :title => action.humanize.t
      'icon/delete.gif', :class => 'icon delete-icon'
    ), {
      :action => action, :id => user.login
    }, {
      :data => { confirm: "Are you sure to #{action} account: '%s'" / user },
      :method => action == 'destroy' ? 'DELETE' : 'PATCH',
      # REWRITE: see above
      :title => action.humanize.t
    })
  end

end
