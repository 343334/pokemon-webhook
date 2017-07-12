require 'twitter'

class Notifier
  class Twitter
    
    def initialize
      begin
	
        @client = ::Twitter::REST::Client.new do |config|
	  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
	  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
	  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
	  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
	end      

        @delayqueue = {}
	Thread.new do
          loop do
	    begin
              if @delayqueue.length > 0
	        @delayqueue.keys.each do |key|
                  if key < Time.now.to_i
                    self.send_delayed(@delayqueue[key]['message'],@delayqueue[key]['options'])
                    @delayqueue.delete key
                  end
                end
              end
              sleep 0.01
            rescue => e
	      puts "Error running Twitter Delay Thread"
	      puts e.inspect
     	      puts e.backtrace
	    end
	  end
	end

        puts '[Notifier::Twitter] Loaded Twitter Notifier'
      rescue => e
        puts '[Notifier::Twitter] Error loading Twitter Notifier!'
        puts e.inspect
        puts e.backtrace
      end
    end

    def send(message='No Message Specified',options={})
      source = options['source']
      if @delayqueue.length < 25
        @delayqueue[options['disappear']-900] = { 'message' => message, 'options' => options }
        puts "[#{source.upcase}][Notifier::Twitter] Queued Message for #{options['disappear']-900} - Current Time: #{Time.now.to_i}"
      else
        puts "[Notifier::Twitter] Queue Full - Ignoring notifications until queue frees up"
      end
    end

    def send_delayed(message='No Message Specified',options={})
      source = options['source']      
      city = options['attachments']['mapcity']

      begin
        @client.update("#{city}: #{message} - #{options['attachments']['mapurl']}")        
        puts "[#{source.upcase}][Notifier::Twitter] Message Sent"
      rescue => e
        puts e.inspect
        puts e.backtrace
        puts "[#{source.upcase}][Notifier::Twitter] Error sending message to Twitter Bot"
      end
    end

    def is_notifier?
      return true
    end


  end
end
