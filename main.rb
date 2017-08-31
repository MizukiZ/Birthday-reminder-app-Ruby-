require_relative "server.rb"
require_relative "menu.rb"
require_relative "account.rb"
require_relative "person_you_love.rb"

new_server = Server.new("sever1")
create_csv_accounts(new_server)
load_csv_account_data(new_server)
create_csv_people(new_server)
load_csv_people_data(new_server)
menu(new_server)
