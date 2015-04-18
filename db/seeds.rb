# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def create_a_user(email, password, contact_person = "", company_name  = "", phone_number  = "", admin_status = :user)
	admin = :admin == admin_status
	User.create({:email => email, :password => password, :admin => admin, :contact_person => contact_person, :company_name => company_name, :telephone => phone_number}, :without_protection => true)
end

def link_form_questions_to_form(form,questions)
	question_objects = []
	questions.each_with_index do |question_attributes,index|
		question_attributes[:form_type] = form.form_name
		question_attributes[:order] = index + 1
		question_objects << FormQuestion.create(question_attributes)
	end
	form.form_questions << question_objects
end

objects_to_create = {}

create_a_user('admin@hostname.com', 'admin123', "", "", "", :admin)
create_a_user('user2@hostname.com', 'user1234', "John Wick", "Pineapple", "512-123-1235")
create_a_user('user3@hostname.com', 'user1234', "Kevin Chavez", "Apple", "232-567-4234")
create_a_user('user4@hostname.com', 'user1234', "Paul Lee", "Orange", "185-323-3523")

# Application Types
vendor_non_food = ApplicationType.create({:app_type => 'Vendor Exhibitor for Non-Food Items or Services', 
										  :description => 'Vendors who DO NOT sell or giveaway any food items.
										  - All other types of businesses can use this form.
										  - Non-profit organizations need to use another form.'})
sponsor = ApplicationType.create({:app_type => 'Sponsor',
								  :description => 'Any exhibitor or vendor who is willing to co-sponsor the event 
								  					for a productexclusivity and also be included in the festival 
								  					advertising and promotional campaign at no additional cost.'})
non_profit = ApplicationType.create({:app_type => 'Non-Profit Exhibitor',
									 :description => 'Any IRS registered tax exempt organization.'})
vendor_food = ApplicationType.create({:app_type => 'Vendor Exhibitor of Food Items',
									  :description => 'Vendors who Do sell or giveaway any food items.  
									  					- All types of businesses can use this form.
									  					- Non-profit organizations need to use another form.'})
restaurant_concessionaire = ApplicationType.create({:app_type => 'Restaurant Food Concessionaire'})

# Questionnaire
#adding seeds questions, each question has an attribute referances its parent(like a tree), the tree is as follow:
#
#                   'Which one came first?'
#                     /                 \
#                  (egg)             (chicken)
#                   /                     \
#     'How do you like it?'          'Which part of chicken do you like?'
#      /        |        \              /         |          |        \
#(scramble)   (ssu)     (raw)      (breast)    (legs)     (wings)    (eggs)

objects_to_create[:Questionnaire] = [
	{:question => 'Choose your allpication type. (Click on apllication to view detail)'},
	{:question => vendor_non_food.description, :parent_id => 1},
	{:question => vendor_food.description, :parent_id => 1},
	{:question => non_profit.description, :parent_id => 1},
	{:question => sponsor.description, :parent_id => 1}
]

#answer table has answer to referance to its question, as well as which question it leads to

objects_to_create[:Answers] = [
	{:ans => vendor_non_food.app_type, :questionnaire_id => 1, :leads_to => 2},
	{:ans => sponsor.app_type, :questionnaire_id => 1, :leads_to => 3},
	{:ans => non_profit.app_type, :questionnaire_id => 1, :leads_to => 4},
	{:ans => vendor_food.app_type, :questionnaire_id => 1, :leads_to => 5},
	{:ans => restaurant_concessionaire.app_type, :questionnaire_id => 1, :results_to => restaurant_concessionaire.id},
	{:ans => 'I am a ' + vendor_non_food.app_type, :questionnaire_id => 2, :results_to => vendor_non_food.id},
	{:ans => 'I am a ' + vendor_food.app_type, :questionnaire_id => 3, :results_to => vendor_food.id},
	{:ans => 'I am a ' + sponsor.app_type, :questionnaire_id => 4, :results_to => sponsor.id},
	{:ans => 'I am a ' + non_profit.app_type, :questionnaire_id => 5, :results_to => non_profit.id}
	# {:ans => vendor_non_food.app_type, :questionnaire_id => 1, :results_to => restaurant_concessionaire.id},
	# {:ans => sponsor.app_type, :questionnaire_id => 1, :results_to => vendor_non_food.id},
	# {:ans => non_profit.app_type, :questionnaire_id => 1, :results_to => sponsor.id},
	# {:ans => vendor_food.app_type, :questionnaire_id => 1, :results_to => non_profit.id}
]

# Forms
company_information = Form.create({:form_name => "Company Information"})

non_food_contract = Form.create({:form_name => "Exhibitor Vendor - Non Food Items and Services"})
restaurant_contract = Form.create({:form_name => "Restaurant Concessionaire Contract"})
sponsor_contract = Form.create({:form_name => "Sponsor Contract"})
non_profit_contract = Form.create({:form_name => "Exhibitor Contract - Non Profit"})
food_item_contract = Form.create({:form_name => "Exhibitor Contract of Food Items"})

advertising_contract = Form.create({:form_name => "Advertising Contract"})
health_permit_form = Form.create({:form_name => "Health Permit Form"})
conditions_of_agreement = Form.create({:form_name => "Conditions of Agreement"})
make_agreement = Form.create({:form_name => "Agreement"})


# Associate Application Types to forms
vendor_non_food.forms << [
	company_information,
	non_food_contract,
	advertising_contract,
	conditions_of_agreement,
	make_agreement
]

vendor_food.forms << [
	company_information,
	food_item_contract,
	advertising_contract,
	health_permit_form,
	conditions_of_agreement,
	make_agreement
]

sponsor.forms << [
	company_information,
	sponsor_contract,
	advertising_contract,
	conditions_of_agreement,
	make_agreement
]

non_profit.forms << [
	company_information,
	non_profit_contract,
	advertising_contract,
	conditions_of_agreement,
	make_agreement
]

restaurant_concessionaire.forms << [
	company_information,
	restaurant_contract,
	advertising_contract,
	health_permit_form,
	conditions_of_agreement,
	make_agreement
]

# create form questions for each form
questions_for_form = {}

questions_for_form[company_information]  = [
	{:question => "Mailing Address", :question_type => :textbox},
	{:question => "City", :question_type => :textbox},
	{:question => "State", :question_type => :textbox},
	{:question => "Zip", :question_type => :textbox},
	{:question => "Fax", :question_type => :textbox},
	{:question => "Website", :question_type => :textbox},
	{:question => "Company name for WVF Program listing", :question_type => :textbox}
]

questions_for_form[non_food_contract] = [
	{:question => 'Please provide a description of all items being displayed, promoted and/or sold. 
		Attach a seperate sheet if neccesary', 
		:question_type => :textbox},
	{:question => 'Food Guidelines...',
		:question_type => :statement},
	# {:question => 'Will you require a health permit?',
	# 	:answers => "[Yes, No]", 
	# 	:question_type => :radio_button},
	{:question => 'Will you use a sterno?', 
		:answers => "[Yes, No]", 
		:question_type => :radio_button},
	{:question => 'Exhibit Registration...', 
		:question_type => :statement},
	# {:question => 'Food Booth Fee',  
	# 	:question_type => :textbox},
	# {:question => 'City Health Permit Fee', 
	# 	:answers => "207", 
	# 	:question_type => :textbox},
	# {:question => 'Advertising:', 
	# 	:question_type => :textbox},
	# {:question => 'Total enclosed', 
	# 	:question_type => :textbox},
	# {:question => 'Please make payable to...', 
	# 	:question_type => :statement},
	{:question => 'Will you need electricity?',
		:answers => "[Yes, No]",
		:question_type => :radio_button},
	{:question => 'Please state electrical requirements...', 
		:question_type => :textbox}
]

questions_for_form[restaurant_contract] = [
	{:question => 'Please provide a description of all items being displayed, promoted and/or sold. 
		Attach a seperate sheet if neccesary', 
		:question_type => :textbox},
	{:question => 'Food Guidelines...',
		:question_type => :statement},
	{:question => 'Will you be distributing food/beverage?', 
		:answers => "[Yes, No]",
	 	:question_type => :radio_button},
	# {:question => 'Will you require a health permit?',
	# 	:answers => "[Yes, No]", 
	# 	:question_type => :radio_button},
	{:question => 'Will you use a sterno?', 
		:answers => "[Yes, No]", 
		:question_type => :radio_button},
	{:question => 'Exhibit Registration...', 
		:question_type => :statement},
	{:question => 'Food/Catering Booth Fee\n On or before July 15: $150\n After July 15:$250', 
		:answers => "[150, 250]", 
		:question_type => :radio_button},
	# {:question => 'Food Booth Fee',  
	# 	:question_type => :textbox},
	# {:question => 'City Health Permit Fee', 
	# 	:answers => "207", 
	# 	:question_type => :textbox},
	# {:question => 'Advertising:', 
	# 	:question_type => :textbox},
	# {:question => 'Total enclosed', 
	# 	:question_type => :textbox},
	# {:question => 'Please make payable to...', 
	# 	:question_type => :statement},
	{:question => 'Will you need electricity?',
		:answers => "[Yes, No]",
		:question_type => :radio_button},
	{:question => 'Please state electrical requirements...', 
		:question_type => :textbox}
] 

questions_for_form[advertising_contract] = 	[
	{:question => 'Full Page',
		:answers => "[Free, $500, N/A]",
		:question_type => :radio_button},
	{:question => 'Half Page',
		:answers => "[Free, $300, N/A]",
		:question_type => :radio_button},
	{:question => 'Quarter Page',
		:answers => "[Free, $200, N/A]",
		:question_type => :radio_button},
	{:question => 'One Eigth Page',
		:answers => "[$100, N/A]",
		:question_type => :radio_button},
	{:question => 'Business Card Size',
		:answers => "[$75, $50]",
		:question_type => :radio_button},
	{:question => 'Total Enclosed', 
		:question_type => :textbox},
	{:question => 'Encosed camera-ready ad/ logo...',
		:question_type => :checkbox},
	{:question => 'Email electronic copy...',
		:question_type => :checkbox},
	{:question => 'Mail Information',
		:question_type => :statement},
	{:question => 'Authorized Signature',
		:question_type => :textbox},
	{:question => 'Please upload here',
		:question_type => :textbox}
]

questions_for_form[conditions_of_agreement] = [
	{:question => 'Company/Organization', 
		:question_type => :textbox},
	{:question => 'Conditions of Agreement ......', 
		:answers => "[Agree]",
		:question_type => :radio_button}
]

questions_for_form[health_permit_form] = [
	{:question => "1. Name of Event:",
		:question_type => :textbox},
	{:question => "Location:",
		:question_type => :textbox},
	{:question => "Date(s):",
		:question_type => :textbox},
	{:question => "Number of booths:",
		:question_type => :textbox},
	{:question => "Number of Carts:",
		:question_type => :textbox},
	{:question => "Start Time:",
		:question_type => :textbox},
	{:question => "2. Company Name:",
		:question_type => :textbox},
	{:question => "Address:",
		:question_type => :textbox},
	{:question => "Phone:",
		:question_type => :textbox},
	{:question => "Fax:",
		:question_type => :textbox0},
	{:question => "Email:",
		:question_type => :textbox},
	{:question => "On-Site Representative:",
		:question_type => :textbox},
	{:question => "3. Name of Facility:",
		:question_type => :textbox},
	{:question => "Name & Address:",
		:question_type => :textbox},
	{:question => "Phone:",
		:question_type => :textbox},
	{:question => "Fax:",
		:question_type => :textbox},
	{:question => "E-mail:",
		:question_type => :textbox},
	{:question => "Travel Time:",
		:question_type => :textbox},
	{:question => "Plumbed Sink:",
		:question_type => :textbox},
	{:question => "Warm H20:",
		:question_type => :textbox},
	{:question => "3 compartment sink:",
		:question_type => :textbox},
	{:question => "Other method approved:",
		:question_type => :textbox},
	{:question => "Hot:",
		:question_type => :textbox},
	{:question => "Cold:",
		:question_type => :textbox},
	{:question => "Food Item:",
		:question_type => :textbox},
	{:question => "Off-Site Prep:",
		:question_type => :textbox},
	{:question => "Cooking Procedures:",
		:question_type => :textbox},
	{:question => "Holding Methods:",
		:question_type => :textbox},
	{:question => "Applicant Signaure:",
		:question_type => :textbox},
	{:question => "Date:",
		:question_type => :textbox},
	{:question => "Printed Name:",
		:question_type => :textbox}
]

questions_for_form[sponsor_contract] = [
	{:question => 'Please provide a description of all items being displayed, promoted and/or sold. 
		Attach a seperate sheet if neccesary', 
		:question_type => :textbox},
	{:question => 'Food Guidelines...',
		:question_type => :statement},
	{:question => 'Will you be distributing food/beverage?', 
		:answers => "[Yes, No]",
	 	:question_type => :radio_button},
	# {:question => 'Will you require a health permit?',
	# 	:answers => "[Yes, No]", 
	# 	:question_type => :radio_button},
	{:question => 'Will you use a sterno?', 
		:answers => "[Yes, No]", 
		:question_type => :radio_button},
	{:question => 'Exhibit Registration...', 
		:question_type => :statement},
	{:question => "Principal Sponsor ($3000)
		-Promiment exhibitor location
		-Name on all publicity
		-Full page ad in event program
		-Product exclusivity
		-Logo link on SFVS website
		-Booth (12'x8')
		-Two tables with two chairs",
		:question_type => :statement},
	{:question => "Major Sponsor ($2000)
		-Name on special publicity
		-Half page ad in event program
		-Logo link on SFVS website
		-Booth (12'x8')
		-Two tables with two chairs",
		:question_type => :statement},
	{:question => "Associate Sponsor ($1000)
		-Newsletter recognition
		-Quarter page ad in event program
		-Booth (8'x8')
		-One table with two chairs",
		:question_type => :statement},
	{:question => "Supporting Sponsor [non-exhibiting] ($500)
		-Newsletter recognition
		-Quarter page ad in event program",
		:question_type => :statement},
	{:question => "Included above are 6' x 2.5' table(s), chairs, health permits, and electricity (except non-exhibitor)",
		:question_type => :statement},
	{:question => 'Sponsorship type',
		:answers => "[Principal Sponsor ($3000), Major Sponsor ($2000), 
			Associate Sponsor ($1000), Supporting Sponsor [non-exhibiting] ($500)]", 
		:question_type => :radio_button},	
	{:question => 'Will you need electricity?',
		:answers => "[Yes, No]",
		:question_type => :radio_button},
	{:question => 'Please state electrical requirements...', 
		:question_type => :textbox}
	]

questions_for_form[food_item_contract] = [
	{:question => 'Please provide a description of all items being displayed, promoted and/or sold. 
		Attach a seperate sheet if neccesary', 
		:question_type => :textbox},
	{:question => 'Food Guidelines...',
		:question_type => :statement},
	{:question => 'Non-Food Guidelines...',
		:question_type => :statement},
	{:question => 'Will you be distributing food/beverage?', 
		:answers => "[Yes, No]",
	 	:question_type => :radio_button},
	# {:question => 'Will you require a health permit?',
	# 	:answers => "[Yes, No]", 
	# 	:question_type => :radio_button},
	{:question => 'Will you use a sterno?', 
		:answers => "[Yes, No]", 
		:question_type => :radio_button},
	{:question => 'Do you guarantee your products on display at the Festival to be vegan?', 
		:answers => "[Yes, No]", 
		:question_type => :radio_button},
	{:question => 'Exhibit Registration...', 
		:question_type => :statement},
	{:question => 'Food/Catering Booth Fee\n On or before July 15: $150\n After July 15:$250', 
		:answers => "[150, 250]", 
		:question_type => :radio_button},
	{:question => "Regular Booth 'B' - Open Courtyard", 
		:answers => "[150 (Before July 15), 250 (After July 15)]",
	 	:question_type => :radio_button},
	{:question => "Regular Booth 'C' - Gallery Building", 
		:answers => "[200 (Before July 15), 300 (After July 15)]",
	 	:question_type => :radio_button},
	{:question => "Health Permit Fee", 
		:answers => "[High risk city health permit ($207), 
			Low risk city health permit free ($105)]",
	 	:question_type => :radio_button},
	 {:question => "Electricity Fee", 
		:answers => "[75, N/A]",
	 	:question_type => :radio_button},
	{:question => "Number of additional chairs ($5 each)",
		:question_type => :textbox},
	{:question => 'Will you need electricity?',
		:answers => "[Yes, No]",
		:question_type => :radio_button},
	{:question => 'Please state electrical requirements...', 
		:question_type => :textbox}
	]

questions_for_form[non_profit_contract] = 	[
	{:question => 'Product/Service Description',
		:question_type => :textbox},
	{:question => 'Non-Profit Registration',
		:question_type => :statement},
	{:question => 'Non-Profit Booth',
		:answers => "[$165, $215]",
		:question_type => :radio_button},
	{:question => 'Non-Profit Booth Fee',
		:question_type => :textbox},
	{:question => 'Electricity Fee, $75',
		:question_type => :textbox},
	{:question => 'Additional Chair $5 Each', 
		:question_type => :textbox},
	{:question => 'Advertising',
		:question_type => :textbox},
	{:question => 'TOTAL ENCLOSED',
		:question_type => :textbox},
	{:question => 'Please make check payable to...',
		:question_type => :statement},
	{:question => 'Will you need electricity?',
		:answers => "[Yes, No]",
		:question_type => :radio_button},
	{:question => 'Please state electrical requirements...',
		:question_type => :textbox}
]

questions_for_form[make_agreement] = [
	{:question => 'Agreement...',
		:question_type => :statement},
	{:question => "Name:",
		:question_type => :textbox},
	{:question => "Signature:",
		:question_type => :textbox},
	{:question => "Title:",
		:question_type => :textbox},
	{:question => "Date:",
		:question_type => :textbox}
]

questions_for_form.each do |form_object, form_question_attributes|
	link_form_questions_to_form form_object, form_question_attributes
end

# seed database for every object in objects_to_create
objects_to_create.each do|obj,params|
	obj_class = obj.to_s.constantize
	params.each do |a|
		obj_class.create!(a)
	end
end
