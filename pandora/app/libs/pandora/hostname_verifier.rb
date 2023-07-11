require 'resolv'

class Pandora::HostnameVerifier
  def initialize
    @resolver = Resolv::DNS.new
  end

  def run
    Institution.find_each do |institution|
      institution.hostnames.each do |hostname|
        unless resolve(hostname)
          puts "institution '#{institution.name}' (id #{institution.id}), hostname '#{hostname}' could not be resolved"
        end
      end
    end
  end

  def resolve(hostname)
    @resolver.getaddress(hostname)

    true
  rescue => e
    false
  end
end