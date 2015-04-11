require 'spec_helper'

describe Application do
  it "should be able to be created successfully" do
    myApp = Application.new
    myApp.year.should == nil
    myApp.content.should == {}
    myApp.completed.should == false
  end

  it "should make content accessors work" do
    myApp = Application.new
    myApp.year = 2015
    myApp.content = {:yourName => "John", :yourAge => 23}
    myApp.save!

    myApp.content["yourName"].should == "John"
    myApp.content["yourAge"].should == 23
  end

  it "should make complicated content work" do
    myApp = Application.new
    myApp.content = {:depth1 => {:depth2 => {:depth3 => "hello world"} } }
    myApp.save!

    myApp.reload()
    myApp.content["depth1"]["depth2"]["depth3"].should == "hello world"
  end

  it " should give the current applicationt time" do
    @test_time = Time.parse("2011-1-2")
    Time.stub(:now).and_return(@test_time)

    Application.current_application_year.should == @test_time.year
  end
end
