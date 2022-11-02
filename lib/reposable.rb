module Reposable
  def class_name
    Object.const_get(self.class.name.chomp('Repository'))
  end

  def create(attributes)
    
    stuff = {:name => attributes[:name],
            :id => next_id}
            
    all.push(class_name.new(stuff))
    
  end

  def next_id
    if all.empty?
      1
    else
      id = all.last.id
      id += 1
    end
  end
  
  def find_by_id(id)
    all.find do |entry|
      entry.id == id
    end
  end

  def update(id,attributes)
    attributes.each do |att,val|
      case att
      when :name
        find_by_id(id).name = val
      when :description
        find_by_id(id).description = val
      when :unit_price
        find_by_id(id).unit_price = val
      end
    end
  end

  def delete(id)
    all.delete(find_by_id(id))
  end
end