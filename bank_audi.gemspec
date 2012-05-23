# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bank_audi/version"

Gem::Specification.new do |s|
  s.name        = "bank_audi"
  s.version     = BankAudi::VERSION
  s.authors     = ["m.yermolovich"]
  s.email       = ["m.yermolovich@dev1team.net"]
  s.homepage    = ""
  s.summary     = %q{BANK AUDI (operations with money)}
  s.description = %q{
                      Bank Audi is Lebanon's largest bank.
                      And this gem created to help some
                      make money transactions & integration
                      with its system.
                    }

  s.rubyforge_project = "bank_audi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
