class UserObserver < ActiveRecord::Observer

  def before_create(user)
    # TODO: What should this be?
    user.login ||= 'active_user'
  end

  def after_create(user)
    UserMailer.send_later(:deliver_new_user, user)
    Wordpress.send_later(:create, {
        :login => user.login,
        :firstname => user.firstname,
        :lastname => user.lastname,
        :email => user.email,
        :pword => user.password
    })
  end

  def after_save(user)
    user.send_later :sync_to_campaign_master
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
