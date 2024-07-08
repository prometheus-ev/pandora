class Pandora::LogParser
  def self.parse(file, options = {})
    new(file, options).parse
  end

  def initialize(file, options = {})
    @file = file
    @options = options.reverse_merge(progress: true, test_mode: false)
    @requests = {}
    @lines = {}
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
      parse_line(line.strip)
    end

    @requests.values
  end

  def validate!
    @requests.values.each do |request|
      invalid = request['method'].blank?

      if invalid
        @requests.delete(request['id'])
      end
    end
  end

  def requests
    @requests
  end

  def lines
    @lines
  end

  def total
    @total ||= `zcat -f '#{@file}' | wc -l`.to_i
  end

  protected

    def parse_line(line)
      regex = /^[A-Z], \[([^ ]+) #\d+\] ([A-Z ]{5}) -- : \[([a-f0-9\-]{36})\] (.*)$/
      parts = line.match(regex)

      # check for new (from 2024-03 on) log format
      unless parts

        regex = /^\[([a-f0-9\-]{36})\] (.*)$/
        parts = line.match(regex)

        if parts
          parts = parts.to_a
          parts.insert 1, nil, 'INFO'
        end
      end

      unless parts
        binding.pry if line.match?(/Started/) && @options[:test_mode]

        return nil
      end

      ts, severity, id, payload = parts[1..-1]
      return nil if severity.strip != 'INFO'

      @requests[id] ||= {}
      @requests[id].reverse_merge!(
        'app' => 'pandora',
        'id' => id
      )

      if ts
        @requests[id] ||= Time.parse(ts)
      end

      regex = /^Started ([A-Z]+) ("[^ ]+) for ([0-9a-f:\.]+) at ([0-9\-]{10} [0-9:]{8} [\+\-0-9]{5})/
      if parts = payload.match(regex)
        verb, path, ip, ts = parts[1..-1]
        path = path[1..-2]
        @requests[id].reverse_merge!(
          'method' => verb,
          'path' => path,
          'ip' => ip,
          'ts' => Time.parse(ts)
        )
      end

      regex = /^Processing by ([^#]+)#([^ ]+) as ([A-Z]+|\*\/\*)$/
      if parts = payload.match(regex)
        c, a, fmt = parts[1..-1]
        @requests[id].reverse_merge!(
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
        @requests[id].reverse_merge!(
          'params' => params
        )
      end

      regex = /^  User: (\d+), institution: (\d+)(?:, session: ([a-z\d]+))?(?:, ipuser: (yes|no))?$/
      if parts = payload.match(regex)
        u, i, s, ipuser = parts[1..-1]
        @requests[id].reverse_merge!(
          'user_id' => (u == '0' ? nil : u.to_i),
          'institution_id' => (i == '0' ? nil : i.to_i),
          'session_id' => s,
          'personalized' => (ipuser == 'no')
        )
      end

      regex = /Completed (\d+) ([a-zA-Z ]+) in (\d+)ms .*$/
      if parts = payload.match(regex)
        code, reason, ms = parts[1..-1]
        @requests[id].reverse_merge!(
          'status' => code.to_i,
          'duration' => ms.to_i
        )
      end

      @requests[id]
    end

    def io
      @io ||= begin
        r, w = IO.pipe
        cmd = ['zcat', '-f', @file.to_s]
        pid = Process.spawn *cmd, out: w
        Thread.new do
          Process.wait pid
          w.close
        end
        r
      end
    end
end
