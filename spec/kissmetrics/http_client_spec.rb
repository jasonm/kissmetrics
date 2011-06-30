require 'spec_helper'

describe Kissmetrics::HttpClient, "class" do
  it "is constructed with an API key" do
    Kissmetrics::HttpClient.new("my-api-key").api_key.should == "my-api-key"
  end
end

describe Kissmetrics::HttpClient, "events" do
  subject { Kissmetrics::HttpClient.new("my-api-key") }

  before do
    stub_request(:get, %r{https://trk.kissmetrics.com/e}).to_return(:body => "")
  end

  it "records events without properties" do
    subject.record('identity', 'Signed Up')
    WebMock.should have_requested(:get, "https://trk.kissmetrics.com/e").with({
      :query => {
        :_k => 'my-api-key',
        :_p => 'identity',
        :_n => 'Signed Up'
      }
    })
  end

  it "records events with properties" do
    subject.record('identity', 'Signed Up', { 'Plan' => 'Medium', 'Duration' => 'Year' })
    WebMock.should have_requested(:get, "https://trk.kissmetrics.com/e").with({
      :query => {
        :_k        => 'my-api-key',
        :_p        => 'identity',
        :_n        => 'Signed Up',
        'Plan'     => 'Medium',
        'Duration' => 'Year'
      }
    })
  end
end

describe Kissmetrics::HttpClient, "aliasing" do
  before do
    stub_request(:get, %r{https://trk.kissmetrics.com/a}).to_return(:body => "")
  end

  subject { Kissmetrics::HttpClient.new("my-api-key") }

  it "aliases a person" do
    subject.alias('old_identity', 'new_identity')

    WebMock.should have_requested(:get, "https://trk.kissmetrics.com/a").with({
      :query => {
        :_k => 'my-api-key',
        :_p => 'old_identity',
        :_n => 'new_identity'
      }
    })
  end
end

describe Kissmetrics::HttpClient, "setting properties" do
  before do
    stub_request(:get, %r{https://trk.kissmetrics.com/s}).to_return(:body => "")
  end

  subject { Kissmetrics::HttpClient.new("my-api-key") }

  it "sets properties when unidentified" do
    subject.set('identity', {
      'Button'     => 'Blue',
      'Background' => 'Gray'
    })

    WebMock.should have_requested(:get, "https://trk.kissmetrics.com/s").with({
      :query => {
        :_k          => 'my-api-key',
        :_p          => 'identity',
        'Button'     => 'Blue',
        'Background' => 'Gray'
      }
    })
  end

  it "escapes keys and values" do
    http = stub('http', :use_ssl= => true, :get => true)
    Net::HTTP.stub(:new => http)

    http.should_receive(:get).with(%r{Some\+property=Some\+value})

    subject.set('identity', {
      'Some property' => 'Some value'
    })
  end
end
