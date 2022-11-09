require 'pry'
require 'bigdecimal'
require_relative './merchant_repository'
require_relative './item_repository'
require_relative './invoice_repository'
require_relative './invoice_item_repository'
require_relative './customer_repository'
require_relative './transaction_repository'
require_relative './item'
require_relative './merchant'
require_relative './invoice'
require_relative './invoice_item'
require_relative './customer'
require_relative './transaction'
require_relative './mathable'

class SalesAnalyst
  include Mathable
  
  attr_reader :merchants, 
              :items, 
              :invoices, 
              :customers, 
              :transactions, 
              :invoice_items

  def initialize(merchants,items,invoices,invoice_items,customers,transactions)
    @merchants = merchants
    @items = items
    @invoices = invoices
    @invoice_items = invoice_items
    @customers = customers
    @transactions = transactions
  end

  def average_items_per_merchant
    avg(items_per_merchant).to_f.round(2)
  end

  def average_items_per_merchant_standard_deviation    
    stdev(items_per_merchant).round(2)
  end

  def merchants_with_high_item_count
    avg = avg(items_per_merchant)
    stdev = stdev(items_per_merchant)

    @merchants.all.find_all do |merchant|
      @items.find_all_by_merchant_id(merchant.id).count > avg + stdev
    end
  end

  def average_item_price_for_merchant(id)
    prices = @items.find_all_by_merchant_id(id).map do |item|
      item.unit_price
    end

    avg(prices).round(2)
  end

  def average_average_price_per_merchant
    avg_prices = @merchants.all.map do |merchant|
      average_item_price_for_merchant(merchant.id)
    end

    avg(avg_prices).truncate(2)
  end

  def golden_items
    avg = avg(item_prices)
    stdev = stdev(item_prices)

    @items.all.select do |item|
      item.unit_price > avg + 2*stdev
    end
  end

  # Iteration 5

  def top_buyers(num_buyers = 20)
    @customers.all.sort_by do |cust|
      customer_spent(cust.id)
    end.reverse![0..num_buyers-1]
  end

  def top_merchant_for_customer(cust_id)
    max_pair = spent_per_merchant(cust_id).max
    return max_pair if max_pair.nil?
    merchant_id = max_pair[1] > 0 ? max_pair[0] : nil
    @merchants.find_by_id(merchant_id)
  end

  def one_time_buyers
    @customers.all.find_all do |cust|
      customer_invoices(cust.id).count == 1
    end
  end

  def one_time_buyers_top_item
    top_item_number = one_time_buyers_item_tally.max_by {|item,value| value}[0]
    @items.find_by_id(top_item_number)
  end

  # Helper methods

  def one_time_buyers_item_tally
    item_numbers = []
    one_time_buyers.each do |cust|
      invoice_id = customer_invoices(cust.id)[0].id
      item_numbers += find_item_numbers_by_invoice_id(invoice_id) if invoice_paid_in_full?(invoice_id)
    end
    item_numbers.tally
  end

  def spent_per_merchant(cust_id)
    spent_per_merchant = Hash.new(0)
    customer_paid_invoices(cust_id).each do |cust_inv|
      spent_per_merchant[cust_inv.merchant_id] += invoice_value(cust_inv.id)
    end
    spent_per_merchant
  end

  def find_item_numbers_by_invoice_id(id)
    item_numbers = []
    find_invoice_items_by_invoice_id(id).each do |inv_item|
      item_numbers += Array.new(inv_item.quantity,items.find_by_id(inv_item.item_id).id)
    end
    item_numbers
  end

  def find_invoice_items_by_invoice_id(id)
    invoice_items.all.find_all do |inv_item|
      inv_item.invoice_id == id
    end
  end

  def customer_spent(cust_id)
    customer_paid_invoices(cust_id).sum do |cust_inv|
      invoice_value(cust_inv.id)
    end
  end

  def customer_invoices(cust_id)
    @invoices.all.find_all do |invoice|
      invoice.customer_id == cust_id
    end
  end

  def customer_paid_invoices(cust_id)
    @invoices.all.find_all do |invoice|
      invoice.customer_id == cust_id && invoice_paid_in_full?(invoice.id)
    end
  end

  def invoice_total(invoice_id)
    return 0 if !invoice_paid_in_full?(invoice_id)
    invoice_items_by_invoice_id(invoice_id).sum do |invoice_item|
      invoice_item.quantity * invoice_item.unit_price
    end
  end

  def invoice_value(invoice_id)
    invoice_items_by_invoice_id(invoice_id).sum do |invoice_item|
      invoice_item.quantity * invoice_item.unit_price
    end
  end

  def invoice_items_by_invoice_id(invoice_id)
    @invoice_items.all.find_all do |invoice_item|
      invoice_item.invoice_id == invoice_id
    end
  end
  
  def items_per_merchant
    @merchants.all.map do |merchant|
      @items.find_all_by_merchant_id(merchant.id).count
    end
  end

  def item_prices
    @items.all.map do |item|
      item.unit_price
    end
  end

  # Iteration 2 (Invoices)

  def average_invoices_per_merchant
    avg(invoices_per_merchant).to_f.round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    stdev(invoices_per_merchant).round(2)
  end

  def invoices_per_merchant
    @merchants.all.map do |merchant|
      @invoices.find_all_by_merchant_id(merchant.id).count
    end
  end

  def top_merchants_by_invoice_count
    avg = avg(invoices_per_merchant)
    stdev = stdev(invoices_per_merchant)

    @merchants.all.find_all do |merchant|
      @invoices.find_all_by_merchant_id(merchant.id).count > avg + (stdev * 2)
    end
  end

  def bottom_merchants_by_invoice_count
    avg = avg(invoices_per_merchant)
    stdev = stdev(invoices_per_merchant)

    @merchants.all.find_all do |merchant|
      @invoices.find_all_by_merchant_id(merchant.id).count < avg - (stdev * 2)
    end
  end

  def invoices_days_of_week
    @invoices.all.map do |invoice|
      invoice.created_at.wday
    end
  end

  def top_invoice_days_count
    invoice_days_count.find_all do |day, count|
      count > one_over_standard_dev
    end
  end

  def invoice_days_count
    {
      sunday:     invoices_days_of_week.count(0),
      monday:     invoices_days_of_week.count(1),
      tuesday:    invoices_days_of_week.count(2),
      wednesday:  invoices_days_of_week.count(3),
      thursday:   invoices_days_of_week.count(4),
      friday:     invoices_days_of_week.count(5),
      saturday:   invoices_days_of_week.count(6)
    }
  end

  def average_invoices_per_day
    (invoice_days_count.values.sum / 7.0).round(2)
  end

  def average_invoices_per_week_standard_deviation
    stdev(invoice_days_count.values)
  end

  def invoice_week_sum_diff_square
    invoice_days_count.values.map do |count|
      (count - average_invoices_per_day)**2
    end.sum
  end

  def one_over_standard_dev
    average_invoices_per_week_standard_deviation + average_invoices_per_day
  end

  def top_days_by_invoice_count
    top_days = []
    top_invoice_days_count.each do |day|
      top_days << day[0].to_s.capitalize
    end
    top_days
  end

  def find_transactions_by_invoice_id(invoice_id) # there can be multiple transactions per invoice
    transactions.all.find_all do |transaction|
      transaction.invoice_id == invoice_id
    end
  end

  def invoice_paid_in_full?(invoice_id)
    find_transactions_by_invoice_id(invoice_id).any? do |transaction|
      transaction.result == :success
    end
  end

  def find_invoice_item_by_invoice_id(invoice_id) 
    invoice_items.all.find_all do |invoice_item|
    invoice_item.invoice_id == invoice_id
    end
  end
  
  def invoice_status(status)
    invoice_count = invoices.all.select { |invoice| invoice.status == status }
    ((invoice_count.count).to_f / (invoices.all.count) * 100).round(2)
  end

  def total_revenue_by_date(date)
    invoice_date = find_invoice_by_date(date)
    invoice_date.map do |invoice|
      invoice_total(invoice.id)
    end.inject(:+)
  end

  def find_invoice_by_date(date)
    invoices.all.find_all do |invoice|
      invoice.created_at.to_date === date.to_date
    end
  end

  def total_merchant_revenue(merchant_id) 
    total = 0 
    x = @invoices.find_all_by_merchant_id(merchant_id)
    x.each do |invoice|
      if invoice_paid_in_full?(invoice.id)
        total += invoice_total(invoice.id)
      end
    end
    total.round(2)
  end

  def top_revenue_earners(rank = 20)
    merchants.all.max_by(rank) do |merchant|
      total_merchant_revenue(merchant.id)
    end
  end

  def pending_invoices
    pending_invoices = invoices.all.select do |invoice|
        (invoice.status != :shipped || :returned) && !invoice_paid_in_full?(invoice.id)
    end.uniq
    pending_invoices
  end

  def find_merchant_ids_with_pending_invoices
    pending_invoices.map do |invoice|
      invoice.merchant_id
    end.uniq
  end

  def merchants_with_pending_invoices
    find_merchant_ids_with_pending_invoices.map do |merchant_id|
      @merchants.find_by_id(merchant_id)
    end
  end  
       
  def merchants_with_only_one_item
    @merchants.all.find_all do |merchant|
      @items.find_all_by_merchant_id(merchant.id).count == 1
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchants_with_only_one_item.select do |merchant|
      month_merchant_created(merchant) == number_month(month)
    end
  end

  def month_merchant_created(merchant)
    merchant.created_at.to_date.month
  end

  def merchant_ids_in_month(month)
    invoices_in_month(month).map do |invoice|
      invoice.merchant_id
    end
  end

  def number_month(month)
    Date::MONTHNAMES.find_index(month)
  end

  def invoices_in_month(month)
    invoices.all.find_all do |invoice|
      invoice.created_at.to_date.month == number_month(month)
    end
  end

  def invoices_by_merchant(merchant_id)
    @invoices.all.find_all do |invoice|
      invoice.merchant_id == merchant_id
    end
  end

  def invoice_items_by_merchant(merchant_id)
    invoices_by_merchant(merchant_id).collect do |invoice|
      @invoice_items.all.find_all do |invoice_item|
        invoice_item.invoice_id == invoice.id
      end
    end.flatten
  end

  def revenue_by_merchant(merchant_id)
    invoice_items_by_merchant(merchant_id).sum do |invoice_item|
     invoice_item.quantity.to_i * invoice_item.unit_price
    end
  end
    
  def most_sold_item_for_merchant(merchant_id)
    items.find_by_id(max_item(merchant_id).item_id)
  end

  def max_item(merchant_id)
    find_merch_iis(merchant_id).max_by do |ii|
      ii.quantity
    end
  end

  def merch_items_list(merchant_id)
    items.find_all_by_merchant_id(merchant_id).map do |item|
      item.id
    end
  end

  def find_merch_iis(merchant_id)
    invoice_items.all.select do |ii|
      merch_items_list(merchant_id).include?(ii.item_id)
    end
  end

  def paid_invoice_items_by_merchant(merchant_id)
    invoice_items_by_merchant(merchant_id).find_all do |invoice_item|
      invoice_paid_in_full?(invoice_item.invoice_id)
    end
  end

  def best_item_for_merchant(merchant_id)
    paid_invoices = paid_invoice_items_by_merchant(merchant_id)
    best_invoice_item = paid_invoices.max_by do |invoice_item|
      invoice_item.quantity * invoice_item.unit_price
    end
    items.find_by_id(best_invoice_item.item_id)
  end
end