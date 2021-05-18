module InstitutionsHelper
  def list_sort_links(klass = Institution)
    @is_admin ? super : super(%w[Title City Country])
  end

  def license_for(institution)
    if institution.license
      h(institution.license)
    elsif institution.licensee
      'via %s' / link_to_if(
        current_user && current_user.action_allowed?('institutions', 'show'),
        h(institution.licensee),
        institution_path(institution.licensee)
      )
    end
  end

  def format_license(license)
    from = pm_l(license.valid_from, format: :date_only)
    to = pm_l(license.expires_at, format: :date_only)
    "#{from} - #{to}: #{license}"
  end
end
