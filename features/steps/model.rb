require 'rspec/expectations'

module RodTest
end

Before do
  @instances = {}
end

def get_class(class_name)
  klass = RodTest.const_get(class_name) rescue nil
  if klass.nil?
    klass = Class.new(Rod::Model)
    RodTest.const_set(class_name,klass)
  end
  klass
end

def get_instance(class_name,position,cache=false)
  if cache
    @instances[class_name][get_position(position)]
  else
    get_class(class_name)[get_position(position)]
  end
end

def get_value(value)
  case value
  when /^\d+\.\d+$/
    value.to_f
  when /^\d+$/
    value.to_i
  else
    value = value.scan(/[^\d\\]+|\\\d+/).map do |segment|
      case segment
      when /\\\d+/
        $&.to_i.chr
      else
        segment
      end
    end.join("")
    value
  end
end

def get_position(position)
  case position
  when "first"
    0
  when "second"
    1
  when "third"
    2
  when "last"
    -1
  end
end

Given /^a class (\w+) has an? (\w+) field of type (\w+)( with (\w+) index)?$/ do |class_name,field,type,index,index_type|
  # index_type is ignored so far
  if index
    get_class(class_name).send(:field,field.to_sym,type.to_sym,:index => true)
  else
    get_class(class_name).send(:field,field.to_sym,type.to_sym)
  end
end

Given /^a class (\w+) has one (\w+)$/ do |class_name,field|
  get_class(class_name).send(:has_one,field.to_sym)
end

Given /^a class (\w+) has many (\w+)$/ do |class_name,field|
  get_class(class_name).send(:has_many,field.to_sym)
end

When /^I create a(nother|n)? (\w+)$/ do |ignore,class_name|
  @instance = get_class(class_name).new
  @instances[class_name] ||= []
  @instances[class_name] << @instance
end

When /^(his|her|its) (\w+) is '([^']*)'( multiplied (\d+) times)?$/ do |ignore,field,value,multi,multiplier|
  value = get_value(value)
#  p value
  if multi
    value *= multiplier.to_i
  end
  @instance.send("#{field}=".to_sym,value)
end

When /^(his|her|its) (\w+) is the (\w+) (\w+) created$/ do |ignore,field,position,class_name|
  @instance.send("#{field}=".to_sym,get_instance(class_name,position,true))
end

When /^(his|her|its) (\w+) contain the (\w+) (\w+) created$/ do |ignore,field,position,class_name|
  @instance.send("#{field}".to_sym) << get_instance(class_name,position,true)
end

When /^I store (him|her|it) in the database$/ do |ignore|
  @instance.store
end

Then /^there should be (\d+) (\w+)(\([^)]*\))?$/ do |count,class_name,ignore|
  get_class(class_name).count.should == count.to_i
end

Then /^the (\w+) of the (\w+) (\w+) should be '([^']*)'$/ do |field, position, class_name,value|
  get_instance(class_name,position).send(field.to_sym).should == get_value(value)
end

Then /^the (\w+) of the (\w+) (\w+) should be '([^']*)'( multiplied (\d+) times)$/ do |field, position, class_name,value,multi,multiplier|
  value = get_value(value)
  if multi
    value *= multiplier.to_i
  end
  get_instance(class_name,position).send(field.to_sym).should == value
end

Then /^the (\w+) (\w+) should not exist$/ do |position,class_name|
  (lambda {get_instance(class_name,position)}).should raise_error(IndexError)
end

Then /^the (\w+) of the (\w+) (\w+) should be equal to the (\w+) (\w+)$/ do |field, position1,class1,position2,class2|
  get_instance(class1,position1).send(field.to_sym).should ==
    get_instance(class2,position2,true)
end

Then /^the (\w+) (\w+) should have (\d+) (\w+)$/ do |position,class_name,count,field|
  get_instance(class_name,position).send(field.to_sym).count.should == count.to_i
end

Then /^the (\w+) of (\w+) of the (\w+) (\w+) should be equal to the (\w+) (\w+)$/ do |position0,field,position1,class1,position2,class2|
  get_instance(class1,position1).send(field.to_sym)[get_position(position0)].should ==
    get_instance(class2,position2,true)
end

Then /^(his|her|its) (\w+) should be '([^']*)'$/ do |ignore,field, value|
  value = get_value(value)
  @instance.send(field.to_sym).should == value
end

Then /^the (\w+) (\w+) should be equal with the instance$/ do |position1,class1|
  instance1 = get_instance(class1,position1)
  instance1.should == @instance
end

Then /^the (\w+) (\w+) should be identical with the (\w+) (\w+)$/ do |position1,class1,position2,class2|
  instance1 = get_instance(class1,position1)
  instance2 = get_instance(class2,position2)
  instance1.object_id.should == instance2.object_id
end

Then /^there should be (\d+) (\w+)(\([^)]*\))? with (\w+) of value '(\w+)'$/ do |count,class_name,ignore,field,value|
  get_class(class_name).send("find_all_by_#{field}",get_value(value)).count.should == count.to_i
end
