require 'spec_helper'
 
	describe "Static Pages" do 

		subject{page}

		shared_examples_for "all static pages" do 
			it { should have_title (full_title(page_title)) }
			it { should have_selector('h1', text: heading) }
		end

		describe "Home page" do 
			before{visit root_path}	
			let(:page_title){''}
			let(:heading){"Sample App"}

			it_should_behave_like "all static pages"
			it { should_not have_title("| Home") }

			describe "for signed-in users" do 
				let(:user){ FactoryGirl.create(:user) }
				before do 
				 FactoryGirl.create(:micropost, user: user, content: "Test1")
				 FactoryGirl.create(:micropost, user: user, content: "Test2")
				 sign_in user
				 visit root_path
				end

				it "should render the user's feed" do 
					user.feed.each do |item|
						expect(page).to have_selector("li##{ item.id }", text: item.content)
					end
				end

				it { should have_selector('span', text: "#{user.microposts.count} microposts") }
				describe "test pluralize" do 
					before{ click_link "delete", match: :first}

					it{ should have_selector('span', text: "#{user.microposts.count} micropost" ) }
				end
			end 
		end

		describe "Help page" do 
			before{visit help_path}
			let(:page_title) {"Help"}
			let(:heading) {"Help"}

			it_should_behave_like "all static pages" 
		end

		describe "About page" do
			before{visit about_path}
			let(:page_title) {"About Us"}
			let(:heading) {"About Us"}

			it_should_behave_like "all static pages" 
		end

		describe "Contact page" do 
			before{visit contact_path}
			let(:page_title){"Contact"}
			let(:heading) {"Contact"}

			it_should_behave_like "all static pages" 
		end

		it "should have the right links on the layout" do
			visit root_path
			click_link "About"
			expect(page).to have_title(full_title('About Us'))
			click_link "Contact"
			expect(page).to have_title(full_title('Contact'))
			click_link "Help"
			expect(page).to have_title(full_title('Help'))
			click_link "Home"
			click_link "Sign up now!"
			expect(page).to have_title(full_title('Sign Up'))
			click_link "sample app"
			expect(page).to have_selector('h1', text: "Sample App")
		end

			
end