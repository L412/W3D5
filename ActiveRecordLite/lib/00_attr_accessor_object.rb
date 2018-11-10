class AttrAccessorObject


  def self.my_attr_accessor(*names)

    names.each do |name|
      define_method(name) do
        instance_variable_get("@#{name}")
      end

      #WHY ARE WE PASSING THE VALUE IN PIPES?
      #IS THIS CONVENTION? THE WAY WE MAKE A () FOR ARGUMENTS?
      define_method("#{name}=") do |value|
        instance_variable_set("@#{name}", value)
      end
    end
  end

end
