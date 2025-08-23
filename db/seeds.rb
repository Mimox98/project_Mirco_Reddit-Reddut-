# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

u = User.first_or_create!(username: "DemoUser")


# Post 1: AI irony
Post.create!(
  user: u,
  subreddit: "r/AiWIllTakeMyJob",
  title: "My fridge just told me to learn Rust",
  body: "I'm not sure if this is a threat or career advice.",
  image_url: ActionController::Base.helpers.asset_path("fridge_ai.jpg"),
  score: rand(10..40)
)

# Post 2: rant (text only)
Post.create!(
  user: u,
  subreddit: "r/Ranting",
  title: "My laptop fan sounds like a jet engine",
  body: "Every time I open Chrome with 3 tabs, it sounds like it's about to take off.",
  score: rand(5..25)
)

# Post 3: steuer satire
Post.create!(
  user: u,
  subreddit: "r/Steuergeld",
  title: "Government spent €500k on a website that shows a spinning cube",
  body: "At least it's responsive... kinda.",
  image_url: ActionController::Base.helpers.asset_path("spinning_cube.jpg"),
  score: rand(15..50)
)

# Post 4: job plea
Post.create!(
  user: u,
  subreddit: "r/pleaseHireMeASAP",
  title: "I need a job",
  body: "please hire me I'm a good dedicated programmer",
  image_url: ActionController::Base.helpers.asset_path("hire_me.jpg"),
  score: 60
)
