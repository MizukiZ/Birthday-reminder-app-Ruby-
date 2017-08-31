class Account

  attr_accessor :server,:first_name,:last_name,:mail_address,:date_of_birth,:password,:people_you_love, :csv_array

  def initialize(server)
    @people_you_love = []
    @csv_array = []
    @server = server
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def add_people_you_love(person)
    @people_you_love << person
  end

  def make_array_for_csv
   @csv_array =[@first_name, @last_name, @mail_address, @date_of_birth, @password]
  end

  def check_password(password)
    password_correct = false
    if @password == password
      password_correct = true
    end
    password_correct
  end

  def save_people_you_love
    CSV.open("#{@first_name}'s_people.csv","w") do |data|
      @people_you_love.each do |person|
          data << person.csv_array
      end #accounts each end
    end  # csv end
  end

  def delete_person(person)
    @people_you_love.delete(person)
    save_people_you_love
  end

end
