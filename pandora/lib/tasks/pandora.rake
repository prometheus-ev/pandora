namespace :pandora do
  # TODO: can this be removed?
  def options_from_env(env = ARGV[1..-1])
    options = {}

    env.each {|string|
      key, value = string.split('=', 2)

      next unless value

      options[key.downcase.to_sym] = case value
      when 'true'
        true
      when 'false', ''
        false
      when /\A[+-]?\d+\z/
        value.to_i
      when /\A[+-]?\d+\.\d+\z/
        value.to_f
      else
        value
      end
    } if env

    options
  end

  # TODO: can this be removed?
  def print_err(err, msg = 'Error')
    warn "#{msg}: #{err}\n  #{err.backtrace.join("\n  ")}"
  end

  desc 'generate etc config files'
  task etc: :environment do
    Dir["#{ENV['PM_ROOT']}/etc/templates/*"].each do |tpl|
      engine = ERB.new(File.read tpl)
      outfile = "#{ENV['PM_ROOT']}/etc/#{File.basename(tpl).gsub(/\.erb$/, '')}"
      File.open(outfile, 'w') do |f|
        f.write engine.result(binding)
      end
    end
  end

  desc 'render sass -> tmp/app.css'
  task css: :environment do
    File.open "#{Rails.root}/tmp/app.css", 'w' do |f|
      f.write Pandora.css
    end
  end
end
