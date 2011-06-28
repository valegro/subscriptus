namespace :states do
  desc 'Expire Subscription States'
  task :expire => :environment do
    User.validate_as(:system) do
      Subscription.expire_states
    end
  end
end
