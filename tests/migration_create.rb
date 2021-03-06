$:.unshift("lib")
require 'rod'
require File.join(".",File.dirname(__FILE__),"migration_model1")

Rod::Database.development_mode = true


Database.instance.create_database("tmp/migration")

count = (ARGV[0] || 10).to_i
puts "Count in migration test: #{count}"

files = count.times.map{|i| UserFile.new(:data => "#{i} data")}
files.each{|f| f.store}

users = []
count.times do |index|
  account = Account.new(:login => "john#{index}",
                        :nick => "j#{index}")
  account.store
  user1 = User.new(:name => "John#{index}",
                  :surname => "Smith#{index}",
                  :account => account,
                  :mother => users[index-1],
                  :father => users[index-2],
                  :friends => [users[index-3],users[index-4]],
                  :files => [files[index],files[index + 1],files[index + 2]])
  user1.store

  account = Account.new(:login => "amanda#{index}",
                        :nick => "a#{index}")
  account.store
  user2 = User.new(:name => "Amanda#{index}",
                   :surname => "Amanda#{index}",
                   :account => account,
                   :mother => users[index-1],
                   :father => users[index-2],
                   :friends => [users[index-5],users[index-6]],
                   :files => [files[index],files[index+4],files[index+5],
                     nil,files[index+6]])
  user2.store
  users << user1
  users << user2
end

Database.instance.close_database
