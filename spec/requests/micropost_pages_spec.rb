require 'spec_helper'

describe "MicropostPages" do

	subject{ page }

	let(:user){ FactoryGirl.create(:user) }
	before{ sign_in user }

	describe "micropost creation" do 
		before{ visit root_path }

		describe "with invalid information" do 

			it "should not create micropost" do 
				expect{ click_button "Post" }.not_to change(Micropost, :count)
			end

			describe "error messages" do 
				before{ click_button "Post" }

				it{ should have_content("error") }
			end
		end

		describe "with valid information" do 
			before do 
				fill_in "micropost_content", with: "Test text"
			end

			it "should create micropost" do 
				expect{ click_button "Post" }.to change(Micropost, :count).by(1)
			end
		end
	end

	describe "micropost destruction" do 
		before{ FactoryGirl.create(:micropost, user: user) }

		describe "as correct user" do 
			before{ visit root_path }

			it "should delete a micropost" do 
				expect{click_link "delete"}.to change(Micropost, :count).by(-1)
			end
		end

		describe "as wrong user" do 
			let(:wrong_user){ FactoryGirl.create(:user) }
			before do 
				sign_in wrong_user 
				visit user_path(user)
			end

			it{ should_not have_link('delete') }
			it{ should have_title(user.name) }
		end
	end
end
