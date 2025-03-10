require './lib/item_repository'
require './lib/item'

RSpec.describe ItemRepository do
  let(:item_repo) {ItemRepository.new}
  let(:item1) {Item.new({
    :id          => 1,
    :name        => "Pencil",
    :description => "You can use it to write things",
    :unit_price  => BigDecimal(10.99,4),
    :created_at  => Time.now,
    :updated_at  => Time.now,
    :merchant_id => 2
  })}
  let(:item2) {Item.new({
    :id          => 2,
    :name        => "Eraser",
    :description => "You can use it to erase things",
    :unit_price  => BigDecimal(10.99,4),
    :created_at  => Time.now,
    :updated_at  => Time.now,
    :merchant_id => 2
  })}
  let(:item3) {Item.new({
    :id          => 3,
    :name        => "Pen",
    :description => "You can write but not erase",
    :unit_price  => BigDecimal(20.99,4),
    :created_at  => Time.now,
    :updated_at  => Time.now,
    :merchant_id => 3
  })}
  let(:item4) {Item.new({
    :id          => 4,
    :name        => "Fountain Pen",
    :description => "A nicer pen",
    :unit_price  => BigDecimal(22.99,4),
    :created_at  => Time.now,
    :updated_at  => Time.now,
    :merchant_id => 3
  })}

  it 'exists' do
    expect(item_repo).to be_a ItemRepository
  end

  it 'can find by id' do
    expect(item_repo.find_by_id(5)).to eq nil

    item_repo.all << item1
    expect(item_repo.find_by_id(1)).to be {item}
  end

  describe '#find_by_name' do
    it 'returns either nil or an instance of Item' do
      expect(item_repo.find_by_name("Pencil")).to be nil

      item_repo = ItemRepository.new([item1])

      expect(item_repo.find_by_name("Pencil")).to eq item1
      expect(item_repo.find_by_name("Ruler")).to eq nil
    end
  end

  describe '#find_all_with_description' do
    it 'returns an array of all items involving description' do
      expect(item_repo.find_all_with_description("write")).to eq []

      item_repo = ItemRepository.new([item1,item2,item3])

      expect(item_repo.find_all_with_description("write")).to eq [item1,item3]
      expect(item_repo.find_all_with_description("you CAN")).to eq [item1,item2,item3]
      expect(item_repo.find_all_with_description("snow")).to eq []
    end
  end

  describe '#find_all_by_price' do
    it 'returns an array of items with that price' do
      expect(item_repo.find_all_by_price(BigDecimal(10.99,4))).to eq []

      item_repo = ItemRepository.new([item1,item2,item3])

      expect(item_repo.find_all_by_price(BigDecimal(0.1099,4))).to eq [item1,item2]
      expect(item_repo.find_all_by_price(BigDecimal(0.20000,4))).to eq []
    end
  end

  describe '#find_all_by_price_in_range' do
    it 'returns an array of all items in price range' do
      item_repo = ItemRepository.new([item1, item2, item3, item4])

      expect(item_repo.find_all_by_price_in_range(0..0.15)).to eq [item1, item2]
      expect(item_repo.find_all_by_price_in_range(0.15..0.25)).to eq [item3, item4]
      expect(item_repo.find_all_by_price_in_range(2..3)).to eq []
    end
  end

  describe '#find_all_by_merchant_id' do
    it 'returns items with specified merchant id' do
      item_repo = ItemRepository.new([item1,item2,item3,item4])

      expect(item_repo.find_all_by_merchant_id(2)).to eq [item1, item2]
      expect(item_repo.find_all_by_merchant_id(3)).to eq [item3, item4]
      expect(item_repo.find_all_by_merchant_id(5)).to eq []
    end
  end
end