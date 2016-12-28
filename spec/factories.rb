FactoryGirl.define do 
	factory :user do 
		name					"Test User"
		email					"test-user@lol.com"
		password				"123456"
		password_confirmation	"123456"
	end
end