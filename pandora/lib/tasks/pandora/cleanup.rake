namespace :pandora do

  def clear_stale(what, duration = '1 week', attribute = 'updated_at')
    options = options_from_env

    table = what.downcase.gsub(/\s/, '_')

    desc "Clear #{what} older than #{duration} (or DATE=YYYY-MM-DD)"
    task "clear_stale_#{table}" => :environment do
      date = options[:date] || duration.split.
        inject { |i, j| i.to_i.send(j) }.ago.utc.strftime('%Y-%m-%d')

      num = ActiveRecord::Base.connection.delete(
        "DELETE FROM #{table} WHERE #{attribute} <= '#{date}'"
      )

      silent_log "#{date}: #{num} #{num != 1 ? what : what.singularize} deleted"
    end
  end

  def silent_log(msg = nil)
    if ENV['PM_SILENT'] != 'true'
      puts msg
    end
  end

  clear_stale 'sessions'
  clear_stale 'rate limits', '1 day', 'timestamp'

  desc "List accounts that haven't finished the signup process"
  task :stale_signups => :environment do
    options = options_from_env

    date  = 1.month.ago.utc
    # REWRITE: use upgrade glue code
    # stale = Account.find(:all, Account.conditions_for_stale_signup(date))
    # stale = Upgrade.conds_to_scopes(Account, Account.conditions_for_stale_signup(date))
    stale = Account.stale_signups

    silent_log "#{date}: #{num = stale.size} stale signup#{'s' if num != 1}"
    silent_log
    silent_log stale.sort_by(&:created_at).map { |account|
      "#{account.created_at} . . . [#{account.id}] #{account.login} <#{account.email}>"
    }

    if ENV['CLEAR'] == 'true'
      stale.each do |account|
        account.destroy
      end

      silent_log
      silent_log 'CLEARED!'
    end
  end

  desc "Clear accounts that haven't finished the signup process"
  task 'clear_stale_signups' do
    ENV['CLEAR'] = 'true'
    Rake::Task['pandora:stale_signups'].invoke
  end
end
