class Server

  attr_accessor :accounts,:name
  def initialize(name)
    @name = name
    @accounts = []
  end

  def add_account(acoount)
  @accounts << acoount
  end

  def account_find(email)
    account_exist = nil
    @accounts.each do |account|
      if account.mail_address == email
        account_exist = account
      end # if end
    end # each end
     account_exist
  end# def

   def save_account
     CSV.open("#{@name}_accounts.csv","w") do |data|
       @accounts.each do |account|
           data << account.csv_array
       end #accounts each end
     end  # csv end
   end #def end

   def delete_account(account)
     @accounts.delete(account)
     save_account
   end
end
