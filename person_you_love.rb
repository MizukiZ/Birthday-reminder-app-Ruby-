class Person_you_love

 attr_accessor :first_name, :last_name, :date_of_birth,:relationship,:csv_array

 def initialize
   @csv_array = []
 end

 def full_name
   "#{@first_name} #{@last_name}"
 end

 def get_age
   age = Date.today.year - DateTime.parse(@date_of_birth).year
   age -=1 if Date.today.month < DateTime.parse(@date_of_birth).month || Date.today.month == DateTime.parse(@date_of_birth).month && Date.today.day < DateTime.parse(@date_of_birth).day
   age
 end

 def make_array_for_csv
   @csv_array = [@first_name,@last_name,@relationship,@date_of_birth]
 end
end
