module SimpleES
  ItemCreated = Struct.new :id, :name
  ItemsCheckedIn = Struct.new :id, :quantity
  ItemsRemoved = Struct.new :id, :quantity
  ItemDeactivated = Struct.new :id
  ItemReactivated = Struct.new :id
end
