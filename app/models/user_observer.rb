class UserObserver < ActiveRecord::Observer

  # TODO: Delayed Job
  def after_create(user)
    UserMailer.deliver_new_user(user)
    user.update_cm(:create!)
  end

  def after_update(user)
    user.update_cm(:update)
  end
end
