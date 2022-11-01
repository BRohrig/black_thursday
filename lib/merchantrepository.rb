require './lib/merchant.rb'

class Merchant_Repository
  attr_accessor :merchants

  def initialize(merchants = [])
   
    @merchants = merchants
  end

  def all
    merchants
  end

  def find_by_id(merchant_id)
    merchants.find do |merchant|
      merchant.id == merchant_id
    end
  end

  def find_by_name(merchant_name)
    merchants.find do |merchant|
      merchant.name.upcase == merchant_name.upcase
    end
  end

  def find_all_by_name(merchant_name)
    merchants.find_all do |merchant|
      merchant.name.upcase.include?(merchant_name.upcase)
    end
  end

  def create(merchant_name)
    merchants << Merchant.new({:name => merchant_name, :id => next_id})
  end

  def next_id
    if merchants.empty?
      1
    else
      merchants.last.id += 1
    end
  end

  def update(id, new_name)
    merchants.find do |merchant|
       if merchant.id == id then merchant.name = new_name
       end
    end
  end

  def delete(id)
    merchants.find do |merchant|
      merchants.delete(merchant) if merchant.id == id
    end
  end
end