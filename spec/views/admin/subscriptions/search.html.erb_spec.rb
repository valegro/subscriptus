require File.dirname(__FILE__) + '/../../../spec_helper'

describe 'admin/subscriptions/search.html.erb' do
  before(:each) do
    @search = Subscription.search
    @search.stub!(
                   :publication_id => '@s.pid',
                   :username => '@s.uname',
                   :state => '@s.state',
                   :renewal => '@s.ren',
                   :gift => '@s.g',
                   :order => nil, # searchlogic link ordering stuff
                   :conditions => {} # searchlogic link ordering stuff
    )
    @results = mock('@results', :offset => 0, :size => 10, :total_pages => 1, :each => nil)
    assigns[:search] = @search
    assigns[:results] = @results
    assigns[:count] = 10
  end

  it "should render" do
    render
  end

  it "should render shortcuts" do
    pending "shortcut functionalities and paths need to be done"
  end

  describe "the search form" do
    before(:each) do
      render
    end
    it "should render form" do
      response.should have_tag( 'form[action=/admin/subscriptions/search]' )
    end
    it "should render filter select in the form" do
      response.should have_tag( 'form select[id=filter_name]' )
    end
    it "should render add link" do
      response.should have_tag( 'a', 'Add' )
    end
    it "should render search button" do
      response.should have_tag( 'input[type=submit][value=Search]' )
    end
    it "should render reset link" do
      response.should have_tag( 'a', 'Reset' )
    end
  end

  it "should render results description" do
    @results.stub!( :offset => 110, :size => 10000)
    assigns[:count] = 65535
    render
    response.should have_tag('p', 'Showing 111 to 10110 of 65535 subscription(s).')
  end

  it "should render 'no subscription' if count is 0" do
    assigns[:count] = 0
    render
    response.should have_tag('p', 'No subscription found.')
  end

  it "should render pagination nav" do
    template.should_receive(:will_paginate).twice
    render
  end

  it "should render table" do
    render
    response.should have_tag('table[id=search_results]')
  end

  describe "rendering headers" do
    before(:each) do
      render
    end
    it "should render name header" do
      response.should have_tag('th', 'Name')
    end
    it "should render email header" do
      response.should have_tag('th', 'Email')
    end
    it "should render pubilcation header" do
      response.should have_tag('th', /Publication/)
    end
    it "should render state header" do
      response.should have_tag('th', 'State')
    end
    it "should render renewal header" do
      response.should have_tag('th', 'Renewal')
    end
    it "should render signd up header" do
      response.should have_tag('th', 'Signed Up')
    end
  end

  describe "with no result" do
    it "should not render any 'content' row" do
      template.should_not_receive(:render_result_row)
      render
    end
  end

  describe "with results" do
    it "should render 'content' rows" do
      template.should_receive(:render_result_row).with('render me')
      @results.should_receive(:each).and_yield('render me')
      render
    end
  end

  describe "bottom parts" do
    describe "script section" do
      %w(publication username state renewal gift).each { |key|
        describe "if #{key} set" do
          before(:each) do
            @search.stub!(:publication_id => '@s.pid',
                          :username => '@s.uname',
                          :state => '@s.state',
                          :renewal => '@s.ren',
                          :gift => '@s.g' )
          end
          it "should render js that calls add #{key} filter" do
            render
            response.body.should include("if( true ) add_field(filter_element_for('#{key}'));")
          end
        end
        describe "if #{key} not set" do
          before(:each) do
            @search.stub!(:publication_id => nil,
                          :username => nil,
                          :state => nil,
                          :renewal => nil,
                          :gift => nil )
          end
          it "should render js that calls add #{key} filter" do
            render
            response.body.should include("if( false ) add_field(filter_element_for('#{key}'));")
          end
        end
      }
    end
    describe "hidden div" do
      before(:each) do
        render
      end
      it "should have hidden div" do
        response.should have_tag('div[style=display:none]')
      end
      %w(username state renewal publication gift).each { |key|
        it "should have a div" do
          response.should have_tag("div[id=#{key}_field]")
        end
        it "should have a remove link" do
          response.should have_tag("a[id=remove_#{key}_link]")
        end
      }
      it "should have username field"
      it "should have state select"
      it "should have renewal field"
      it "should have publication select" do
        response.should have_tag('select[id=search_publication_id]')
      end
      it "should have gift field"
    end
  end
end
