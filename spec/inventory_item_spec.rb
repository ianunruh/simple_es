require 'spec_helper'

module SimpleES
  describe InventoryItem do
    let(:id) { SecureRandom.uuid }
    let(:name) { 'Awesomesauce' }

    it 'records creation' do
      item = InventoryItem.new id, name

      item.changes.should == [
        ItemCreated.new(id, name)
      ]
    end

    it 'records check in and removal quantities' do
      history = [
        ItemCreated.new(id, name)
      ]

      item = InventoryItem.from_history history
      item.check_in 100
      item.remove 50

      item.changes.should == [
        ItemsCheckedIn.new(id, 100),
        ItemsRemoved.new(id, 50)
      ]
    end

    it 'does not allow quantity changes when deactivated' do
      history = [
        ItemCreated.new(id, name),
        ItemDeactivated.new(id)
      ]

      item = InventoryItem.from_history history

      expect {
        item.check_in 100
      }.to raise_error DomainError

      item.changes.should == []
    end

    it 'allows quantity changes after being reactivated' do
      history = [
        ItemCreated.new(id, name),
        ItemDeactivated.new(id),
        ItemReactivated.new(id)
      ]

      item = InventoryItem.from_history history
      item.check_in 100

      item.changes.should == [
        ItemsCheckedIn.new(id, 100)
      ]

      item.initial_version.should == 3
      item.version.should == 4
    end

    it 'supports idempotent deactivation' do
      history = [
        ItemCreated.new(id, name),
        ItemDeactivated.new(id)
      ]

      item = InventoryItem.from_history history
      item.deactivate

      item.changes.should == []
    end

    it 'supports idempotent reactivation' do
      history = [
        ItemCreated.new(id, name)
      ]

      item = InventoryItem.from_history history
      item.reactivate

      item.changes.should == []
    end

  end
end
