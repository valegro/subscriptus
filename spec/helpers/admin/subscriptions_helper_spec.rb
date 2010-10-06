require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SubscriptionsHelper do
  include Admin::SubscriptionsHelper
  before(:each) do
    @content = mock('@content')
    @content.stubs(:user => mock('user', :fullname => 'S. Pam', :email => 'spam@ham'),
                   :publication => mock('publication', :name => 'Hungarian Phrasebook'),
                   :state => 'Sealand',
                   :expires_at => Time.parse('2010-09-01'),
                   :created_at => Time.parse('2010-09-01')
                  )
    @result = render_result_row(@content)
  end
  it "should render row" do
    @result.should have_tag('tr')
  end
  it "should render fullname" do
    @result.should have_tag('tr td', 'S. Pam')
  end
  it "should render email" do
    @result.should have_tag('tr td', 'spam@ham')
  end
  it "should render publication name" do
    @result.should have_tag('tr td', 'Hungarian Phrasebook')
  end
  it "should render state" do
    @result.should have_tag('tr td', 'Sealand')
  end
  it "should render expiry date" do
    @result.should have_tag('tr td', '01/09/2010')
  end
  it "should render creation date" do
    @result.should have_tag('tr td', '01/09/2010')
  end
end
