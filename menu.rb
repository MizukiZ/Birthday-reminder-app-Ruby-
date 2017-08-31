require 'tty-prompt'
require "csv"
require 'terminal-table'
require "date"
require 'mail'

def menu(server)
  system "clear"
puts "wlecome to Birthday reminder!"
 loop do
prompt = TTY::Prompt.new
decision = prompt.select("How can I help you?", ["Sign Up","Sign In","Exit"])
  case decision
  when "Sign Up"
   sign_up(server)
   system "clear"
  when "Sign In"
    account = account_validation(server)
    system "clear"
    account_menu(account)
  when "Exit"
  puts "See you next time :)"
  sleep 1
  exit
  end #case end
 end #loop end
end #def end

def account_menu(account)
  puts "Hello #{account.full_name}"
  loop do
 prompt = TTY::Prompt.new
 decision = prompt.select("How can I help you?", ["Add New Person","List of people","Update","Setting","Log out"])
   case decision
   when "Add New Person"
  add_person_you_love(account)
  system "clear"
   when "List of people"
     system "clear"
     show_peple_list(account)
   when "Update"
     find_birthday(account)
   when "Setting"
     account_setting_menu(account)
   when "Log out"
   puts "You have logged out successfully!!"
   sleep 1
   system 'clear'
   break
   end #case end
  end #loop end
end


def sign_up(server)
system "clear"
new_account = Account.new(server)
prompt = TTY::Prompt.new
new_account.first_name = prompt.ask('What is your first name?'){|q| q.modify :capitalize}
new_account.last_name = prompt.ask('What is your last name?'){|q| q.modify :capitalize}
new_account.mail_address = prompt.ask('What is your email address?') do |q|
q.validate(/\A\w+@\w+\.\w+\Z/)
q.messages[:valid?] = 'Invalid email address'
                                                             end #ask end
new_account.date_of_birth = prompt.ask('What is your Birth day (YYYY-DD-MM)?')  do |q|
q.validate (/\A\d{4}\-(0?[1-9]|1[0-2])\-(0?[1-9]|1[0-9]|2[0-9]|3[0-1])\z/)
q.messages[:valid?] = 'Invalid date'
                                end #mask end

green = prompt.decorate(".",:green)
password_check = false
 while !password_check
new_account.password = prompt.mask('Enter your password (Must contain Number and Alphabet and at least 6 characters)', mask: green) do |q|
q.validate (/(?=.*\d)(?=.*[A-z]).{6,}/)
q.messages[:valid?] = 'Your password is not strong enough'
                                                       end #mask end
check = prompt.mask("Enter your password again", mask: green)
  if check == new_account.password
password_check = true
  else
puts "Error. #{check} is not your passward"
sleep 1
  end # if end
 end # while end
 server.add_account(new_account)
 new_account.make_array_for_csv
 server.save_account
end #def end


def account_validation(server)
  system "clear"
  prompt = TTY::Prompt.new
  green = prompt.decorate(".",:green)
  address_for_check = prompt.ask('What is your email address?')
  found_acoount = server.account_find(address_for_check)
  if !found_acoount.nil?
    wrong_count = 0
    loop do
    password_for_check = prompt.mask('What is your password?', mask: green)
    password_validation = found_acoount.check_password(password_for_check)
    if password_validation == true
      puts "You have logged in successfully!!"
      sleep 1.5
      return found_acoount
    else
      puts "Wrong password"
      wrong_count +=1
      if wrong_count == 3
      puts "You have tried 3 times."
      sleep 1.5
        menu(server)
      end
    end # if end
    end # loop
  else
    puts "#{address_for_check} is not registered"
    sleep 2
    menu(server)
  end # if end
end # def

def create_csv_accounts(server)
  CSV.open("#{server.name}_accounts.csv","a") do |data|
  end  # csv end
end

def create_csv_people(server)
  server.accounts.each do |account|
  CSV.open("#{account.first_name}'s_people.csv","a") do |data|
  end  # csv end
 end#each
end

def load_csv_account_data(server)
 CSV.foreach("#{server.name}_accounts.csv") do |row|
    new_account = Account.new(server)
    new_account.first_name = row[0]
    new_account.last_name = row[1]
    new_account.mail_address = row[2]
    new_account.date_of_birth = row[3]
    new_account.password = row[4]
    server.add_account(new_account)
    new_account.make_array_for_csv
 end #csv
end

def load_csv_people_data(server)
  server.accounts.each do |account|
    CSV.foreach("#{account.first_name}'s_people.csv") do |row|
     new_person = Person_you_love.new
     new_person.first_name = row[0]
     new_person.last_name = row[1]
     new_person.relationship = row[2]
     new_person.date_of_birth = row[3]
     account.add_people_you_love(new_person)
     new_person.make_array_for_csv
   end #foreach end
 end #accounts each end
end #def

