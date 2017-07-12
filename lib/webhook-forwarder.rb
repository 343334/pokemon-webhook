require 'rest-client'
require_relative 'encounter.rb'

class WebHook
  class Forwarder < WebHook

    def initialize(plugins=[])
      loadConfig
      loadnotifiers(plugins)
      super
    end

    def runThread
      while @queue.length > 0 do
        begin 
          item = @queue.pop
          payload = item['payload']
          encounter = Encounter.new(payload)

          fencelist = Set.new 
          notifiers = {}

          @@config['forwarders'].each do |forwarder|
            if (forwarder['pokemon'].include? encounter.pokemon.to_i or forwarder['pokemon'].include? 999) and encounter.inFence? forwarder['fence']
              forwarder['notify'].each do |url|
                response = RestClient.post url, item['payload'].to_json, {content_type: :json, accept: :json}                
                puts "Invalid Response - #{response}" unless response
	      end
            end
          end
        rescue => e
          puts e.inspect
          puts e.backtrace
        end
      end
    end

    def notifiers
      return @plugins.keys.join(',')
    end

    def loadnotifiers(plugins)
      plugins.each do |plugin|
        loadnotifier(plugin)
      end
    end

    def loadnotifier(plugin)
      begin
        @plugins ||= {}
        require_relative "./plugin-#{plugin}.rb"
        @plugins[plugin] = Module.const_get("Notifier::#{plugin.capitalize}").new
        return true
      rescue => e
        puts "[Notifier] Error: Could not load notifier plugin"
        puts e.inspect
        puts e.backtrace
        return false
      end
    end



  end
end
