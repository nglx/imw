require 'imw'
dataset = IMW::Dataset.new :handle => 'test'

dataset.rip do
  IMW.open("http://path/to/somre/resource.html").cp(dataset.path_to(:ripd), 'original_data.html')
end

dataset.parse do
  #...
end


