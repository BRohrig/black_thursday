require './lib/reposable'
require './lib/item_repository'
require './lib/item'

RSpec.describe Reposable do
  let(:item) {Item.new({
    :id          => 1,
    :name        => "Pencil",
    :description => "You can use it to write things",
    :unit_price  => BigDecimal(10.99,4),
    :created_at  => Time.now,
    :updated_at  => Time.now,
    :merchant_id => 2})}
  let(:item_repo) {ItemRepository.new([item])}

  describe '#class_name' do
    it 'returns a const of the class the current repo is storing' do

      expect(item_repo.class_name).to eq Item
    end
  end

  describe '#create' do
    it 'adds a new instance corresponding to the current repo' do
      item_repo.create({
        :name        => "Eraser",
        :description => "You can use it to erase things",
        :unit_price  => BigDecimal(10.99,4),
        :merchant_id => 2
      })

      expect(item_repo.all[1].name).to eq "Eraser"
      expect(item_repo.all[1].id).to eq 2

      item_repo.create({
        :name        => "Pen",
        :description => "You can use it to erase things",
        :unit_price  => BigDecimal(20.99,4),
        :merchant_id => 3
      })

      expect(item_repo.all[2].name).to eq "Pen"
      expect(item_repo.all[2].id).to eq 3
    end
  end

  describe '#update' do
    it 'updates an instance with the corresponding id' do
      item_repo = ItemRepository.new
      item_repo.create({
        :id          => 1,
        :name        => "Pencil",
        :description => "You can use it to write things",
        :unit_price  => BigDecimal(10.99,4),
        :created_at  => Time.now,
        :updated_at  => Time.now,
        :merchant_id => 2
      })
      item_repo.update(1, {
        :name        => "Broken Pencil",
        :description => "You now have a smaller pencil",
        :unit_price  => BigDecimal(5.99,4)
      })

      expect(item_repo.all[0].name).to eq "Broken Pencil"
      expect(item_repo.all[0].description).to eq "You now have a smaller pencil"
      expect(item_repo.all[0].unit_price).to eq BigDecimal(5.99,4)
    end
  end

  describe '#find_by_id' do
    it 'returns either nil or an instance with matching id' do
      item = Item.new({
        :id          => 1,
        :name        => "Pencil",
        :description => "You can use it to write things",
        :unit_price  => BigDecimal(10.99,4),
        :created_at  => Time.now,
        :updated_at  => Time.now,
        :merchant_id => 2
      })  
      item_repo = ItemRepository.new([item])

      expect(item_repo.find_by_id(1)).to eq item
    end
  end

  describe '#delete' do
    it 'deletes instance with corresponding id' do
      item = Item.new({
        :id          => 1,
        :name        => "Pencil",
        :description => "You can use it to write things",
        :unit_price  => BigDecimal(10.99,4),
        :created_at  => Time.now,
        :updated_at  => Time.now,
        :merchant_id => 2
      })  
      item_repo = ItemRepository.new([item])

      expect(item_repo.all).to eq [item]
      
      item_repo.delete(1)

      expect(item_repo.all).to eq []
    end
  end


end