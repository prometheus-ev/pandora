namespace :pandora do

  desc "Inform users about impending expiration of their account"
  task :expiration_notification => :environment do
    options = options_from_env

    # REWRITE: use update glue code
    # expiring = Account.find(:all,
    #   { :conditions => 'notified_at IS NULL AND email_verified_at IS NOT NULL' }.
    #     merge_conditions(Account.conditions_for_status).
    #     merge_conditions(Account.conditions_for_expires.merge(:readonly => false))
    # )
    expiring = Upgrade.conds_to_scopes(Account,
      { :conditions => 'notified_at IS NULL AND email_verified_at IS NOT NULL' }.
        merge_conditions(Account.conditions_for_status).
        merge_conditions(Account.conditions_for_expires.merge(:readonly => false))
    )

    unless expiring.empty?
      expiring.each { |account|
        begin
          account.deliver(:expiration_notification)
          account.notified!
        rescue Timeout::Error => err
          print_err(err, account.email)
        end
      }

      unless options[:quiet]
        puts "#{num = expiring.size} expiration notification#{'s' if num != 1} sent"
        puts
        puts expiring.sort_by(&:expires_at).map { |account|
          "#{account.expires_at} . . . #{account.login} <#{account.email}>"
        }
      end
    end
  end

end
