require 'tmpdir'

class Pandora::Zip
  def initialize(data = {})
    @data = data
  end

  attr_accessor :pid

  # TODO: this should be enhanced to write to the tmp dir immediately so that
  # stuff isn't held in memory until 'generate' is called
  def []=(filename, data)
    @data[filename] = data
  end

  def generate
    data = nil

    Dir.mktmpdir 'pandora-zip-' do |dir|
      @data.each do |filename, data|
        File.open "#{dir}/#{filename}", 'wb' do |f|
          case data
          when IO then f.write(data.read)
          when Proc then f.write(data.call)
          else
            f.write(data)
          end
        end
      end

      r, w = IO.pipe
      self.pid = spawn("zip -r -j - #{dir}", out: w, err: '/dev/null')
      w.close
      data = r.read
      Process.wait(self.pid)
    end

    return data
  end
end
