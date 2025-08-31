# Reddut — a micro-Reddit

Reddut is a minimal Reddit-style app built with Ruby on Rails, Tailwind CSS, Stimulus, and Turbo. It provides a Reddit-like feed with posts from predefined subreddits, upvotes, and comments. There’s no real authentication yet—each distinct browser session transparently receives a random demo user so you can interact right away.

Deployed on Render (free plan) — the database may sleep or reset. Available at https://reddut-demo.onrender.com/ (feel free to add posts / comment on existing posts) 

<img src="https://i.imgur.com/i5J3QJr.png" alt="Reddut demo" style="width:400px; border-radius:8px;">



## Table of contents

- [Features](#features)
- [Screens & UX](#screens--ux)
- [Tech stack](#tech-stack)
- [Data model](#data-model)
- [Routes](#routes)
- [Getting started](#getting-started)
- [Development tips](#development-tips)
- [Deployment (Render)](#deployment-render)
- [Security & limitations](#security--limitations)
- [License](#license)

## Features

- **Home**: replica of Reddit’s About page.
- **Reddut feed**: all posts across predefined subreddits, newest first.
- **Create posts**: publish to a selected subreddit.
- **Voting**: upvote posts (simple score nudge endpoint).
- **Comments**: add, edit (Turbo frame), or delete your own comments.
- **Demo users**: a random Username is created per browser and stored in a signed cookie—no signup required.

### Demo-user creation (simplified from ApplicationController):

```ruby
before_action :ensure_demo_user

def ensure_demo_user
  @current_user = User.find_by(id: cookies.signed[:demo_user_id]) if cookies.signed[:demo_user_id]
  return if @current_user

  @current_user = User.create!(Username: "DemoUser#{SecureRandom.random_number(10_000).to_s.rjust(4, '0')}")
  cookies.signed.permanent[:demo_user_id] = @current_user.id
end
```

## Screens & UX

- `/` → About-style landing page.
- `/posts` → Main “Reddut” feed (all posts).
- `/posts/:id` → Post detail with comments, inline comment editing via Turbo.
- New-post form with subreddit selector using the predefined list.
- Post cards show score, comment count, and actions.

## Tech stack

- Rails + Hotwire: Turbo Streams/Frames and Stimulus for snappy UI.
- Tailwind CSS for styling.
- Active Record with counter caches (comments_count on posts).
- SQLite (dev) or PostgreSQL (prod/Render).

## Data model

From `db/schema.rb`:

### users
- `Username :string` (required)
- `timestamps`

### posts
- `user_id :integer` (FK → users)
- `title :string` (required)
- `body :text` (optional)
- `image_url :string` (optional)
- `subreddit :string` (required; must be one of Post::SUBREDDITS)
- `score :integer` (default: 0)
- `comments_count :integer` (default: 0; maintained by counter_cache)
- `timestamps`

### comments
- `user_id :integer` (FK → users)
- `post_id :integer` (FK → posts, counter_cache)
- `body :text` (required)
- `timestamps`

### Model highlights

```ruby
class Post < ApplicationRecord
  SUBREDDITS = [
    "r/programming",
    "r/AiReplacesHumans",
    "r/AiWIllTakeMyJob",
    "r/Steuergeld",
    "r/pleaseHireMeASAP",
    "r/WhyShouldUHireMe",
    "r/Ranting"
  ].freeze

  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :subreddit, :title, presence: true
  validates :subreddit, inclusion: { in: SUBREDDITS }
  validate :text_or_image

  private
  def text_or_image
    if body.blank? && image_url.blank?
      errors.add(:base, "Provide body (text post) or image_url (image post)")
    end
  end
end

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true
  validates :body, presence: true
end

class User < ApplicationRecord
  has_many :posts, dependent: :nullify
  has_many :comments, dependent: :nullify
  validates :Username, presence: true
end
```

## Routes

Core routes (representative):

```
GET    /            → PagesController#home
GET    /posts       → PostsController#index
GET    /posts/new   → PostsController#new
POST   /posts       → PostsController#create
GET    /posts/:id   → PostsController#show
DELETE /posts/:id   → PostsController#destroy

POST   /posts/:id/nudge_score?delta=1   → PostsController#nudge_score (JSON)

POST   /posts/:post_id/comments         → CommentsController#create
GET    /posts/:post_id/comments/:id/edit→ CommentsController#edit
PATCH  /posts/:post_id/comments/:id     → CommentsController#update (Turbo-compatible)
DELETE /posts/:post_id/comments/:id     → CommentsController#destroy (Turbo-compatible)
```

### Voting endpoint example:

```bash
# Upvote (+1)
curl -X POST "/posts/123/nudge_score?delta=1"   -H "Accept: application/json"

# Downvote-like (-1)
curl -X POST "/posts/123/nudge_score?delta=-1"   -H "Accept: application/json"
```

The controller clamps delta to `[-2, 2]` and responds with `{ score: <int> }`.

## Getting started

### Prereqs
- Ruby & Bundler (use the project’s `.ruby-version` if present)
- Node & Yarn (if your JS bundling requires it)
- SQLite (dev) or PostgreSQL (optional for dev; used in prod)

### Setup

```bash
# Install Ruby gems
bundle install

# (If using JS packages)
yarn install || true

# DB setup (creates, migrates, seeds if present)
bin/rails db:setup
# or:
# bin/rails db:create db:migrate db:seed

# Run the app
bin/rails s
# Visit http://localhost:3000
```

If you’re using `bin/dev` (Procfile.dev) for Rails + Tailwind watchers, run:

```bash
bin/dev
```

### Environment variables

For production you’ll typically need:

- `RAILS_MASTER_KEY=...`
- `DATABASE_URL=...`

(Dev with SQLite generally needs no env vars.)

## Development tips

- Feed query: `PostsController#index` preloads :user and orders `created_at: :desc`.
- Post show: preloads comment users and orders comments oldest→newest.
- Turbo Streams:
  - Comment update returns `update.turbo_stream.erb` on success.
  - Comment destroy removes the comment frame and updates the comment count pill.
- Subreddits are fixed by `Post::SUBREDDITS` (adjust the list in Post as needed).

## Deployment (Render)

- Web service: Rails app.
- Database: Render PostgreSQL (free tier may sleep/reset).
- Release step: `bundle exec rails db:migrate`.
- Build step: if using the asset pipeline, run `bundle exec rails assets:precompile`.
- Set env vars in Render:
  - `RAILS_MASTER_KEY`
  - `DATABASE_URL` (provided by Render’s PostgreSQL)

Because the free DB can reset, keep seed data handy and don’t rely on persistence.

## Security & limitations

- **Auth**: No real authentication yet. A permanent signed cookie maps the browser to a demo user. Clearing cookies or session expiration creates a new demo user.
- **Permissions**: Comment edit/delete checks author equality (`comment.user == current_user`). Post delete is author-only.
- **Abuse/Spam**: Not addressed in the demo (no rate limiting / CSRF exemptions beyond Rails defaults).



## License

MIT.
