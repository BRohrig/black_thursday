require 'time'

class Transaction
  attr_reader :id, 
              :invoice_id,
              :created_at

  attr_accessor :updated_at,
                :credit_card_number,
                :credit_card_expiration_date,
                :result

  def initialize(attributes)
    @id                           = attributes[:id].to_i
    @invoice_id                   = attributes[:invoice_id].to_i
    @credit_card_number           = attributes[:credit_card_number]
    @credit_card_expiration_date  = attributes[:credit_card_expiration_date]
    @result                       = attributes[:result].to_sym
    @created_at                   = Time.parse(attributes[:created_at].to_s)
    @updated_at                   = Time.parse(attributes[:updated_at].to_s)
  end
end
