require 'time'

class Customer
  attr_reader :id, 
              :created_at
  attr_accessor :updated_at, 
                :first_name, 
                :last_name

  def initialize(attributes)
    @id           = attributes[:id].to_i
    @first_name   = attributes[:first_name]
    @last_name    = attributes[:last_name]
    @created_at   = Time.parse(attributes[:created_at].to_s)
    @updated_at   = Time.parse(attributes[:updated_at].to_s)
  end
end