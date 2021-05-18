require 'mail'

# REWRITE: we need it below
require 'resolv'

module Util

  module Email

    extend self

    # Enhanced Mail System Status Codes
    # <http://tools.ietf.org/html/rfc3463>
    STATUS_CODES = Hash.new({}).update(
      0 => {  # Other or Undefined Status
        0 => %q{Other undefined Status}
      },

      1 => {  # Addressing Status
        0 => %q{Other address status},
        1 => %q{Bad destination mailbox address},
        2 => %q{Bad destination system address},
        3 => %q{Bad destination mailbox address syntax},
        4 => %q{Destination mailbox address ambiguous},
        5 => %q{Destination address valid},
        6 => %q{Destination mailbox has moved, No forwarding address},
        7 => %q{Bad sender's mailbox address syntax},
        8 => %q{Bad sender's system address}
      },

      2 => {  # Mailbox Status
        0 => %q{Other or undefined mailbox status},
        1 => %q{Mailbox disabled, not accepting messages},
        2 => %q{Mailbox full},
        3 => %q{Message length exceeds administrative limit},
        4 => %q{Mailing list expansion problem}
      },

      3 => {  # Mail System Status
        0 => %q{Other or undefined mail system status},
        1 => %q{Mail system full},
        2 => %q{System not accepting network messages},
        3 => %q{System not capable of selected features},
        4 => %q{Message too big for system},
        5 => %q{System incorrectly configured}
      },

      4 => {  # Network and Routing Status
        0 => %q{Other or undefined network or routing status},
        1 => %q{No answer from host},
        2 => %q{Bad connection},
        3 => %q{Directory server failure},
        4 => %q{Unable to route},
        5 => %q{Mail system congestion},
        6 => %q{Routing loop detected},
        7 => %q{Delivery time expired}
      },

      5 => {  # Mail Delivery Protocol Status
        0 => %q{Other or undefined protocol status},
        1 => %q{Invalid command},
        2 => %q{Syntax error},
        3 => %q{Too many recipients},
        4 => %q{Invalid command arguments},
        5 => %q{Wrong protocol version}
      },

      6 => {  # Message Content or Media Status
        0 => %q{Other or undefined media error},
        1 => %q{Media not supported},
        2 => %q{Conversion required and prohibited},
        3 => %q{Conversion required but not supported},
        4 => %q{Conversion with loss performed},
        5 => %q{Conversion Failed}
      },

      7 => {  # Security or Policy Status
        0 => %q{Other or undefined security status},
        1 => %q{Delivery not authorized, message refused},
        2 => %q{Mailing list expansion prohibited},
        3 => %q{Security conversion required but not possible},
        4 => %q{Security features not supported},
        5 => %q{Cryptographic failure},
        6 => %q{Cryptographic algorithm not supported},
        7 => %q{Message integrity failure}
      }
    )

    STATUS_CLASSES = {
      2 => 'Success',
      4 => 'Persistent Transient Failure',
      5 => 'Permanent Failure'
    }

    def parse(address, relax = true)
      # REWRITE: replaced with new mail implementation.
      # TODO: remove unused code from this file once the app is functional
      # TMail::Address.parse(address)
      ::Mail::Address.new(address)
    rescue ::Mail::Field::IncompleteParseError
      raise unless relax
    end

    def sanitize(address)
      sanitize!(address) || address
    end

    def sanitize!(address, relax = true)
      parsed_address = parse(address, relax)
      parsed_address.address if parsed_address
    end

    # <http://lindsaar.net/2008/4/14/tip-4-detecting-a-valid-email-address>
    # <http://lindsaar.net/2008/4/14/tip-5-cleaning-up-an-verifying-an-email-address-with-ruby-on-rails>
    # <http://lindsaar.net/2008/4/15/tip-6-validating-the-domain-of-an-email-address-with-ruby-on-rails>
    def valid?(address, relax = true)
      raise_or_relax = lambda { |error| !relax and raise error.new(address) }

      if parsed_address = parse(address) and valid_format?(parsed_address)
        valid_domain?(parsed_address.domain) or raise_or_relax[InvalidDomainError]
      else
        raise_or_relax[InvalidFormatError]
      end
    end

    def valid!(address)
      valid?(address, false)
    end

    def valid_format?(address)
      # REWRITE: its Mail now
      # address.is_a?(TMail::Address) || parse(address).is_a?(TMail::Address)
      address.is_a?(Mail::Address) || parse(address).is_a?(Mail::Address)
    end

    def valid_domain?(domain)
      domain = parse(domain).domain if domain.is_a?(Mail::Address)
      return if domain.blank?

      # in testing, we hardcode a few domains because the below check
      # depends on a working dns system
      if ENV['PM_SKIP_EMAIL_DOMAIN_CHECK'] == 'true'
        return [
          'example.com', 'prometheus-bildarchiv.de', 'wendig.io'
        ].include?(domain)
      end

      Resolv::DNS.open { |dns|
        tries = 0

        [
          Resolv::DNS::Resource::IN::MX,
          Resolv::DNS::Resource::IN::A
        ].inject(false) { |ok, type|
          ok || begin
            dns.getresources(domain, type).any?
          rescue Errno::ECONNREFUSED
            false
          rescue ArgumentError  # network timeout!?
            # wrong number of arguments (0 for 1) in
            # resolv.rb, line 600: raise TimeoutError

            # let's try again
            tries += 1
            retry if tries < 3

            # better not blame this on the user...
            true
          end
        }
      }
    end

    def explain_status(status)
      klass, subject, detail = status.split('.').map(&:to_i)
      [STATUS_CODES[subject][detail], STATUS_CLASSES[klass], case klass
        when 5 then false  # not retryable
        when 4 then true   # retryable
        else        nil    # don't care
      end]
    end

    def status_code(status)
      explain_status(status).first || status
    end

    class EmailError < StandardError
      def initialize(address)
        @address = address
      end

      def msg
        :invalid
      end

      def to_s
        "#{@address} #{msg}"
      end
    end

    class InvalidFormatError < EmailError
      def msg
        :invalid
      end
    end

    class InvalidDomainError < EmailError
      def msg
        :invalid_domain
      end
    end

  end

end
