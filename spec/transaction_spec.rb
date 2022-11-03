require './lib/transaction'

RSpec.describe Transaction do
  let(:transaction) {Transaction.new({
    :id => 1, 
    :invoice_id => 2,
    :credit_card_number => 3,
    :credit_card_expiration_date  => 4,
    :result => "success",
    :created_at => Time.now,
    :updated_at => Time.now
  })}

  it 'exists and takes in info and gives access to them' do
    allow(Time).to receive(:now).and_return(@time_now)

    expect(transaction).to be_a(Transaction)
    expect(transaction.id).to eq(1)
    expect(transaction.invoice_id).to eq(2)
    expect(transaction.credit_card_number).to eq(3)
    expect(transaction.credit_card_expiration_date).to eq(4)
    expect(transaction.result).to eq("success")
    expect(transaction.created_at).to eq(Time.now)
    expect(transaction.updated_at).to eq(Time.now)
  end
end