require 'rest-client'
require 'json'

begin
  response = RestClient.get("https://s3.amazonaws.com/pokemon-webhook/config.json?timestamp=#{Time.now.to_i}")
rescue
  puts "[Webhook::Command] Error: Cannot download configuration file"
  puts response.body
end

begin
  json = response.body
  parse = JSON.parse(json)
  File.open('config/config.json', 'w') { |file| file.write(json) }
  loadConfig true

  puts "[Webhook::Command] Successfully ran command: #{command['command']}"

rescue => error
  puts error.inspect
  puts error.backtrace

  puts "[Webhook::Command] Error: Cannot parse downloaded JSON"
  puts json
end



