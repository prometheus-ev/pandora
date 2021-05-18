class Pandora::LogParser
  def self.parse(file, options = {})
    new(file, options).parse
  end

  def initialize(file, options = {})
    @file = file
    @options = options.reverse_merge(progress: true)
    @requests = {}
    if @options[:progress]
      @progress = Pandora.progress(
        title: "pandora #{File.basename(@file)}",
        total: total
      )
    end
  end

  def parse
    while !io.eof?
      line = io.readline
      @progress.increment if @options[:progress]
      parse_line(line)
    end

    @requests.values
  end

  protected

    def parse_line(line)
      regex = /^[A-Z], \[([^ ]+) #\d+\] ([A-Z ]{5}) -- : \[([a-f0-9\-]{36})\] (.*)$/
      parts = line.strip.match(regex)
      return nil unless parts

      ts, severity, id, payload = parts[1..-1]
      return nil if severity.strip != 'INFO'

      @requests[id] ||= {
        'app' => 'pandora',
        'id' => id,
        'ts' => Time.parse(ts)
      }

      regex = /^Started ([A-Z]+) "([^"]+)" for ([0-9:\.]+) at [0-9\-]{10} [0-9:]{8} [\+\-0-9]{5}/
      if parts = payload.match(regex)
        verb, path, ip = parts[1..-1]
        @requests[id].merge!(
          'method' => verb,
          'path' => path,
          'ip' => ip
        )
      end

      regex = /^Processing by ([^#]+)#([^ ]+) as ([A-Z]+|\*\/\*)$/
      if parts = payload.match(regex)
        c, a, fmt = parts[1..-1]
        @requests[id].merge!(
          'controller' => c,
          'action' => a,
          'format' => fmt
        )
      end

      regex = /^\s+ Parameters: (.+)$/
      if parts = payload.match(regex)
        params = begin
          JSON.parse(parts[1].gsub('=>', ':'))
        rescue JSON::ParserError => e
          # uploaded files etc
          {}
        end
        @requests[id].merge!(
          'params' => params
        )
      end

      regex = /^  User: (\d+), institution: (\d+)(?:, session: ([a-z\d]+))?(?:, ipuser: (yes|no))?$/
      if parts = payload.match(regex)
        u, i, s, ipuser = parts[1..-1]
        @requests[id].merge!(
          'user_id' => (u == '0' ? nil : u.to_i),
          'institution_id' => (i == '0' ? nil : i.to_i),
          'session_id' => s,
          'personalized' => (ipuser == 'no')
        )
      end

      regex = /Completed (\d+) ([a-zA-Z ]+) in (\d+)ms .*$/
      if parts = payload.match(regex)
        code, reason, ms = parts[1..-1]
        @requests[id].merge!(
          'status' => code.to_i,
          'duration' => ms.to_i
        )
      end

      if id == 'e40ab940-6804-46ae-958e-823377815052'
        puts line
      end

      @requests[id]
    end

    def io
      @io ||= begin
        r, w = IO.pipe
        cmd = "zcat -f '#{@file}'"
        pid = Process.spawn cmd, out: w
        Thread.new do
          Process.wait pid
          w.close
        end
        r
      end
    end

    def total
      `zcat -f '#{@file}' | wc -l`.to_i
    end
end