require File.expand_path(__dir__ + '/../../dotenv')

# load pry if its available
begin; require 'pry'; rescue LoadError => e; ; end

if u = ENV['PM_UMASK']
  File.umask u.to_i(8)
end

RACK_ENV = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

class RackImages
  autoload :Exception, 'rack_images/exception'
  autoload :Resizer, 'rack_images/resizer'
  autoload :Secret, 'rack_images/secret'
  autoload :Server, 'rack_images/server'

  def self.run(command, options= {})
    o_r, o_w = IO.pipe unless options[:stdout]
    e_r, e_w = IO.pipe unless options[:stderr]
    pid = Process::spawn(*command,
      out: options[:stdout] || o_w,
      err: options[:stderr] || e_w
    )
    Process::wait(pid)
    status = $?.exitstatus
    stdout = unless options[:stdout]
      o_w.close
      o_r.read
    end
    stderr = unless options[:stderr]
      e_w.close 
      e_r.read
    end
    [status, stdout, stderr]
  end
end
