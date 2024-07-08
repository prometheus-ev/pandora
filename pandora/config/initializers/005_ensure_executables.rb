# make sure all required executables are available and can be found

executables = [
  'convert', 'curl', 'gzip', 'rsync', 'ln', 'mkdir', 'rm', 'zip', 'cat', 'zcat',
  'wc', 'gunzip', 'idn', 'grep', 'file'
]

executables.each do |e|
  unless system('which', e, [:out, :err] => '/dev/null')
    raise(
      StandardError,
      "executable '#{e}' could not be found, please install it"
    )
  end
end
