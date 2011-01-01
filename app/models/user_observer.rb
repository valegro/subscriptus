class UserObserver < ActiveRecord::Observer

  def before_create(user)
    # TODO: What should this be?
    user.login ||= 'active_user'
  end

  # TODO: Delayed Job
  def after_create(user)
    UserMailer.deliver_new_user(user)
  end

  def after_save(user)
    user.send_later :sync_to_campaign_master
  end
end
