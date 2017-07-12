class Notifier
  class Debug
    
    def initialize
      puts '[Notifier::Debug] Loaded Debug Notifier'
    end

    def send(message='No Message Specified',options={})
      puts "[Notifier::Debug] Message: #{message} | Options: #{options}"
    end

    def is_notifier?
      return true
    end
  end
end
