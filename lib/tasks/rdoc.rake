require 'sdoc'
require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc' # name of output directory
  rdoc.generator = 'sdoc' # explictly set the sdoc generator
  rdoc.template = 'rails' # template used on api.rubyonrails.org
  rdoc.main = 'README.md'
  rdoc.rdoc_files.include('README.md', 'app/', 'docs/', 'lib/')
end