def add_person_you_love(account)
  system "clear"
  new_person = Person_you_love.new
  prompt = TTY::Prompt.new
  new_person.first_name = prompt.ask('What is the person\'s first name?'){|q| q.modify :capitalize}
  new_person.last_name = prompt.ask('What is the person\'s last name?'){|q| q.modify :capitalize}
  new_person.relationship = prompt.ask('What is the relation between you and the person?'){|q| q.modify :capitalize}
  new_person.date_of_birth = prompt.ask('What is the person\'s Birth day (YYYY-DD-MM)?')  do |q|
  q.validate (/\A\d{4}\-(0?[1-9]|1[0-2])\-(0?[1-9]|1[0-9]|2[0-9]|3[0-1])\z/)
  q.messages[:valid?] = 'Invalid date'
                                  end #ask end
  account.add_people_you_love(new_person)
  new_person.make_array_for_csv
  account.save_people_you_love
end #def end

def show_peple_list(account)
  rows = []
  prompt = TTY::Prompt.new
  account.people_you_love.each do |person|
    rows << ["#{person.full_name}", "#{DateTime.parse(person.date_of_birth).strftime("%B %d")}","#{person.get_age}"]
                               end # each end
  table = Terminal::Table.new :headings => ['Name', 'Birthday',"Age"], :rows => rows
  puts table
 loop do
  choice = prompt.select("How can I help you?", ["Delete person from the list","Go bakc to account menu"])
  case choice
  when "Delete person from the list"
  system "clear"
  if account.people_you_love.empty?
  puts "No one is on your list."
  sleep 1
  system "clear"
  return
  end
  person_name = prompt.select("Who you want to delete?", account.people_you_love.map(&:full_name))
  person = nil
   account.people_you_love.each do |people|
    person = people if person_name == people.full_name
  end
  account.delete_person(person)
  puts "Deleted!"
  sleep 1.5
  system "clear"
  when "Go bakc to account menu"
  end # case
  system "clear"
  break
 end # loop end
end #def

def account_setting_menu(account)
   system "clear"
   prompt = TTY::Prompt.new
   loop do
  decision = prompt.select("How can I help you?", ["Change email address","Change password","Delete this account","Go back to main menu"])
    case decision
    when "Change email address"
     change_email_address(account)
    when "Change password"
     change_password(account)
    when "Delete this account"
      delete_decision = prompt.select("Are you sure? You want to delete this account?", ["Delete!","Change my mind"])
    case delete_decision
    when "Delete!"
      account.server.delete_account(account)
      puts "Deleted! Thank you"
      sleep 1.5
      menu(account.server)
    when "Change my mind"
      puts "Ok, no worries"
      sleep 1.5
      system "clear"
    when "Go back to main menu"
    end #case end
    end #case end
    break
  end #loop
end# def

def change_email_address(account)
  prompt = TTY::Prompt.new
  account.mail_address = prompt.ask('What is your new email address?') do |q|
  q.validate(/\A\w+@\w+\.\w+\Z/)
  q.messages[:valid?] = 'Invalid email address'
                                                          end #mask end
 account.make_array_for_csv
 account.server.save_account
 puts "Your email address has been changed!"
 sleep 1.5
 system "clear"
end

def change_password(account)
  prompt = TTY::Prompt.new
  green = prompt.decorate(".",:green)
  password_check = false
  while !password_check
    account.password = prompt.mask('Enter your new password (Must contain Number and Alphabet and at least 6 characters)', mask: green) do |q|
 q.validate (/(?=.*\d)(?=.*[A-z]).{6,}/)
 q.messages[:valid?] = 'Your password is not strong enough'
                                                        end #mask end
 check = prompt.mask("Enter your password again", mask: green)
   if check == account.password
 password_check = true
   else
 puts "Error. #{check} is not your passward"
 sleep 1
   end # if end
  end # while end
  account.make_array_for_csv
  account.server.save_account
  puts "Your passward has been changed!"
  sleep 1.5
  system "clear"
end

def find_birthday(account)
  birthdays_arr = []
  now_yday = Date.today.yday
  account.people_you_love.each do |person|
     if now_yday <= DateTime.parse(person.date_of_birth).yday && DateTime.parse(person.date_of_birth).yday - now_yday <= 7
       birthdays_arr << person
     end # if end
  end # each end
    if birthdays_arr.empty?
    puts   "Nobody's birthday is within one week."
      sleep 1
      system "clear"
    else
      send_massage(account,birthdays_arr)
      puts "remind mail has sent!!"
      sleep 1
      system "clear"
    end
end # def

def send_massage(account,birthdays)
  mail = Mail.new
  prompt = TTY::Prompt.new
  green = prompt.decorate(".",:green)
  gmail_password = prompt.mask('Enter your Gmail password', mask: green)

  options = { :address              => "smtp.gmail.com",
              :port                 => 587,
              :domain               => "smtp.gmail.com",
              :user_name            => "#{account.mail_address}",
              :password             => "#{gmail_password}",
              :authentication       => :plain,
              :enable_starttls_auto => true  }

  content_arr=[]
  birthdays.each do |person|
  content_arr << "#{person.full_name}'s Birthday is close!(#{DateTime.parse(person.date_of_birth).strftime("%B %d")}) and will trun #{person.get_age+1} years old'\n"
  end

  mail.charset = 'utf-8'
  mail.from "#{account.mail_address}"
  mail.to "#{account.mail_address}"
  mail.subject "Birthday reminder"
  mail.body "#{content_arr.join("")}"
  mail.delivery_method(:smtp, options)
  mail.deliver
end
