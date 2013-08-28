module SimpleES
  class AggregateRoot
    # The unique identifier for this aggregate
    attr_reader :id

    # Bypasses the constructor
    def self.from_history(events)
      allocate.tap { |a|
        a.initialize_from_history events
      }
    end

    # Returns a copy of the list of changes made to this aggregate
    def changes
      if @changes
        @changes.dup
      else
        []
      end
    end

    def clear_changes
      @changes.clear if @changes
    end

    # Returns true if there are uncommitted changes to this aggregate
    def dirty?
      @changes && @changes.size > 0
    end

    # Returns the version of this aggregate before changes were made
    def initial_version
      version - changes.size
    end

    # Returns the current version of this aggregate
    def version
      @version || 0
    end

    # Rebuilds the state of this aggregate using the given sequence of events
    def initialize_from_history(events)
      if @version
        raise InvalidStateError, 'Aggregate has already been initialized'
      end

      events.each do |event|
        transition_to event
      end
    end

    protected

    # Applies the given event to the aggregate, adding it to the list of changes
    def apply(event)
      transition_to event

      @changes ||= []
      @changes.push event
    end

    # Mutates the state of the aggregate using the given event
    def handle(event)
      raise NotImplementedError
    end

    private

    # Transitions the aggregate to the next version using the given event
    def transition_to(event)
      handle event
      @version = version.next
    end
  end
end
