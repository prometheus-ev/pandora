module Util
  module Bot
    extend self

    BOT_RE = %r{
      \b (?:
        AdsBot-Google
      | AhrefsBot
      | Baidu
      | Ezooms
      | Gigabot
      | Googlebot
      | Mediapartners-Google
      | SiteUptime
      | Slurp
      | WordPress
      | ZIBB
      | ZyBorg
      | bingbot
      | gsa-crawler
      | ia_archiver
      | msnbot
      ) \b
    }xio

    def bot?(user_agent)
      !!(user_agent =~ BOT_RE)
    end
  end
end
