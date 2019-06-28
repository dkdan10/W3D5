class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    AttrAccessorObject.my_attr_reader(*names)
    AttrAccessorObject.my_attr_setter(*names)
  end
  
  def self.my_attr_reader(*names)
    names.each do |name|
      define_method(name) do
        instance_variable_get("@" + name.to_s)
      end
    end
  end

  def self.my_attr_setter(*names)
    names.each do |name|
      define_method("#{name}=") do |set_val|
        instance_variable_set("@" + name.to_s, set_val)
      end
    end
  end

end
