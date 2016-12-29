require 'spec_helper'

describe "UserPages" do

		subject{page}

	describe "Sign Up page" do 
		before{visit signup_path}

			it { should have_content('Sign Up') }
			it { should have_title(full_title('Sign Up')) }

			let(:submit){ "Create my account" }

			describe "with invalid information" do 
				it "should not create a user" do
					expect{click_button submit}.not_to change(User, :count)
				end

				describe "after submission" do
					before{click_button submit}

					it { should have_title('Sign Up') }
					it { should have_content('error') }
					it { should have_selector('div#error_explanation') }
					it { should have_selector('div.alert.alert-error', text: "The form contains") }
					it { should have_selector('div.field_with_errors') }
				end
			end

			describe "with valid information" do
				before do 
					fill_in "Name", 		with: "User"
					fill_in "Email", 		with: "user@lol.com"
					fill_in "Password", 	with: "123456"
					fill_in "Confirmation",	with: "123456"
				end

				it "should create a user" do
					expect{click_button submit}.to change(User, :count).by(1)
				end

				describe "after signin user" do
					before{ click_button submit } 
					let(:user){User.find_by(email: "user@lol.com") }

					it { should have_title(full_title(user.name)) }
					it { should have_selector('div.alert.alert-success', text: 'Welcome to Sample App!') }
					it { should have_selector('div', text: user.name) }
					it { should have_selector('img.gravatar') }
					it { should have_link('Sign Out') }

					describe "followed by signout" do 
						before { click_link "Sign Out" }
						it { should have_link('Sign In') }
					end
				end


			end

	
		end

	describe "Profile page" do
		let(:user) {FactoryGirl.create(:user)}
		before {visit user_path(user)}

		it { should have_content(user.name) }
		it { should have_title(user.name) }
	end
end
