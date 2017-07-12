require 'sinatra'
require 'sinatra/base'
require 'puma'
require 'json'

require_relative 'lib/webhook.rb'
require_relative 'lib/webhook-notify.rb'
require_relative 'lib/webhook-forwarder.rb'
require_relative 'lib/webhook-command.rb'

set :server, :puma 

set :environment, :production
set :server_settings, {:AccessLog => []}
set :logging, false
set :bind, '0.0.0.0'
set :port, '4567'

queue = { 
  'forward' => WebHook::Forwarder.new,
  'notify' => WebHook::Notify.new(['twitter','slack','groupme','debug']), 
  'command' => WebHook::Command.new, 
  'internal' => WebHook::Debug.new 
}

if queue.empty?
  puts 'No webhook queues defined'
  exit
end


post '/webhook/?:queue?/?:source?' do
  begin
    source = params['source'] || 'unknown' 
    payload = JSON.parse(request.env['rack.input'].read)
    data = { 'source' => source, 'type' => params['queue'], 'payload' => payload } 
    queue[params['queue']] << data
  rescue => e
    puts 'Could not parse incoming data'
    puts e.inspect
    puts e.backtrace
  end

end
