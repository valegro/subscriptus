module  Utilities

  # generates a random number that is saved after a successful recurrent profile creation and used later 
  # to access the users recurrent profile in secure pay in order to make new payments or cancel the proile
  # this unique number (called Client ID in AU sequre pay gateway) should be less than 20 characters long
  # this method uses secure random number generator in combination with offset(unique) that makes the number unique
  # the generated number is length numbers long
  def generate_unique_random_number(length)
    max = 1000000 # we assume self.id is less 6 digit or less
    offset = (max + self.id).to_s[1..max.size] # omit the first 1 from the beginning of the offset
    len = offset.size
    diff = length - len # size of the random number
    num = SecureRandom.random_number(10 ** diff).to_s + offset.to_s # time stamp makes the number unique
    num.to_i
  end

end