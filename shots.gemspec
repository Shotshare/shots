$:.push File.expand_path('../lib', __FILE__)
require 'shotshare/version'

Gem::Specification.new do | s |
  s.name            = 'shots'
  s.version         = Shotshare::Shots::VERSION
  s.summary         = 'CLI client for shotshare.it'
  s.description     = 'Command line application for capturing and publishing screenshots and configs to https://shotshare.it'
  s.authors         = ["Trevor Basinger"]
  s.email           = ['trevor.basinger@gmail.com']
  s.homepage        = 'https://github.com/Shotshare/shots'

  s.files           = `git ls-files`.split("\n")
  s.executables     = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_runtime_dependency 'docile'
  s.add_runtime_dependency 'rest_client'
end
