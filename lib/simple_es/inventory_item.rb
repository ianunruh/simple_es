module SimpleES
  class InventoryItem < RoutedAggregateRoot
    ## Domain operations

    def initialize(id, name)
      apply(ItemCreated.new(id, name))
    end

    # This is an idempotent operation
    def deactivate
      if @active
        apply(ItemDeactivated.new(id))
      end
    end

    def check_in(quantity)
      unless @active
        raise DomainError, "Item has been deactivated"
      end

      apply(ItemsCheckedIn.new(id, quantity))
    end

    def remove(quantity)
      unless @active
        raise DomainError, "Item has been deactivated"
      end

      apply(ItemsRemoved.new(id, quantity))
    end

    # This is an idempotent operation
    def reactivate
      unless @active
        apply(ItemReactivated.new(id))
      end
    end

    ## Routed event handlers

    route ItemCreated do |event|
      @id = event.id
      @name = event.name
      @quantity = 0
      @active = true
    end

    route ItemsCheckedIn do |event|
      @quantity = @quantity + event.quantity
    end

    route ItemsRemoved do |event|
      @quantity = @quantity - event.quantity
    end

    route ItemDeactivated do |event|
      @active = false
    end

    route ItemReactivated do |event|
      @active = true
    end
  end
end
