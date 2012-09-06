Before do
  stub_request(:get, /.*crikey.*/).to_return { |request|
    case request.uri.query_values['func']
    when 'exists' then {:body => ''}
    when 'create','update' then {:body =>request.uri.query_values['login']}
    else
      {:body =>'Unknown function'}
    end
    }
end