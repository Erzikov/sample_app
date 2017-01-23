require 'spec_helper'

describe User do
  
	before do
		 @user = User.new(name: "Example User" , email: "user@example.com", 
		 						password: '123123', password_confirmation: '123123') 
	end

	subject{ @user }
	
	it { should respond_to(:name) }
	it { should respond_to(:email) } 
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
	it { should respond_to(:authenticate) }
	it { should respond_to(:remember_token) }
	it { should respond_to(:admin) }
	it { should respond_to(:microposts) }
	it { should respond_to(:feed) }
	it { should respond_to(:relationships) }
	it { should respond_to(:followed_users) }
	it { should respond_to(:follow!) }
	it { should respond_to(:unfollow!) }
	it { should respond_to(:following?) }
	it { should respond_to(:reverse_relationships) }
	it { should respond_to(:followers) }

	it { should be_valid }
	it { should_not be_admin }

	describe "when name is not present" do 
		before{@user.name = ""}

		it { should_not be_valid }
	end

	describe "when email is not present" do
		before{@user.email = ""}

		it { should_not be_valid }
	end

	describe "when name is too long" do
		before{@user.name = "a" * 51}

		it {should_not be_valid}
	end

	describe "when email format is invalid" do 
		it "should be invalid" do 
			addresses = %w[ user@lol,com user_at_lol.org example.user@lol.
				woman@lol_ol.com man@lol+olo.com  foo@bar..com]
			addresses.each do |invalid_address|
				@user.email = invalid_address
				expect(@user).not_to be_valid
			end
		end
	end

	describe "when email format is valid" do
		it "should be valid" do
			addresses = %w[ user@lol.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn ]
			addresses.each do |valid_address|
				@user.email = valid_address
				expect(@user).to be_valid
			end
		end
	end

	describe "when email is alredy taken" do
		before do
			user_with_same_email = @user.dup
			user_with_same_email.email = @user.email.upcase
			user_with_same_email.save
		end

		it {should_not be_valid}
	end

	describe "email address with mix case" do
		let(:mix_case_email){"MiX@cAse.coM"}

		it "should be save as all lower-case" do 
			@user.email = mix_case_email
			@user.save
			expect(@user.reload.email).to eq mix_case_email.downcase
		end		
	end

	describe "when password is not present" do
		before { @user = User.new( name:"User1", email: "user1@lol.com", 
									password: " ", password_confirmation: " " ) }
		it {should_not be_valid}
	end

	describe "when password dosen't match confimation" do
		before { @user.password_confirmation = "45643" }

		it { should_not be_valid } 
	end

	describe "with a password that's too short" do
		before { @user.password = @user.password_confirmation = "a" * 5 }

		it { should be_invalid }
	end

	describe "return value of authenticate method" do 
		before { @user.save }
		let(:found_user) {User.find_by(email: @user.email)}

		describe "with valid password" do
			it { should eq found_user.authenticate(@user.password) }
		end

		describe "with invalid password" do
			let(:user_for_invalid_password) {found_user.authenticate('lol')}

			it { should_not eq user_for_invalid_password }
			specify { expect(user_for_invalid_password).to be_false }

		end
	end

	describe "remember_token" do 
		before { @user.save }
		its(:remember_token){ should_not be_blank }
	end

	describe "with admin attribute set on true" do 
		before do 
			@user.save!
			@user.toggle(:admin)
		end
		
		it{ should be_admin }
	end

	describe "microposts associations" do 
		before{ @user.save }
		let!(:older_micropost){ FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago) }
		let!(:newer_micropost){ FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago) }

		it "should have the right microposts in the right order" do 
			expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
		end

		it "should destroy associated microposts" do 
			microposts = @user.microposts.to_a
			@user.destroy
			expect(microposts).not_to be_empty
			microposts.each do |micropost| 
				expect(Micropost.where(id: micropost.id)).to be_empty
			end
		end

		describe "status" do 
			let(:unfollowed_post) do 
				FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
			end
			let(:followed_user){ FactoryGirl.create(:user) }

			before do
				@user.follow!(followed_user) 
				3.times{ followed_user.microposts.create!(content: "TestContent") }
			end

			its(:feed){ should include(newer_micropost) }
			its(:feed){ should include(older_micropost) }
			its(:feed){ should_not include(unfollowed_post) }
			its(:feed) do
				followed_user.microposts.each do |micropost|
					should include(micropost)
				end
			end
		end
	end

	describe "following" do 
		let(:other_user){ FactoryGirl.create(:user) }
		before do 
			@user.save
			@user.follow!(other_user)
		end

		it{ should be_following(other_user) }
		its(:followed_users){ should include(other_user) }

		describe "and unfollowing" do 
			before{ @user.unfollow!(other_user) }

			it{ should_not be_following(other_user) }
			its(:followed_users){ should_not include(other_user) }
		end

		describe "followed user" do 
			subject{other_user}

			its(:followers){ should include(@user) }
		end

		it "should destroy associated relationships" do 
			relationships = @user.relationships.to_a
			@user.destroy
			expect(relationships).not_to be_empty
			relationships.each do |rls|
				expect(Relationship.where(id: rls.id)).to be_empty
			end
		end

		it "should destroy associated reverse_relationships" do 
			other_user.follow!(@user)
			reverse_relationships = @user.reverse_relationships.to_a 
			@user.destroy
			expect(reverse_relationships).not_to be_empty
			reverse_relationships.each do |r_rls| 
				expect(Relationship.where(id: r_rls.id)).to be_empty
			end
		end
	end
end
