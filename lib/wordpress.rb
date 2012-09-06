class Wordpress
  require 'rest_client' 

  class Error < StandardError; end
  class PrimaryKeyMismatch < Error; end

  class << self
    attr_accessor :enabled
  end

  # Force it to be enabled
  # def self.enabled
  #   true
  # end
  
  def self.config
    @@config ||= YAML.load_file(File.join(RAILS_ROOT, 'config', 'wordpress.yml'))[RAILS_ENV].symbolize_keys
  end
  
  def self.exists?(opts={})
    check_any_required(opts, :login, :email)
    Rails.logger.warn("Exists #{opts.inspect}")
    res = make_request(opts.merge(:func => 'exists')).strip
    return !res.blank? && res != "-1"
  end
  
  def self.create(opts={})
    check_required(opts, :login, :pword, :email)
    opts[:premium] = false unless opts.has_key?(:premium)
    make_request_and_raise_error(opts.merge(:func => 'create'))
  end
  
  def self.update(opts={})
    check_required(opts, :login)
    Rails.logger.warn("Update #{opts.inspect.reject { |key,v| key == :pword }}")
    opts[:premium] = false unless opts.has_key?(:premium)
    make_request_and_raise_error(opts.merge(:func => 'update'))
  end
  
  def self.authenticate(opts={})
    check_any_required(opts, :login, :email)
    Rails.logger.warn("Authentication #{opts.inspect}")
    check_required(opts, :pword)
    res = make_request(opts.merge(:func => 'authenticate')).strip
    return !res.blank? && res != "-1"
  end

private
  def self.make_request(opts)
    if self.enabled
      #res = RestClient.get(Wordpress.config[:endpoint], :params => opts.map{|k,v| "#{k}=#{v}"}.join('&'), :accept => :text).to_str
      res = RestClient.get(Wordpress.config[:endpoint], :params => opts.merge(:key => Wordpress.config[:key], "subscriptus" => ""), :accept => :text).to_str
      res
    else
      ''
    end
  end
  
  def self.make_request_and_raise_error(opts, expected_result = nil)
    expected_result ||= opts[:login] 
    if self.enabled
      make_request(opts).tap do |result|
        raise Error.new("#{result} was returned, #{expected_result} was expected: (#{opts.inspect})") unless result == expected_result
      end
    else
      opts[:login]
    end
  end
  
  def self.check_any_required(opts, *required)
    raise Error.new(%(options missing one of the following required key(s): #{required.map{|k| ":#{k}"}.join(', ')} (#{opts.inspect}) were provided)) if (required - opts.keys == required)
  end
  
  def self.check_required(opts, *required)
    raise Error.new(%(options missing required key(s): #{(required - opts.keys).map{|k| ":#{k}"}.join(', ')} (#{opts.inspect}) were provided)) unless (required & opts.keys == required)
  end
end
