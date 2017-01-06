namespace :db do 
	desc "Fill database with sample data"
	task populate: :environment do 
		admin = User.create!(name: "Lesha",
							email: "lesha@admin.com",
							password: "123456",
							password_confirmation: "123456",
							admin: true)
		99.times do |n|
			name = Faker::Name.name
			email = "email-#{n+1}@user.com"
			password = "password"
			User.create!(name: name,
						email: email,
						password: password,
						password_confirmation: password)
		end
	end
end