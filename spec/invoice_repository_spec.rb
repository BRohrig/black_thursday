require './lib/invoice_repository'
require './lib/invoice'

RSpec.describe InvoiceRepository do
  let(:invoice_repository) {InvoiceRepository.new}
  let(:invoice1) {Invoice.new({
    :id          => 6,
    :customer_id => 7,
    :merchant_id => 8,
    :status      => "pending",
    :created_at  => Time.now,
    :updated_at  => Time.now,
  })}
  let(:invoice2) {Invoice.new({
    :id          => 7,
    :customer_id => 8,
    :merchant_id => 9,
    :status      => "pending",
    :created_at  => Time.now,
    :updated_at  => Time.now,
  })}
  let(:invoice3) {Invoice.new({
    :id          => 8,
    :customer_id => 8,
    :merchant_id => 9,
    :status      => "shipped",
    :created_at  => Time.now,
    :updated_at  => Time.now,
  })}

  it 'is an instance of a #invoice_repository' do
    expect(invoice_repository).to be_a(InvoiceRepository)
  end

  it 'has a method to find_all_by_customer_id' do
    invoice_repository.all << invoice1
    invoice_repository.all << invoice2
    invoice_repository.all << invoice3

    expect(invoice_repository.find_all_by_customer_id(7)).to eq([invoice1])
    expect(invoice_repository.find_all_by_customer_id(8)).to eq([invoice2, invoice3])
    expect(invoice_repository.find_all_by_customer_id(2)).to eq []
  end

  it 'has a method to find_all_by_merchant_id' do
    invoice_repository.all << invoice1
    invoice_repository.all << invoice2
    invoice_repository.all << invoice3

    expect(invoice_repository.find_all_by_merchant_id(8)).to eq([invoice1])
    expect(invoice_repository.find_all_by_merchant_id(9)).to eq([invoice2, invoice3])
    expect(invoice_repository.find_all_by_merchant_id(1)).to eq []
  end

  it 'has a method to find_all_by_status' do
    invoice_repository.all << invoice1
    expect(invoice_repository.find_all_by_status(:pending)).to eq([invoice1])

    invoice_repository.all << invoice2
    expect(invoice_repository.find_all_by_status(:pending)).to eq([invoice1, invoice2])
    expect(invoice_repository.find_all_by_status(:shipped)).to eq []
    expect(invoice_repository.find_all_by_status(:sold)).to eq []
  end
end