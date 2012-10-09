class Admin::System::ImportController < Admin::SystemController
  
  def index
  end

  def new

/*

	upload the CSV file and perform various opperations on it:

EXAMPLE CSV:

'rick', 'giner', 'inserttest@giner.com.au', '123456789', '22 william street', '', 'Melbourne', 'vic', '3000', 'Australia', 'Mr', 'inserttest', 'Valegro', 'male', 'publication one', 'active', '2012-09-06 06:26:50', '2013-10-01 05:29:03', '2013-10-01 05:29:03'

... must match publication name to the publications table and insert the ID; must also generate `role` and `created_at` for user table, e.g. 'subscriber', '2012-10-01 00:00:00'

SQL will be generated for the following inserts:

PER USER:

INSERT INTO 
users 
(`firstname`, `lastname`, `email`, `phone_number`, `address_1`, `address_2`, `city`, `state`, `postcode`, `country`, `title`, `login`, `company`, `gender`, `role`, `created_at`) 
VALUES 
('rick', 'giner', 'inserttest@giner.com.au', '123456789', '22 william street', '', 'Melbourne', 'vic', '3000', 'Australia', 'Mr', 'inserttest', 'Valegro', 'male', 'subscriber', '2012-10-01 00:00:00')

store user.id

LOOK UP PUBLICATION:

SELECT id FROM publications WHERE name LIKE 'Member & Subscriber Management'

IF publication.id & user.id :

INSERT INTO
subscriptions
(`user_id`, `publication_id`, `state`, `created_at` `expires_at`, `state_expires_at`)
VALUES
(19, 1, 'active', '2012-09-06 06:26:50', '2013-10-01 05:29:03', '2013-10-01 05:29:03')

REPORT ANY ERRORS

CREATE AND MAIL OUT PASSWORDS TO USERS


*/





  end

  def create
  end

  def edit

  end

  def update
 
  end
 
  def destroy
  end
  
end
