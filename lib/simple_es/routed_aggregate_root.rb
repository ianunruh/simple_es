module SimpleES
  class RoutedAggregateRoot < AggregateRoot
    def self.routes
      @routes ||= Hash.new
    end

    def self.route(type, &block)
      routes[type] = block
    end

    protected

    def routes
      self.class.routes
    end

    def handle(event)
      handler = routes.fetch event.class
      instance_exec event, &handler
    rescue KeyError
      raise ArgumentError, "No handler registered for #{event.class}"
    end
  end
end
