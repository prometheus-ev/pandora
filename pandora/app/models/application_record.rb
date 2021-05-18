class ApplicationRecord < ActiveRecord::Base

  self.abstract_class = true

  include ActiveModel::Serializers::Xml

  include Util::ActiveColumns
  # include Util::ActiveEnum
  include Util::ActiveTextarea

  # CACHE_MAP = {
  #   '.marshal' => Marshal,
  #   '.yaml'    => YAML,
  #   '.yml'     => YAML
  # }

  def self.with_lock(name, timeout = 5, &block)
    regex = /^[a-z]+$/
    unless name.match(regex)
      raise Pandora::Exception, "#{name} must match #{regex}"
    end

    filename = Rails.root.join('tmp', "lock-#{name}")

    begin
      f = File.open(filename, File::RDWR | File::CREAT)
      f.flock(File::LOCK_EX)

      yield
    ensure
      f.flock(File::LOCK_UN)
      f.close
    end
  end

  class << self
    attr_writer :controller_name

    protected

      def clean_email_link_params!(*args)
        # remove trailing closing angle bracket added by stupid e-mail clients
        # NOTE: need to be sure this can never be a valid parameter component
        args.each { |i| i.sub!(/>\z/, '') if i.respond_to?(:sub!) }
      end
  end

  # REWRITE: we introduce a general paging mechanism
  def self.pageit(page = 1, per_page = 10)
    page = [(page || 1).to_i, 1].max
    per_page = (per_page || 20).to_i
    offset((page - 1) * per_page).limit(per_page)
  end

  def self.controller_name
    return 'uploads' if self == Upload
    return 'sources' if self == Source
    return 'collections' if self == Collection
    @controller_name ||= name[/[^:]+/].underscore
  end

  def self.base_class?
    self == base_class
  end

  def self.cache_path(path)
    path.is_a?(Symbol) ? pconfig[path] : path
  end

  def self.load_cache(path, default = nil, verbose = false)
    if path = cache_path(path) and File.readable?(path)
      logger.info "Loading cache from #{path}" if verbose

      cache, loader = nil, cache_map(path)

      elapsed = Benchmark.realtime {
        cache = if loader.respond_to?(:load_file)
          loader.load_file(path)
        else
          File.open(path) { |f| loader.load(f) }
        end
      }

      logger.info "Finished loading cache from #{path} (took #{elapsed.to_hms(4)})" if verbose

      block_given? ? yield(cache) : cache
    end || default
  end

  # def save_cache(path, cache, writable = false)
  #   path = cache_path(path)

  #   if !writable || File.writable?(path)
  #     dumper = cache_map(path)
  #     File.open(path, 'w') { |f| dumper.dump(cache, f) }
  #   end

  #   cache
  # end

  # def others(*exclude)
  #   # REWRITE: use new ar glue code
  #   # find(:all, :conditions =>
  #   #   "NOT #{k = primary_key} IN (#{exclude.map(&k.to_sym).compact.join(',')})")
  #   conds = {
  #     :conditions => 
  #       "NOT #{k = primary_key} IN (#{exclude.map(&k.to_sym).compact.join(',')})"
  #   }
  #   Upgrade.conds_to_scopes(self, conds)
  # end
    
  # def cache_key
  #   [self.class, id || 'new', updated_at].compact.cache_key
  # end

  def pristine
    unless new_record?
      self.class.find(id).tap do |r|
        r.readonly!
      end
    end
  end

  def <=>(other)
    return unless other.is_a?(ApplicationRecord)

    klass, other_klass = self.class, other.class

    [klass.table_name, send(klass.primary_key)] <=>
    [other_klass.table_name, other.send(other_klass.primary_key)]
  end

  def filename(ext = nil)
    to_s.to_filename(ext)
  end

  def generate_oauth_key(length = 40)
    OAuth::Helper.generate_key(length)[0, length]
  end

  def others(*exclude)
    self.class.others(self, *exclude)
  end


  protected

    def sanitize_email
      self.email = Util::Email.sanitize(email) if email.present?
    end

    # used to be provided by globalize, we implement the simplest solution
    def self.translates(*args)
      self.class_eval do
        args.each do |field|
          define_method(field) do |locale = nil|
            locale ||= I18n.locale
            if locale == :de
              self["#{field}_de".to_sym]
            else
              self[field]
            end
          end

          define_method("#{field}=") do |value|
            self["#{field}_de".to_sym] = value['de']
            self[field] = value['en']
          end

          # for compatibility with i18n_helper.rb
          define_method('_translations=') do |value|
            value.each do |locale, values|
              ext = (locale == 'de' ? '_de' : '')
              values.each do |field, v|
                self["#{field}#{ext}".to_sym] = v
              end
            end
          end

          define_method("#{field}_in_all_languages") do |separator|
            ORDERED_LANGUAGES.map { |lang|
              Locale.switch_locale(lang) do
                send("#{field}".to_sym)
              end
            }.compact.join(separator)
          end
        end
      end
    end

end
