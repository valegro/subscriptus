class UserObserver < ActiveRecord::Observer

  def before_create(user)
    # TODO: What should this be?
    user.login ||= 'active_user'
  end

  # TODO: Delayed Job
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
end
