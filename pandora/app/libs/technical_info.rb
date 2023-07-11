module TechnicalInfo

  RAILS_VERSION = "Rails #{Rails.version}"

  ELASTICSEARCH_VERSION = Pandora::Elastic.new.version

  PASSENGER_VERSION = "Phusion Passenger Apache Module"

  APACHE_VERSION = %w[apache2 httpd].find { |name|
    if File.exist?(prog = "/usr/sbin/#{name}")
      break %x{#{prog} -v | awk '/^Server version:/{print $3}'}.chomp
    end
  } || 'Apache'

  # OS_VERSION = case
  #   when File.readable?(file = '/etc/lsb-release')
  #     %x{awk -F '"' '/^DISTRIB_DESCRIPTION=/{print $2}' #{file}}
  #   when File.readable?(file = '/etc/debian_version')
  #     "Debian GNU/Linux #{File.read(file)}"
  #   when %w[redhat suse gentoo].find { |dist| File.readable?(file = "/etc/#{dist}-release") }
  #     File.read(file)
  #   else
  #     %x{uname -o}
  # end.chomp

  # cpu_models = %x{awk -F ': ' '/^model name/{print $2}' /proc/cpuinfo}.split("\n")

  # CPU_COUNT = case cpu_models.size
  #   when 1 then ''
  #   when 2 then 'dual'
  #   else        'multiple'
  # end

  # CPU_MODEL     = cpu_models.first.strip
  # CPU_FREQUENCY = %x{awk -F ': ' '/^cpu MHz/{print $2}' /proc/cpuinfo}.split("\n").first

  # MEMORY = %x{awk '/^MemTotal:/{print $2}' /proc/meminfo}.to_i.kilobytes

end
