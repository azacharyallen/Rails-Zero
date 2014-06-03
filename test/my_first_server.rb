require 'webrick'
require "active_support/core_ext"
require 'ERB'

server = WEBrick::HTTPServer.new :Port => 8080

server.mount_proc "/" do |request, response|
  response['Content-Type'] = 'text/plain' 
  response.body = request.path
end

trap('INT') { server.shutdown }

server.start

# template = <<-ERB
# Your number is: <%= x %>
# The square of your number is <%= x * x %>
# ERB

# compiled_template = ERB.new(template)

# x = 4

# b = binding()

# puts compiled_template.result(b)