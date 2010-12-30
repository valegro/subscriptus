module AdminHelper
  def format_timestamp(time)
    time.in_time_zone(APP_TIMEZONE).strftime(STANDARD_TIME_FORMAT)
  end
end
