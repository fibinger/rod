$:.unshift("lib")
require 'rod'
require 'rspec/expectations'
include RSpec::Matchers

# This class have properties in oposite order as the class in the
# properties_order_create file.
class User < Rod::Model
  database_class Rod::Database
  field :surname, :string
  field :name, :string
end

Rod::Database.development_mode = true

(lambda {Rod::Database.instance.open_database("tmp/properties_order")}).
  should raise_error(Rod::IncompatibleVersion)
