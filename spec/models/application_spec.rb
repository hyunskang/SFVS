require 'spec_helper'

describe Application do
	describe "it should be able to be created successfully" do
		myApp = Application.new
		myApp.year.should == nil
		myApp.content.should == {}
		myApp.completed.should == false
	end

	describe "content accessors should work" do
		myApp = Application.new
		myApp.year = 2015
		myApp.content = {:yourName => "John", :yourAge => 23}
		myApp.save!

		myApp.content["yourName"].should == "John"
		myApp.content["yourAge"].should == 23
	end

	describe "complicated content should still work" do
		myApp = Application.new
		myApp.content = {:depth1 => {:depth2 => {:depth3 => "hello world"} } }
		myApp.save!

		myApp.reload()
		myApp.content["depth1"]["depth2"]["depth3"].should == "hello world"
	end

	describe "should merge new contents with old one" do 
		myApp = Application.new
		myApp.year = 2015
		myApp.content = {"Person1" => {"yourName" => "John", "yourLastName" => "Wick"}}
		myApp.save!

		myApp.add_content({"Person2" => {"yourName" => "Neo", "yourLastName" => "The Chosen One"}})
		myApp.reload
		myApp.content.should == {"Person1" => {"yourName" => "John", "yourLastName" => "Wick"}, "Person2" => {"yourName" => "Neo", "yourLastName" => "The Chosen One"}}
	end

end
