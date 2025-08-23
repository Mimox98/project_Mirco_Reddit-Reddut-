class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :body
      t.string :subreddit
      t.string :image_url
      t.integer :score, default: 0, null: false
      t.integer :comments_count, default: 0, null: false

      t.timestamps
    end
  end
end
