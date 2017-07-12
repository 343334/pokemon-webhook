class WebHook
  class Command < WebHook

    def initialize(plugins=[])
      puts "[Webhook::Command] Loaded Command Webhook"
      loadConfig
      super
    end

    def runThread
      while @queue.length > 0 do
        begin 
          item = @queue.pop
          text = item['payload']['text']
          @@config['commands'].each do |command|
            if text =~ %r[#{command['match']}] 
              puts "[Webhook::Command] Running Command - Text: #{text} Regex: #{command['match']} Command: #{command['command']}"

              file = File.open("commands/#{command['command']}.rb", "r") 
              script = file.read
              eval script
              file.close              

              break
            else
              puts "[Webhook::Command] NO MATCH FOUND - Text: #{text} Regex: #{command['match']} Command: #{command['command']}" 
            end
          end
        rescue => e
          puts e.inspect
          puts e.backtrace
        end
      end
    end

  end
end
