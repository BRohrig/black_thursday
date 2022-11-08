require './lib/sales_analyst'
require './lib/sales_engine'
require './lib/item_repository'
require './lib/merchant_repository'
require './lib/invoice_item_repository'
require './lib/customer_repository'

RSpec.describe SalesAnalyst do
  let(:sales_engine) {SalesEngine.from_csv({:items => './data/items.csv',
                                            :merchants => './data/merchants.csv',
                                            :invoices => './data/invoices.csv',
                                            :invoice_items => './data/invoice_items.csv',
                                            :customers => './data/customers.csv',
                                            :transactions => './data/transactions.csv'})}
  let(:sales_analyst) {sales_engine.analyst}

  it 'exists' do
    expect(sales_analyst).to be_a SalesAnalyst
  end

  describe '#average_items_per_merchant' do
    it 'gives how many items a merchant has on average' do
      expect(sales_analyst.average_items_per_merchant).to eq 2.88
    end
  end

  describe '#average_items_per_merchant_standard_deviation' do
    it 'returns the stdev of merchant average # of items' do
      expect(sales_analyst.average_items_per_merchant_standard_deviation).to eq 3.26
    end
  end

  describe '#merchants_with_high_item_count' do
    it 'returns merchants whose average # of items is >1 stdev' do
      avg = sales_analyst.average_items_per_merchant
      stdev = sales_analyst.average_items_per_merchant_standard_deviation

      expect(
        sales_analyst.merchants_with_high_item_count.all? {
          |merchant| sales_analyst.items.find_all_by_merchant_id(merchant.id).count > avg + stdev 
          }).to be true
    end
  end

  describe '#average_item_price_for_merchant' do
    it 'returns a BigDecimal of average item price' do
      expect(sales_analyst.average_item_price_for_merchant(12334105)).to eq 16.66
      expect(sales_analyst.average_item_price_for_merchant(12334257)).to eq BigDecimal(38.33,4)
    end
  end

  describe '#average_average_price_per_merchant' do
    it 'returns the average of all merchant average prices' do
      expect(sales_analyst.average_average_price_per_merchant).to eq 350.29
    end
  end

  describe '#golden_items' do
    it 'returns an array of all Item objects with price >2stdev above mean' do
      golden_items = sales_engine.items.find_all_by_price_in_range(6999..100000)
      expect(sales_analyst.golden_items).to eq golden_items
    end
  end

  describe '#top_buyers' do
    it 'returns the top x buyers' do
      expected = [313,517,148,370,478].map do |cust| 
        sales_analyst.find_customer_by_id(cust)
      end
      expect(sales_analyst.top_buyers(5)).to eq(expected)
    end
    it 'returns the top 20 buyers by default' do
      expected = [
                  313,517,148,370,478,
                  266,596,802,793,571,
                  655,433, 5 ,755,258,
                  888,821,274,954,250               
                  ].map do |cust| 
        sales_analyst.find_customer_by_id(cust)
      end
      expect(sales_analyst.top_buyers).to eq(expected)
    end
  end

  describe '#top_merchant_for_customer' do
    it 'returns the merchant a customer has spent the most with' do
      expected = sales_analyst.merchants.find_by_id(1)
      expect(sales_analyst.top_merchant_for_customer(1)).to eq(expected)
    end
  end

  describe '#one_time_buyers' do
    it 'returns an array of customers that only have one invoice' do
      require 'pry'; binding.pry
      expected = sales_analyst.customers.find_by_id(27)
      expect(sales_analyst.one_time_buyers[0]).to eq(expected)

      expected = sales_analyst.customers.find_by_id(61)
      expect(sales_analyst.one_time_buyers[1]).to eq(expected)

      expected = sales_analyst.customers.find_by_id(77)
      expect(sales_analyst.one_time_buyers[2]).to eq(expected)
    end
  end

  describe '#one_time_buyers_item' do
    it 'returns the item most commonly bought by one time buyers' do
      expected = []

      expect(sales_analyst.one_time_buyers_item).to eq(expected)
    end
  end

  describe '#find_item_numbers_by_invoice_id' do
    it 'returns an array of every item number on an invoice' do
      expected = sales_analyst.find_item_numbers_by_invoice_id(136)
