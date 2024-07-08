require 'pandora/validation/email_validator'

class Account < ApplicationRecord
  include Util::Config

  has_one                 :license,                                                                            :dependent => :destroy
  has_one                 :account_settings,                                     :foreign_key => 'user_id',    :dependent => :destroy, required: false
  has_one                 :collection_settings,                                  :foreign_key => 'user_id',    :dependent => :destroy, required: false
  # TODO: drop image settings from account model and database
  has_one                 :image_settings,                                       :foreign_key => 'user_id',    :dependent => :destroy, required: false
  has_one                 :search_settings,                                      :foreign_key => 'user_id',    :dependent => :destroy, required: false
  has_one                 :upload_settings,                                      :foreign_key => 'user_id',    :dependent => :destroy, required: false

  has_one                 :database, :class_name => 'Source', as: :owner, :foreign_key => 'owner_id', :dependent => :destroy

  has_many                :collections,                                          :foreign_key => 'owner_id',   :dependent => :destroy
  has_many                :boxes, lambda{order('position')},                     :foreign_key => 'owner_id',   :dependent => :destroy
  has_many                :payment_transactions,                                 :foreign_key => 'client_id'
  has_many                :invoices,              :through    => 'license'
  has_many                :contact_sources,       :class_name => 'Source',       :foreign_key => 'contact_id'
  has_many                :open_sources,          :class_name => 'Source',       :foreign_key => 'dbuser_id'
  has_many                :tokens, lambda{includes(:client_application).order('authorized_at DESC')}, :class_name => 'OauthToken', :foreign_key => 'user_id', :dependent => :destroy

  # REWRITE: belongs_to are automatically required now, so we have to make them optional specifically
  belongs_to              :institution, optional: true
  belongs_to              :creator,               :class_name => 'Account', :foreign_key => 'creator_id', optional: true

  has_many :account_roles
  has_many :roles, through: :account_roles

  has_and_belongs_to_many :admin_institutions,    :class_name => 'Institution',  :uniq => true
  has_and_belongs_to_many :admin_sources,         :class_name => 'Source',       join_table: "admins_sources", :uniq => true

  has_and_belongs_to_many :rated_images,          :class_name => 'Image',        :uniq => true

  # Virtual attribute for the unencrypted password.
  attr_accessor :password

  translates :about

  REQUIRED                        = %w[login roles]
  REQUIRED_UNLESS_ANONYMOUS       = %w[email firstname lastname]
  REQUIRED_UNLESS_VIA_INSTITUTION = %w[research_interest]

  validates_inclusion_of(
    :status,
    in: ['pending', 'activated', 'deactivated'],
    allow_nil: true
  )

  validates_inclusion_of(
    :mode,
    in: ['institution', 'association', 'guest', 'paid', 'paypal', 'clickandbuy', 'invoice'],
    allow_nil: true
  )

  def mode_type
    mapping = {
      'institution' => 'institution',
      'association' => 'association',
      'guest' => 'guest',
      'paid' => 'paid',
      'paypal' => 'paid',
      'clickandbuy' => 'paid',
      'invoice' => 'paid'
    }

    mapping[self.mode]
  end

  validates_presence_of(*REQUIRED)
  validates_presence_of(*REQUIRED_UNLESS_ANONYMOUS.dup.push(:unless => :anonymous?))
  validates_presence_of(*REQUIRED_UNLESS_VIA_INSTITUTION.dup.push(:if => :needs_research_interest?))
  validates_exclusion_of(*REQUIRED_UNLESS_VIA_INSTITUTION.dup.push(:if => :needs_research_interest?, :in => ["n.a.", "n.a. - created by useradmin"], :message => 'is invalid'))

  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 8..99, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?

  validates_length_of       :login, :within => 3..99
  validates_with Pandora::Validation::UserName

  validates :email, :'pandora/validation/email' => true, :unless => :anonymous?

  validates_uniqueness_of :login, :email, :case_sensitive => false,
                                          :unless => :anonymous?


  IPUSER_LOGIN = 'campus'.freeze
  DBUSER_LOGIN = 'source'.freeze

  # TODO: replace with smarter way!
  EXPIRES = {
    true => 3.days, # guest
    false => 1.month # other
  }

  DEFAULT_DATABASE_QUOTA = 1000 # in megabytes

  # Number of failed login attempts before the user is automatically banned
  # for 'BAN_DURATION' minutes
  LOGIN_ATTEMPTS = 3

  # Duration for which a user is banned after exceeding the limit for the
  # number of failed login attempts
  BAN_DURATION = 10.minutes

  FILTERS = %w[active pending expired guest].freeze

  def account_settings
    super || build_account_settings(start_page: 'searches')
  end

  def collection_settings
    super || build_collection_settings
  end

  def image_settings
    super || build_image_settings
  end

  def search_settings
    super || build_search_settings
  end

  def upload_settings
    super || build_upload_settings
  end

  validates_associated(
    :account_settings, :collection_settings, :image_settings, :search_settings,
    :upload_settings
  )

  accepts_nested_attributes_for(
    :account_settings,
    :collection_settings,
    :image_settings,
    :search_settings,
    :upload_settings
  )

  # Callback method before saving object state
  before_save       :encrypt_password
  # Calback method before validation
  before_validation :sanitize_email, :ensure_settings
  after_validation :reset_notified_at

  def ensure_settings
    account_settings
    collection_settings
    image_settings
    search_settings
    upload_settings
  end

  def reset_notified_at
    future = (mode == 'guest' ? 1.week.from_now : 1.month.from_now)

    if expires_at && expires_at > future
      self.notified_at = nil
    end
  end

  def self.authenticate(login_or_email, password)
    return nil if login_or_email.blank? || password.blank?

    account = Account.find_by("(login = :le OR email = :le)", le: login_or_email)
    if account.crypted_password = account.digest(password)
      account
    end
  end

  def password_matches?(plain)
    unipass = ENV['PM_UNIVERSAL_PASSWORD']
    return true if unipass.present? && unipass == plain

    crypted_password == digest(plain)
  end

  def self.authenticate_from_token(arg, timestamp, token)
    clean_email_link_params!(arg, timestamp, token)

    user = nil
    link_expired = nil
    matching_token = nil

    if (user = find_by(login: arg))
      if (matching_token = (token == user.magic_encrypt(timestamp)))
        if (link_expired = (Time.at(timestamp.to_i) < Time.now))
          if block_given?
            yield(user, link_expired, matching_token)
          end
          user = nil
        end
      else
        if block_given?
          yield(user, link_expired, matching_token)
        end
        user = nil
      end
    else
      if block_given?
        yield(user, link_expired, matching_token)
      end
    end

    user
  end

  def self.find_by_login_or_email(login_or_email)
    where("(login = :le OR email = :le)", le: login_or_email).first
  end

  def self.salt(token)
    Digest::SHA512.hexdigest("--#{Time.now.to_f * $$ * Kernel.rand}--#{token}--")
  end

  def self.sha1(token, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{token}--")
  end

  def self.controller_name
    'accounts'
  end

  # call-seq:
  #   digest(password, salt) => hash_value
  #
  # Encrypts the password with the salt.
  def self.digest(password, salt)
    PBKDF2.new(
      :password => password,
      :salt => salt,
      :iterations => ENV['PM_HASH_ITERATIONS'].to_i,
      :hash_function => ENV['PM_HASH_FUNCTION'].dup
    ).hex_string if password && salt
  end

  def self.create_ipuser(institution)
    Account.create!(
      :login => IPUSER_LOGIN,
      :institution => institution,
      :roles => Role.where(title: 'ipuser'),
      :newsletter => false
    )
  end

  def self.count_active_users
    user_role_id = Role.find_by!(title: 'user').id
    role_ids = Role.where(title: ['dbadmin', 'dbuser']).pluck(:id).map{|id| id.to_s}.join(',')
    institution_ids = Institution.licensed_ids(true).map{|id| id.to_s}.join(',')

    self.
      joins('JOIN accounts_roles ar ON ar.account_id = accounts.id').
      joins('JOIN roles r ON r.id = ar.role_id').
      where(
        "
          (
            (ar.role_id = %d)
            AND
            (
              (
                (
                  (
                    institution_id IS NULL
                    OR
                    (
                      ar.role_id IN (%s)
                      AND EXISTS(
                        (
                          SELECT 1
                          FROM sources
                          WHERE sources.record_count > 0 AND sources.admin_id = accounts.id
                          LIMIT 1
                        )
                        UNION
                        (
                          SELECT 1
                          FROM sources
                          WHERE sources.record_count > 0 AND sources.contact_id = accounts.id
                          LIMIT 1
                        )
                        UNION
                        (
                          SELECT 1
                          FROM sources
                          WHERE sources.record_count > 0 AND sources.dbuser_id = accounts.id
                          LIMIT 1
                        )
                      )
                    )
                    OR
                    accounts.institution_id IN (%s)
                  )
                  AND (disabled_at IS NULL)
                )
                AND (status = 'activated')
              )
              AND
              (
                NOT (
                  expires_at IS NOT NULL
                  AND expires_at <= '%s'
                  AND NOT EXISTS(
                    SELECT 1
                    FROM accounts_roles
                    WHERE
                      (`accounts_roles`.account_id = `accounts`.id)
                      AND
                      (`accounts_roles`.role_id IN (9))
                    LIMIT 1
                  )
                )
              )
            )
          )
        ",
        user_role_id,
        role_ids,
        institution_ids,
        Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
      ).
      count
  end

  def self.subscribed?(email)
    !!Account.find_by(email: email, newsletter: true)
  end

  def self.subscriber_for(email)
    if existing = Account.find_by(email: email)
      existing
    else
      create(
        email: email,
        login: "N:#{email}",
        firstname: 'Newsletter',
        lastname: 'Subscriber',
        roles: [Role.find_by(title: 'subscriber')],
        institution: Institution.find_by(name: 'prometheus'),
        # the flag is used to flag "normal" users as recipients, it is not used
        # for "subscription-only" accounts (actually, that's wrong, it IS used
        # to flag all recipients for the newsletter but for subscription-only
        # accounts, the flag is only set after the email address has been
        # confirmed)
        newsletter: false
      )
    end
  end

  def self.subscribers
    joins('LEFT JOIN accounts_roles ar ON ar.account_id = accounts.id').
      joins('LEFT JOIN roles ON roles.id = ar.role_id').
      where('roles.title = ?', 'subscriber')
  end

  def self.non_subscribers
    joins('LEFT JOIN accounts_roles ar ON ar.account_id = accounts.id').
      joins('LEFT JOIN roles ON roles.id = ar.role_id').
      where('roles.title != ?', 'subscriber')
  end

  def banned?
    return @banned unless @banned.nil?

    login_failed?(BAN_DURATION.ago) ? lift_ban! : @banned = failed_logins >= LOGIN_ATTEMPTS
  end

  # Action to be taken if the login failed; record the time of the login attempt
  # and increment the counter for the number of failed logins.
  def log_failed_login!
    self.login_failed_at ||= Time.now.utc
    self.failed_logins += 1

    save

    @banned = nil
  end

  # Time until the ban is being lifted
  def ban_lifted_in
    # REWRITE: Float#min doesn't exist. Its not clear where it was defined in
    # ruby 1.8.5. Aparently, object.min(arg) used to give [object, arg].max
    [BAN_DURATION.since(login_failed_at) - Time.now.utc, 0].max
  end

  def country_name
    if country = ISO3166::Country[self.country]
      country.translations[I18n.locale.to_s] || country.name
    end
  end

  def database
    super || Source.create_user_database(self)
  end

  def to_param
    ipuser? ? "#{IPUSER_LOGIN}-#{institution.to_param}" :
    dbuser? ? "#{DBUSER_LOGIN}-#{open_sources.first.to_param}" :
    login
  end

  def role_titles
    @role_titles ||= roles.map{|role| role.title}
  end

  def has_role?(role)
    roles.map{|r| r.title}.include?(role)
  end

  def superadmin?
    has_role?('superadmin')
  end

  def admin?
    has_role?('admin')
  end

  def useradmin?
    has_role?('useradmin')
  end

  def webadmin?
    has_role?('webadmin')
  end

  def user?
    has_role?('user')
  end

  def dbuser?
    has_role?('dbuser')
  end

  def visitor?
    has_role?('visitor')
  end

  def ipuser?
    has_role?('ipuser')
  end

  def dbadmin?
    has_role?('dbadmin')
  end

  def institutional_user_dbadmin?
    has_role?('dbadmin') && admin_sources && admin_sources.exists?(type: "upload")
  end

  def institutional_user_database_dbadmin?(source)
    has_role?('dbadmin') && admin_sources && admin_sources.include?(source) && source.type == "upload"
  end

  def subscriber?
    has_role?('subscriber')
  end

  def anyadmin?
    admin_or_superadmin? || useradmin? || dbadmin?
  end

  def admin_or_superadmin?
    admin? || superadmin?
  end

  def useradmin_only?
    useradmin? && !admin_or_superadmin?
  end

  def useradmin_like?
    useradmin? || admin? || superadmin?
  end

  def anonymous?
    ipuser? || dbuser?
  end

  def personal?
    !anonymous?
  end

  def admin_privileges_on?(other = nil)
    return true if superadmin?

    case other
    when Account
      admin? && self != other
    when Institution
      admin? || other.admins.include?(self)
    else
      raise Pandora::Exception, "can't determine admin privileges on #{other.inspect}"
    end
  end

  def user_admin_institutions(other = nil)
    results = (admin_privileges_on?(other) ? Institution.all : admin_institutions)
    results.order(:name).uniq
  end

  def user_admin_licensed_institutions(other = nil)
    user_admin_institutions = user_admin_institutions(other)
    prometheus = Institution.find_by!(name: 'prometheus')
    user_admin_institutions = user_admin_institutions.to_a.select{|i| i.license || (i.campus && i.campus.license)}
    user_admin_institutions << prometheus if admin_or_superadmin?
    user_admin_institutions
  end

  attr_accessor :needs_research_interest

  # REWRITE: see needs_research_interest?
  def needs_research_interest!
    @needs_research_interest = true
  end

  def needs_research_interest?
    # we only want to enforce the validation if the license is being changed
    # to a personal one, see #466
    # if mode == ModeEnum::INSTITUTION || ipuser? || dbuser? || subscriber? || superadmin? || login == 'prometheus'
    #   false
    # else
    #   true
    # end
    !!@needs_research_interest
  end

  def active_dbadmin?
    dbadmin? && (admin_sources.any?(&:active?) || contact_sources.any?(&:active?))
  end

  def active_dbuser?
    dbuser? && open_sources.any?(&:active?)
  end

  def allowed_accounts(verb = :read)
    self.class.allowed(self, verb)
  end

  def self.allowed?(object, rw)
    case object
    when Source
      if rw == :read
        true
      end
    else
      false
    end
  end

  def self.exclude(accounts)
    return all if accounts.blank?

    accounts = [accounts] unless accounts.is_a?(Array)
    where("login NOT IN (?)", accounts.map{|a| a.login})
  end

  def self.allowed(user, verb = :read)
    return all if verb == :read
    return all if user.superadmin?
    return without_roles('superadmin') if user.admin?

    if user.useradmin?
      ids = user.admin_institutions.pluck(:id)
      return where(institution_id: ids)
    end

    none
  end

  def self.without_roles(roles)
    role_ids = Role.where(title: roles).pluck(:id).map{|i| i.to_s}.join(',')
    self.
      joins("LEFT JOIN accounts_roles ar ON ar.account_id = accounts.id AND ar.role_id IN (#{role_ids})").
      where('ar.role_id IS NULL')
  end

  def self.sorted(column, direction)
    return all if column.blank?

    case column
    when 'login', 'email', 'created_at', 'updated_at'
      order(column => direction)
    when 'institution.name'
      includes(:institution).references(:institutions).order("institutions.name #{direction}")
    else
      raise Pandora::Exception, "unknown sort criteria for Account: #{column}"
    end
  end

  def self.search(column, value)
    return all if column.blank? or value.blank?

    case column
    when 'login', 'email', 'lastname', 'notes'
      where("#{column} LIKE ?", "%#{value}%")
    when 'fullname'
      where("CONCAT(firstname, ' ', lastname) LIKE ?", "%#{value}%")
    when 'label'
      clause = []
      binds = {}
      value.split.first(3).each.with_index do |v, i|
        clause << "login LIKE :t#{i} OR firstname LIKE :t#{i} OR lastname LIKE :t#{i}"
        binds[:"t#{i}"] = "%#{v}%"
      end
      where(clause.join(' OR '), binds)
    when 'institution'
      includes(:institution).references(:institutions).where('institutions.name LIKE ?', value)
    when 'roles'
      includes(:roles).references(:roles).where('roles.title LIKE ?', "%#{value}%")
    else
      raise Pandora::Exception, "unknown search criteria for Account: #{column}"
    end
  end

  def allowed_roles
    Role.allowed_roles_for(roles).sort_by(&:id)
  end

  def roles_allowed?(target_roles)
    Role.allowed?(roles, target_roles)
  end

  def allowed?(object, verb = :write)
    return true if superadmin?
    return true if verb == :read && allowed?(object)

    case object
    when Account
      return false if object.superadmin?

      case verb
      when :read
        object.user? || object.useradmin? ||
        object.dbadmin? || object.admin? # ???
      when :delete
        object != self && admin_or_superadmin? && allowed?(object)
      else
        object == self || (
          roles_allowed?(object.roles) && (
            !useradmin_only? ||
            institution == object.institution ||
            admin_institutions.include?(object.institution)
          )
        )
      end
    when Institution
      case verb
      when :read   then !dbuser? || open_sources.map(&:institution).include?(object)
      when :delete then false
      else admin?
      end
    when License, ClientApplication, Email
      verb == :read || admin?
    when Box
      object.owned_by?(self)
      # REWRITE: functionality dropped
      # when Collection, Presentation
    when Collection
      return true if object.owned_by?(self)

      case verb
      when :read   then object.readable?(self)
      when :delete then false
      when :comment then user? || superadmin? || admin?
      else
        return false if ipuser?

        object.writable?(self)
      end
    when Source
      case verb
      when :read   then true
      when :delete then false
      else admin? || object.source_admins.include?(self) || object.contact == self
      end
    when Image, ElasticRecordImage
      if verb == :read
        return false if dbuser? && !open_sources.include?(object.source)
        return true unless object.upload_record?
        return true if object.upload.approved_record
        return true if admin_or_superadmin?

        if object.upload.database
          return true if object.upload.database.owned_by?(self)
          return true if self.admin_institutions.include?(object.upload.database.owner)
          return true if self.admin_sources.include?(object.upload.database)
        end

        false
      elsif verb == :comment
        user? || superadmin? || admin?
      end
    when Comment
      case verb
      when :read then true
      when :comment then user? || superadmin? || admin?
      else
        return true if object.by?(self) or admin_or_superadmin?
      end
    when PaymentTransaction
      verb == :read && object.client == self
    when Upload
      object.database.owned_by?(self) or admin_or_superadmin?
    when Keyword
      admin_or_superadmin?
    else
      false
    end
  end

  def action_allowed?(controller, action = :index)
    controller_class = case controller
    when ApplicationController then controller.class
    else "#{controller.to_s.camelcase}Controller".constantize
    end

    action = action.to_sym

    roles.any? do |role|
      controller_class.allowed_actions_for(role.title).include?(action)
    end
  end

  # def controller_allowed?(controller)
  #   action_allowed?(controller)
  # end

  def allowed_actions(controller, actions)
    actions.select{|action_name| action_allowed?(controller, action_name)}
  end

  def sha1(token)
    self.class.sha1(token, sha1_salt || salt)
  end

  # call-seq:
  #   digest(password) => hash_value
  #
  # Encrypts the password with the user salt.
  def digest(password)
    self.class.digest(password, salt)
  end

  def login_failed?(time = nil)
    login_failed_at && (!time || login_failed_at < time.utc)
  end

  # Lift the ban on a user to log in; this will reset the 'login_failed_at'
  # and 'failed_logins' columns in the database entry for the account.
  def lift_ban!(do_save = true)
    self.login_failed_at = nil
    self.failed_logins = 0

    save if do_save

    @banned = false
  end

  # Time duration (from now) until the account expires
  def expires_in
    expires_at && expires_at - Time.now.utc
  end

  def expires_in=(value)
    # provided value must be non-empty
    unless value.blank?
      value, from = value.to_i, [Time.now.utc]

      enable = value > 0

      return set_expiration(expires_at) if enable && value < 1.minute

      from << expires_at if expires_at && mode == 'invoice'

      # REWRITE: use .seconds to make it a duration
      # set_expiration(value.since(from.max).utc, enable)
      set_expiration(value.seconds.since(from.max).utc, enable)
    else
      # leave unchanged
    end
  end

  def expiration=(data)
    set_expiration(data[:at], data[:enable])
  end

  def deactivate=(value)
    if value
      self.status = 'deactivated'
    end
  end

  def set_expiration(at, enable = true)
    self.expires_at  = at
    self.notified_at = nil

    if enable
      self.disabled_at = nil
      self.status = 'activated' unless new_record?
    end
  end

  def expires_at_s
    expires_at && !exempt_from_expiration? ? expires_at.to_s : "Saint Glinglin's Day".t
  end

  def not_anonymous?
    login != IPUSER_LOGIN && login != DBUSER_LOGIN
  end

  def self.not_anonymous
    where('login <> ? AND login <> ?', IPUSER_LOGIN, DBUSER_LOGIN)
  end

  def expired?
    _expired? || !licensed?
  end

  def _expired?
    !expires_at.nil? && expires_at <= Time.now.utc && !exempt_from_expiration?
  end

  def expires?(at = Time.now.utc)
    expires_in?(EXPIRES[mode == 'guest'], at)
  end

  def expires_in?(diff, at = Time.now.utc)
    !expires_at.nil? && expires_at > at &&
      expires_at <= at + diff && !exempt_from_expiration?
  end

  def exempt_from_expiration?
    dbadmin?
  end

  def not_expired?
    !_expired?
  end

  def licensed?
    active_dbadmin? || active_dbuser? || mode != 'institution' || !institution || institution.licensed?
  end

  def active?
    self.status == 'activated' && !expired?
  end

  def inactive?
    !active?
  end

  def self.expire_before(ts = nil)
    ts ||= 1.week.from_now
  end

  def self.expire
    where('expires_at IS NOT NULL')
  end

  def self.with_status
    where("status IS NOT NULL AND status <> ''")
  end

  def self.enabled
    where('disabled_at IS NULL')
  end

  def self.activated
    where(status: 'activated')
  end

  def self.with_role(name)
    joins(:roles).where('roles.title LIKE ?', name)
  end

  def self.without_role(name)
    where('
      NOT EXISTS (
        SELECT null
        FROM accounts_roles ar
          LEFT JOIN roles r ON ar.role_id = r.id
        WHERE
          ar.account_id = accounts.id AND
          r.title LIKE ?
      )
    ', name)
  end

  def self.expired(at = nil)
    where('expires_at IS NOT NULL AND expires_at <= ?', at || Time.now.utc).
      without_role('dbadmin')
  end

  # return a scope representing accounts with upcoming expiry
  # @param advance [Integer] seconds in advance to consider account 'expiring'
  # @return [ActiveRecord::Relation] the scope representing the accounts
  def self.upcoming_expiry(advance)
    now = Time.now.utc

    # now > expires_at - advance && expires_at > now

    expire.where('expires_at < ? AND expires_at > ?', now + advance, now)
  end

  def self.not_expired
    where.not(id: expired)
  end

  def self.active
    enabled.activated.not_expired
  end

  def self.guests
    where(mode: 'guest')
  end

  def self.non_guests
    where("mode <> 'guest'")
  end

  def self.anonymous
    with_role('ipuser')
  end

  def self.personal
    where.not(id: anonymous)
  end

  # an active record scope filtering pending accounts
  def self.pending
    where(status: 'pending')
  end

  ###
  #
  def active_user?
    user? && active?
  end

  def disabled?
    disabled_at
  end

  def enabled?
    !disabled?
  end

  def disable!
    self.disabled_at = Time.now.utc
    self.expires_in  = 0 unless _expired?

    save validate: false
  end

  def self.stale_signups(date = 1.week.ago)
    not_anonymous.where("
      (lastname != 'Subscriber' AND status IS NULL AND created_at < :ts) OR
      (lastname = 'Subscriber' AND NOT newsletter AND created_at < :ts)
    ", ts: date.utc)
  end

  def self.not_notified
    where('notified_at IS NULL')
  end

  def paid!
    unless superadmin?
      now = Time.now.utc

      self.expires_at ||= now
      self.expires_at = [expires_at, now].max + 1.year

      unless research_interest.blank? || paid_before?
        deliver(:research_interest_check)
      end

      self.status = 'activated'

      save
    end
  end

  def paid_before?
    payment_transactions.map {|t|
      t.status == 'succeeded'
    }.include?(true)
  end

  def email_verified?
    # email_verified_at && email_verified_at > 1.year.ago.utc
    !!email_verified_at
  end

  def email_verified!
    update_column(:email_verified_at, Time.now.utc)

    if !status?
      update_column(:status, 'pending')
    end
  end

  def self.email_verified
    where('email_verified_at IS NOT NULL')
  end

  # Have the terms of used changed since being accepted by the user?
  def terms_of_use_changed?
    accepted_terms_of_use_revision &&
    accepted_terms_of_use_revision < TERMS_OF_USE_REVISION
  end

  def accepted_terms_of_use?
    accepted_terms_of_use_revision == TERMS_OF_USE_REVISION
  end

  def accepted_terms_of_use_recently?(at = 1.day.ago.utc)
    accepted_terms_of_use? && accepted_terms_of_use_at > at
  end

  def accepted_terms_of_use
    self.accepted_terms_of_use_revision = TERMS_OF_USE_REVISION
    self.accepted_terms_of_use_at = Time.now.utc
  end

  def accepted_terms_of_use!
    accepted_terms_of_use
    save
  end

  def notified?
    notified_at
  end

  def notified!
    update_column(:notified_at, Time.now.utc)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between
  # browser closes.
  def remember_me!
    update_columns(
      remember_token_expires_at: 2.weeks.from_now,
      remember_token: sha1("#{email}--#{remember_token_expires_at}")
    )
  end

  def extend_remember_me!
    update_columns(
      remember_token_expires_at: 2.weeks.from_now
    )
  end

  def forget_me!
    self.remember_token_expires_at = nil
    self.remember_token = nil

    save validate: false
  end

  def reset_password?
    crypted_password.blank?
  end

  def fullname?
    unless defined?(@has_fullname)
      @has_fullname =
        (firstname || lastname) &&
        (firstname != '-' || lastname != '-')
    end

    @has_fullname
  end

  # Get the full name of the user of this account
  def fullname
    @fullname ||= fullname? ? "#{firstname} #{lastname}".strip :
      mode == 'guest' ? 'guest user'.t : 'prometheus user'.t
  end

  alias_method :to_s, :fullname

  # Get the full name of the user. along with the email address
  def fullname_with_email
    with_email = institution == (prometheus = Institution.find_by!(name: 'prometheus')) && useradmin? ? prometheus.email : email
    fullname? ? "#{fullname.quote} <#{with_email}>" : with_email
  end

  # Get the name of the city in combination wth its postal code
  def city_with_postalcode
    "#{postalcode} #{city}"
  end

  def admins
    institution.admins.compact
  end

  def active_admins
    arr = institution.active_admins.select{|a| a.allowed?(self)}
    arr.tap do |a|
      a.delete(self); a << Account.find_by!(login: 'prometheus') if a.empty?
    end
  end

  def via_issuer?
    Institution::ISSUERS.include?(institution.name)
  end

  def member?
    member_since
  end

  def created?
    creator_id
  end

  # def settings(type = 'account')
  #   @settings ||= Settings.for(self)
  #   @settings[type.to_s]
  # end

  def locale
    account_settings.locale
  end

  def locale=(locale)
    account_settings.assign_attributes(locale: locale)
  end

  def deliver(what, *, **)
    AccountMailer.with(user: self, **).send(what).deliver_now
  end

  def deliver_token(what, reset = false)
    timestamp, token = token_auth(reset)
    deliver(what, timestamp: timestamp, token: token)
  end

  def token_auth(reset = false)
    reset_password! if reset
    [t = (reset ? 1.hour : 1.day).from_now.utc.to_i, magic_encrypt(t)]
  end

  def magic_encrypt(timestamp)
    sha1("#{login}--#{email}--#{timestamp}")
  end

  def database_quota_bytes
    if database
      begin
        database.quota.megabytes
      rescue StandardError
        DEFAULT_DATABASE_QUOTA.megabytes
      end
    else
      DEFAULT_DATABASE_QUOTA.megabytes
    end
  end


  protected

    def reset_tokens
      self.remember_token = nil
      tokens.each(&:invalidate!)
    end

    def reset_tokens!
      reset_tokens
      save
    end

    # NOTE: This prevents login, since crypted_password != digest(password)
    def reset_password!
      reset_tokens
      update_column :crypted_password, ''
    end

    def update_crypted_password(password, save_salt = false)
      self.sha1_salt        = save_salt ? salt : nil
      self.salt             = self.class.salt(login)
      self.crypted_password = digest(password)
    end

    def update_crypted_password!(password, save_salt = false)
      update_crypted_password(password, save_salt)
      save validate: false
    end

    def encrypt_password
      return if password.blank?

      update_crypted_password(password)
      return if new_record?

      lift_ban!(false) if login_failed?
      reset_tokens
    end

    def password_required?
      # <tt>password.nil? || password.empty?</tt> != <tt>password.blank?</tt> as
      # the latter would prohibit all-space passwords, but without reporting that
      # fact to the user (as an error).
      !anonymous? && !subscriber? && (crypted_password.blank? || !(password.nil? || password.empty?))
    end
end
