class Pandora::Cleanup
  def all
    sessions
    rate_limits
    oauth_nonces
    short_urls
    payment_transactions

    stale_signups
    collection_image
    account_role
    settings
  end

  def sessions
    clean_table 'sessions'
  end

  def rate_limits
    clean_table 'rate_limits', timestamp: 1.day.ago, column: 'timestamp'
  end

  def oauth_nonces
    clean_table 'oauth_nonces', timestamp: 1.month.ago
  end

  def short_urls
    clean_table 'short_urls', timestamp: 1.month.ago
  end

  def payment_transactions
    clean_table 'payment_transactions', timestamp: 14.months.ago
  end

  def stale_signups
    timestamp = 1.month.ago
    stale = Account.stale_signups(timestamp)

    silent_log "found #{stale.count} stale signup(s):"

    stale.each do |a|
      a.destroy
      silent_log "  deleted #{a.login} <#{a.email}>"
    end
  end

  def collection_image
    num = ApplicationRecord.connection.exec_delete("
      DELETE jt
      FROM collections_images AS jt
      LEFT JOIN collections AS c ON c.id = jt.collection_id
      LEFT JOIN images AS i ON i.pid = jt.image_id
      WHERE c.id IS NULL OR i.pid IS NULL
    ")

    silent_log "deleted #{num} invalid collection <-> image connections"
  end

  def account_role
    num = ApplicationRecord.connection.exec_delete("
      DELETE jt
      FROM accounts_roles AS jt
      LEFT JOIN accounts AS a ON a.id = jt.account_id
      LEFT JOIN roles AS r ON r.id = jt.role_id
      WHERE a.id IS NULL OR r.id IS NULL
    ")

    silent_log "deleted #{num} invalid account <-> role connections"
  end

  def settings
    stale = Settings.
      left_joins(:user).
      where('accounts.id IS NULL')

    num = Settings.delete(stale)
    silent_log "deleted #{num} invalid settings records"
  end


  protected

    def clean_table(name, timestamp: 1.week.ago, column: 'updated_at')
      date = timestamp.utc.strftime('%Y-%m-%d %H:%M:%S')
      sql = "DELETE FROM #{name} WHERE #{column} <= '#{date}'"
      num = ActiveRecord::Base.connection.delete(sql)

      silent_log "table #{name}: deleted #{num} entries older than #{date} (#{column})"
    end

    def silent_log(msg = nil)
      if ENV['PM_SILENT'] != 'true'
        puts msg
      end
    end

end