require 'pry'; binding.pry
      expect(expected[0]).to eq 263512652
      expect(expected[1]).to eq 263401045
      expect(expected[2]).to eq 263410155
      expect(expected[3]).to eq 263434165
    end
  end

  describe '#find_invoice_items_by_invoice_id' do
    it 'returns an array of invoice items matching invoice id' do
      expected = sales_analyst.find_invoice_items_by_invoice_id(136)

      expect(expected[0].id).to eq 640
      expect(expected[1].id).to eq 641
      expect(expected[2].id).to eq 642
      expect(expected[3].id).to eq 643
    end
  end

  describe '#find_customer_by_id' do
    it 'returns a Customer object matching given id' do
      expected = sales_analyst.find_customer_by_id(1)
      expect(expected).to eq sales_analyst.customers.all[0]
    end
  end

  describe '#customer_spent' do
    it 'returns how much a customer has spent' do
      expected = sales_analyst.customer_spent(1)
      expect(expected).to eq BigDecimal(88758.65,7)
    end
  end

  describe '#customer_invoices' do
    it "returns an array of a customer's invoices" do
      expected = sales_analyst.customer_invoices(1)
      expect(expected).to eq(sales_analyst.invoices.all[0..7])
    end
  end

  describe '#invoice_revenue' do
    it 'returns the revenue generated by that invoice' do
      expect(sales_analyst.invoice_revenue(54)).to eq 3095.31
    end
  end

  describe '#invoice_items_by_invoice_id' do
    it 'returns an array of all invoice_items matching invoice id' do
      expected = sales_analyst.invoice_items_by_invoice_id(54)
      expect(expected).to eq(sales_analyst.invoice_items.all[236..238])
    end
  end

  describe '#average_invoices_per_merchant' do
    it 'gives how many invoices a merchant has on average' do
      expect(sales_analyst.average_invoices_per_merchant).to eq(10.49)
    end
  end

  describe '#average_invoices_per_merchant_standard_deviation' do
    it 'returns the stdev of merchant average # of invoices' do
      expect(sales_analyst.average_invoices_per_merchant_standard_deviation). to eq 3.29
    end
  end

  describe '#top_merchants_by_invoice_count' do
    it 'returns merchants whose average # of invoices >2 stdev' do
    avg = sales_analyst.average_invoices_per_merchant
    stdev = sales_analyst.average_invoices_per_merchant_standard_deviation
    expect(
      sales_analyst.top_merchants_by_invoice_count.all? {
      |merchant| sales_analyst.invoices.find_all_by_merchant_id(merchant.id).count > avg + (stdev * 2)
      }).to be true
    end
  end

  describe '#bottom_merchants_by_invoice_count' do
    it 'returns merchants whose average # of invoices <1 stdev' do
    avg = sales_analyst.average_invoices_per_merchant
    stdev = sales_analyst.average_invoices_per_merchant_standard_deviation
    require 'pry'; binding.pry
    # 12334235, 12334601, 12335000, 12335560
    expect(
      sales_analyst.bottom_merchants_by_invoice_count.all? {
      |merchant| sales_analyst.invoices.find_all_by_merchant_id(merchant.id).count < avg - (stdev * 2)
      }).to be true
    end
  end

  describe '#average_invoices_per_week_standard_deviation' do
    it 'returns standard deviation of invoices per week' do

      expect(sales_analyst.average_invoices_per_week_standard_deviation).to eq 18.07
    end
  end

  describe '#invoice_days_count' do
    it 'returns an array of invoice counts from sunday..saturday' do

      expect(sales_analyst.invoice_days_count).to eq [708, 696, 692, 741, 718, 701, 729]
    end
  end

  describe '#average_invoices_per_day' do
    it 'returns the average invoices per day' do

      expect(sales_analyst.average_invoices_per_day).to eq 712.14
    end
  end

  describe '#invoice_week_sum_diff_square' do
    it 'returns the first part of the formula for standard deviation' do

      expect(sales_analyst.invoice_week_sum_diff_square).to eq 1958.8572
    end
  end

  describe '#one_over_standard_dev' do
    it 'returns the first part of the formula for standard deviation' do

    expect(sales_analyst.one_over_standard_dev).to eq 730.21
  end
end

  describe '#top_days_by_invoice_count' do
    it 'return an array of the days at least one standard deviation over the mean' do

      expect(sales_analyst.top_days_by_invoice_count).to eq ["Wednesday"]
    end
  end


  describe '#invoice_paid_in_full?(invoice_id)' do
    it 'return true if transaction success and false if failed' do

      expected = sales_analyst.invoice_paid_in_full?(1)
      expect(expected).to eq true

      expected = sales_analyst.invoice_paid_in_full?(200)
      expect(expected).to eq true

      expected = sales_analyst.invoice_paid_in_full?(203)
      expect(expected).to eq false

      expected = sales_analyst.invoice_paid_in_full?(204)
      expect(expected).to eq false
    end
  end

  describe '#invoice_total(1)' do # change test later to other invoice number
    it 'will return the invoice total for that id' do

      expect(sales_analyst.invoice_total(1)).to eq 21067.77
    end
  end

  describe '#total_revenue_by_date' do
    it 'will give you the total revenue on any given date' do
      date = Time.parse("2012-03-27 14:54:09 UTC")
      
      expect(sales_analyst.total_revenue_by_date(date)).to eq 5977.78
    end
  end

  describe '#top_revenue_earners(x)' do
    it 'will return the top revenue earners. (will default to 20)' do
      merchants = sales_analyst.top_revenue_earners(10)

      merchant_1 = sales_analyst.top_revenue_earners(10).first
      merchant_2 = sales_analyst.top_revenue_earners(10).last
      
      expect(merchants.length).to eq 10
      # binding.pry
      expect(merchant_1.class).to eq Merchant
      expect(merchant_1.id).to eq 12334634
      # binding.pry

      expect(merchant_2.class).to eq Merchant
      expect(merchant_2.id).to eq 12335747
    end
  end

  xit "#merchants_with_only_one_item returns merchants with only one item" do
    expect(sales_analyst.merchants_with_only_one_item.length).to eq 243 #the number of merchants taken from spec harness
    expect(sales_analyst.merchants_with_only_one_item.first.class).to eq Merchant
  end

  xit "#merchants_with_only_one_item_registered_in_month returns merchants with only one invoice in given month" do
    expected = sales_analyst.merchants_with_only_one_item_registered_in_month("March")

    expect(expected.length).to eq 21
    expect(expected.first.class).to eq Merchant

    expected = sales_analyst.merchants_with_only_one_item_registered_in_month("June")

    expect(expected.length).to eq 18
    expect(expected.first.class).to eq Merchant
  end

  it "#revenue_by_merchant returns the revenue for given merchant" do
    expect(sales_analyst.revenue_by_merchant(12337411)).to eq (68159.36)
    expect(sales_analyst.revenue_by_merchant(12337411).class).to eq BigDecimal
  end

  xit '#most_sold_item_for_merchant returns the most sold item' do
    expect(sales_analyst.most_sold_item_for_merchant(merchant_id)).to eq [item]
  end

  xit '#best_item_for_merchant returns an item based off revenue generated' do
    expect(sales_analyst.best_item_for_merchant(merchant_id)).to eq [item]
  end
end