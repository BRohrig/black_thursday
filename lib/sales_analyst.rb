require 'pry'
require_relative './merchant_repository'
require_relative './item_repository'
require_relative './invoice_repository'
require_relative './item'
require_relative './merchant'
require_relative './invoice'

class SalesAnalyst
  attr_reader :merchants, :items, :invoices

  def initialize(merchants,items,invoices)
    @merchants = merchants
    @items = items
    @invoices = invoices
  end

  def average_items_per_merchant
    (@items.all.count / @merchants.all.count.to_f).round(2)
  end

  def average_items_per_merchant_standard_deviation  
    # binding.pry  
    Math.sqrt(sum_square_diff/(item_counts.length-1)).round(2)
  end

  def sum_square_diff
    item_counts.map do |count|
      (count - average_items_per_merchant)**2
    end.sum
  end

  def item_counts
    @merchants.all.map do |merchant|
      @items.find_all_by_merchant_id(merchant.id).count
    end
  end

  def average_invoices_per_merchant
    (@invoices.all.count / @merchants.all.count.to_f).round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    # binding.pry
    Math.sqrt(invoice_sum_square_diff / (invoice_count.length - 1)).round(2)
  end

  def invoice_sum_square_diff
    invoice_count.map do |count|
      (count - average_invoices_per_merchant)**2
    end.sum
  end

  def invoice_count
    @merchants.all.map do |merchant|
      @invoices.find_all_by_merchant_id(merchant.id).count
      # binding.pry
    end
  end

  def top_merchants_by_invoice_count
    average = average_invoices_per_merchant
    stdev = average_invoices_per_merchant_standard_deviation

    @merchants.all.find_all do |merchant|
    @invoices.find_all_by_merchant_id(merchant.id).count > average + (stdev * 2)
    # binding.pry
    end
  end
end