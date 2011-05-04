module Wordpress
  class Error < StandardError; end

  class << self
    attr_accessor :enabled
  end
  
  def self.config
    @@config ||= YAML.load_file(File.join(RAILS_ROOT, 'config', 'wordpress.yml'))[RAILS_ENV].symbolize_keys
  end
  
  def self.exists?(opts={})
    check_any_required(opts, :login, :email)
    return !make_request(opts.merge(:func => 'exists')).blank?
  end
  
  def self.create(opts={})
    check_required(opts, :login, :pword, :email)
    res = make_request_and_raise_error(opts.merge(:func => 'create'))
    p res
    res
  end
  
  def self.update(opts={})
    check_required(opts, :login)
    make_request_and_raise_error(opts.merge(:func => 'update'))
  end
  
  def self.authenticate(opts={})
    check_any_required(opts, :login, :email)
    check_required(opts, :pword)
    return make_request(opts.merge(:func => 'authenticate')) == 'true'
  end

private
  def self.make_request(opts)
    if self.enabled
      RestClient.get(Wordpress.config[:endpoint], :params => opts.merge(:key => Wordpress.config[:key]), :accept => :text).to_str
    else
      ''
    end
  end
  
  def self.make_request_and_raise_error(opts, expected_result = nil)
    expected_result ||= opts[:login] 
    if self.enabled
      make_request(opts).tap do |result|
        raise Error.new(result) unless result == expected_result
      end
    else
      opts[:login]
    end
  end
  
  def self.check_any_required(opts, *required)
    raise Error.new(%(options missing one of the following required key(s): #{required.map{|k| ":#{k}"}.join(', ')})) if (required - opts.keys == required)
  end
  
  def self.check_required(opts, *required)
    raise Error.new(%(options missing required key(s): #{(required - opts.keys).map{|k| ":#{k}"}.join(', ')})) unless (required & opts.keys == required)
  end
end
