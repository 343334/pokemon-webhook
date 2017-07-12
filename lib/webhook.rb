POOL_SIZE=5

class WebHook
  def initialize(*args)
    @queue = Queue.new
    
    workers = (POOL_SIZE).times.map do
      Thread.new do
        loop do
          begin
            runThread
            sleep 1
          rescue => e
            puts "Error running main thread for #{name}"
            puts e.inspect
            puts e.backtrace
          end
        end
      end
    end
  end

  def runThread
    while @queue.length > 0 do
      item = @queue.pop
      puts "Debug WebHook: #{item}"
    end
  end

  def << data
    @queue << data 
  end

  def loadConfig(reload=false)
    @@config ||= {}
    if reload or @@config.empty?
      begin
        puts '[Webhook] Loading config'
        config_file = 'config/config.json'

        file = File.open(config_file, "r")
        @@config = JSON.parse(file.read)
        file.close
        puts '[Webhook] Successfully loaded config'
      rescue => e
        puts "[Webhook] Error loading #{config_file}"
        puts e.inspect
        puts e.backtrace
      end
    end
  end
end

class WebHook
  class Debug < WebHook
  end
end
