require 'slack-ruby-client'

class Notifier
  class Slack
    
    def initialize
      begin
        ::Slack.configure do |config|
          config.token = ENV['SLACK_API_TOKEN']
#          config.logger = Logger.new(STDOUT)
#          config.logger.level = Logger::INFO
          fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
        end
      
        @client = ::Slack::Web::Client.new
        @client.auth_test
        
        puts '[Notifier::Slack] Loaded Slack Notifier'
      rescue => e
        puts '[Notifier::Slack] Error loading Slack Notifier!'
        puts e.inspect
        puts e.backtrace
      end
    end

    def send(message='No Message Specified',options={})
      begin
        source = options['source']
        keywords = ::Set.new
        keywords << (options['attachments']['mapcity'].gsub(/[^0-9a-zA-Z]/, '')).downcase
        keywords << (options['attachments']['pokemon_name'] + '_' + options['attachments']['mapcity'].gsub(/[^0-9a-zA-Z]/, '')).downcase
        options['fences'].each do |fence|
          keywords << (fence).downcase
          keywords << (options['attachments']['pokemon_name'] + '_' + fence).downcase
        end
      rescue
        keywords = ['None']
      end 

      begin
        @client.chat_postMessage(
          channel: options['channel'], 
          as_user: true, 
          unfurl_media: true,
          attachments: [
            {
              fallback: message + ' ' + options['attachments']['mapaddress'],
              title: message,
              text: 'Maps: ' + '<' + options['attachments']['mapurl'] + '|Google>  |  <' + options['attachments']['mapurl_apple'] + '|Apple>' + "\n" + 
                    'Keywords: ' + keywords.to_a.join(','),
              thumb_url: options['attachments']['pokemonimage'],
              footer: 'Address: ' + options['attachments']['mapaddress']
            },
            {
              fallback: 'Map Image',
              image_url: options['attachments']['mapimage']
            }
          ].to_json
        )
        puts "[#{source.upcase}][Notifier::Slack] Message Sent"
      rescue => e
        puts e.inspect
        puts e.backtrace
        puts "[#{source}][Notifier::Slack] Error sending message to Slack Bot"
      end
    end

    def is_notifier?
      return true
    end


  end
end
