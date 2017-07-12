require_relative 'encounter.rb'

class WebHook
  class Notify < WebHook

    def initialize(plugins=[])
      loadConfig
      loadnotifiers(plugins)
      super
    end

    def runThread
      while @queue.length > 0 do
        #puts "[Webhook::Notify (##{Thread.current.object_id})] - Processing Queue Item"
        begin 
          item = @queue.pop
          source = item['source'] || 'unknown'
          payload = item['payload']
          encounter = Encounter.new(payload,source)
          next unless encounter.isValid? 

          fencelist = Set.new 
          notifiers = {}

          @@config['notifiers'].each do |item|
            
            encounter_match = false
            
            if ( item['pokemon'].include? encounter.pokemon.to_i or item['pokemon'].include? 999 ) 

              if item.has_key? 'fences'
                item['fences'].each do |fence|
                  if encounter.inFence? fence  
                    fencelist << fence
                    encounter_match = true
                  end
                end
              end

              if item.has_key? 'sources' and item['sources'].include? source
                encounter_match = true
              end

              if item.has_key? 'cities' and item['cities'].include? encounter.city.gsub(/[^0-9a-zA-Z]/, '').downcase
                encounter_match = true
              end

              if !item.has_key? 'cities' and !item.has_key? 'fences' and !item.has_key? 'sources'
                encounter_match = true
              end

              if encounter_match 
                item['notify'].each do |notify|
                  if @plugins.has_key? notify['type']
                    notifiers[notify['type']] ||= {}
                    notifiers[notify['type']][notify['channel']] ||= { 'tags' => Set.new }
                    notifiers[notify['type']][notify['channel']]['tags'] += notify['tags']
                  end
                end
              end

            end
          end
          
          notifiers.each do |type,channels|
            channels.each do |channel,tags|
              puts "[#{source.upcase}][Webhook::Notify (##{Thread.current.object_id})] - Queueing #{type} message for #{encounter.pokemon_name} expiring at #{encounter.disappear}"
              @plugins[type].send(encounter.notification[:message], {'source' => source, 'disappear' => encounter.disappeartimestamp, 'fences' => fencelist, 'attachments' => encounter.notification[:attachments], 'channel' => channel, 'tags' => tags, 'payload' => payload.to_json})
              sleep 1
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
