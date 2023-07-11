# see https://redmine.prometheus-srv.uni-koeln.de/issues/1530
nofile = Process.getrlimit('NOFILE')
if nofile == [1024, 4096]
  Process.setrlimit('NOFILE', 2048, 4096)
end
