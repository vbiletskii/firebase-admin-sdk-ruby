# Firebase Admin Ruby SDK

The Firebase Admin Ruby SDK enables access to Firebase services from privileged environments (such as servers or cloud)
in Ruby.

For more information, visit the
[Firebase Admin SDK setup guide](https://firebase.google.com/docs/admin/setup/).

This gem is being used in production by https://cheddar.me

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'firebase-admin-sdk'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install firebase-admin-sdk

## Usage

### Application Default Credentials

```ruby
gem 'firebase-admin-sdk'

app = Firebase::Admin::App.new
```

### Using a service account

```ruby
gem 'firebase-admin-sdk'

creds = Firebase::Admin::Credentials.from_file('service_account.json')
app = Firebase::Admin::App.new(credentials: creds)
```

### Realtime Database (REST API)

This SDK includes a small wrapper around the Firebase Realtime Database REST API.
See the REST reference at https://firebase.google.com/docs/reference/rest/database/.

To use it you must provide a Realtime Database URL via `FIREBASE_CONFIG` (key: `databaseURL`)
or by constructing a `Firebase::Admin::Config` with `database_url:`.

```ruby
ENV["FIREBASE_CONFIG"] = {
  projectId: "my-project",
  databaseURL: "https://my-project-default-rtdb.firebaseio.com"
}.to_json

app = Firebase::Admin::App.new

# read
res = app.database.get("todos", query: {orderBy: "created", limitToFirst: 1})
puts res.body

# write
app.database.set("todos/first", {name: "Pick the milk"})

# push
push_res = app.database.push("todos", {name: "Pick the milk"})
puts push_res.body["name"]

# update
app.database.update("todos/first", {done: true})

# delete
app.database.delete("todos/first")

# server timestamp
app.database.set("todos/first", {createdAt: Firebase::Admin::Database::ServerValue::TIMESTAMP})
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cheddar-me/firebase-admin-sdk.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
