class UserObserver < ActiveRecord::Observer
  include ActiveMerchant::Utils

  def before_validation_on_create(user)
    unless user.admin?
      user.login = generate_unique_id
    end
  end

  def after_create(user)
    unless user.admin?
      Wordpress.send_later(:create, {
        :login => user.login,
        :firstname => user.firstname,
        :lastname => user.lastname,
        :email => user.email,
        :pword => user.password
      })
    end
  end

  def after_save(user)
    unless user.admin?
      user.send_later :sync_to_campaign_master
    end
  end

  def after_update(user)
    unless user.admin?
      Wordpress.send_later(:update, {
        :login => user.login,
        :firstname => user.firstname,
        :lastname => user.lastname,
        :email => user.email
      })
    end
  end

  def before_save(user)
    # Set the gender
    user.gender = case user.title.try(:to_sym)
      when :Mr    then :male
      when :Sir   then :male
      when :Fr    then :male
      when :Mrs   then :female
      when :Ms    then :female
      when :Miss  then :female
      when :Lady  then :female
    end
  end
end
