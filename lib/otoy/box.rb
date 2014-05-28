require "ruby-box"

class Otoy
  class Box

    def initialize(consumer_key, consumer_secret)
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @box = ::RubyBox::Session.new({:client_id => @consumer_key, :client_secret => @consumer_secret})
    end

    def __muted_send__(method, *args, &block)
      @box.send(method, *args, &block)
    rescue StandardError, Timeout::Error => e
      nil
    end

    def method_missing(method, *args, &block)
      method = method.to_s

      if method =~ /^muted_(.+)$/
        __muted_send__($1, *args, &block)
      else
        @box.send(method, *args, &block)
      end
    end
  end
end
