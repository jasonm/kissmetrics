require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Kissmetrics, "class" do
  it "is constructed with an API key" do
    Kissmetrics.new("my-api-key").api_key.should == "my-api-key"
  end
end

describe Kissmetrics do
  subject { Kissmetrics.new("my-api-key") }

  context "events" do
    before do
      stub_request(:get, %r{https://trk.kissmetrics.com/e}).to_return(:body => "")
    end

    it "records events without properties" do
      subject.record('Signed Up')
      WebMock.should have_requested(:get, "https://trk.kissmetrics.com/e").with({
        :query => {
          :_k => 'my-api-key',
          :_n => 'Signed Up'
        }
      })
    end

    it "records events with properties" do
      subject.record('Signed Up', { 'Plan' => 'Medium', 'Duration' => 'Year' })
      WebMock.should have_requested(:get, "https://trk.kissmetrics.com/e").with({
        :query => {
          :_k        => 'my-api-key',
          :_n        => 'Signed Up',
          'Plan'     => 'Medium',
          'Duration' => 'Year'
        }
      })
    end

    it "includes identity when recording an event" do
      subject.identify('user@example.com')
      subject.record('Signed Up', { 'Plan' => 'Medium', 'Duration' => 'Year' })
      WebMock.should have_requested(:get, "https://trk.kissmetrics.com/e").with({
        :query => {
          :_k        => 'my-api-key',
          :_n        => 'Signed Up',
          :_p        => 'user@example.com',
          'Plan'     => 'Medium',
          'Duration' => 'Year'
        }
      })
    end
  end
end
