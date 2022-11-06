require_relative 'reposable'
require_relative './merchant.rb'

class MerchantRepository
  include Reposable

  attr_accessor :all

  def initialize(all = [])
    @all = all
  end

  def find_by_name(merchant_name)
    all.find do |merchant|
      merchant.name.upcase == merchant_name.upcase
    end
  end

  def find_all_by_name(merchant_name)
    all.find_all do |merchant|
      merchant.name.upcase.include?(merchant_name.upcase)
    end
  end

  def find_by_id(merchant_id)
    all.find do |merchant|
      merchant.id == merchant_id
    end
  end

  def inspect
    "#<#{self.class} #{@merchants.size} rows>"
  end
end