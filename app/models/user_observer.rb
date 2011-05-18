class UserObserver < ActiveRecord::Observer
  include ActiveMerchant::Utils

  def before_validation_on_create(user)
    unless user.admin?
      user.login = generate_unique_id
    end
  end

  def after_save(user)
    # Only sync if a sync'd column changes
    unless user.admin?
      if user.changes.keys.any? { |column| User::MAIL_SYSTEM_SYNC_COLUMNS.include?(column.to_s) }
        user.send_later(:sync_to_campaign_master)
      end
      if user.firstname_changed? || user.lastname_changed? || user.email_changed?
        user.send_later(:sync_to_wordpress)
      end
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
