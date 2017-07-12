require 'groupme'

class Notifier
  class Groupme
    
    def initialize
      require "hashie"
      require "hashie/logger"
      Hashie.logger = Logger.new(nil)

      begin
        @client = ::GroupMe::Client.new(:token => ENV['groupme_token'])
        @bots = getBots
        puts '[Notifier::Groupme] Loaded Groupme Notifier'
      rescue ArgumentError
        puts '[Notifier::Groupme] Environment variable "groupme_token" is not set or is incorrect. Exiting...'
        exit
      rescue => e
        puts '[Notifier::Groupme] Error loading Groupme Notifier!'
        puts e.inspect
        puts e.backtrace
      end
    end

    def send(message='No Message Specified',options={})
      source = options['source']
      begin
        response = botPost(options['channel'],message + ' - ' + options['attachments']['mapurl'] + ' - ' + 'Fences: ' + options['fences'].to_a.join(','))
        puts "[#{source.upcase}][Notifier::Groupme] Message Sent" if response
      rescue
        puts "[#{source.upcase}][Notifier::Groupme] Error sending message to GroupMe Bot"
      end
    end

    def is_notifier?
      return true
    end

    def botPost(channel,message,options={},attachments={})
      begin
        response = @client.bot_post(@bots[channel]['id'],message,options,attachments)
        return true if response
        return false
      rescue => e
      puts e.inspect
      puts e.backtrace
        puts "[Notifier::Groupme] No Groupme channel ##{channel}"
        return false
      end
    end

    def getBots
      begin
        bots ||= {}
        @client.bots.each do |bot|
          bots[bot['group_id']] ||= {}
          bots[bot['group_id']]['id'] = bot[:bot_id]
          @client.group(bot['group_id'])['members'].each do |member|
            bots[bot['group_id']]['members'] ||= {}
            bots[bot['group_id']]['members'][member['user_id'].to_s] = member['nickname']
          end
        end
        return bots
      rescue => e
        puts '[Notifier::Groupme] Error loading bots'
        puts e.inspect
        puts e.backtrace
        return false
      end      
    end

  end
end
