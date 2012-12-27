# Flickr Login

## About

This gem is a simple Rack endpoint that provides Flickr authentication in your
web application. You just mount it on your web application and it does the rest of the work.

This gem is an alternative to [omniauth-flickr](https://github.com/timbreitkreutz/omniauth-flickr).
They both provide similar results, the main difference is that `flickr-login` is much more
lightweight. If you don't care about that, I would highly suggest that you go with
`omniauth-flickr`, because `omniauth` is a great standard for authentication.

If you intend to use the user's access token for communication with Flickr's
API, you'll want to use one of these 2 gems:

- [flickraw](https://github.com/hanklords/flickraw)
- [flickr-objects](https://github.com/janko-m/flickr-objects)

## Installation

Put it into your Gemfile:

```ruby
gem "flickr-login", require: "flickr/login"
```

And run `bundle install`.

## Setup

You have to be in possession of your API key and shared secret. If you don't have them yet,
you can apply for them [here](http://www.flickr.com/services/apps/create/apply).
In the setup, just replace `API_KEY` and `SHARED_SECRET` with real values.

### Rails

This is an example of how you can the gem in **Rails 3** (in Rails 2 it's probably
similar).

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # ...
    config.flickr_login = Flickr::Login.new "API_KEY", "SHARED_SECRET"
    # ...
  end
end
```
```ruby
# config/routes.rb
YourApp::Application.routes.draw do
  # ...
  flickr = YourApp::Application.config.flickr_login
  flickr_endpoint = flickr.login_handler(return_to: "/any-path")

  mount flickr_endpoint => '/login', as: :login
  # ...
end
```

### Sinatra

In Sinatra this is being put in your `config.ru`, which probably looks
something like this:

```ruby
# config.ru
require './app'
run Sinatra::Application
```

Now you mount the Rack endpoint like this

```ruby
# config.ru
require './app'
require 'flickr/login'

flickr = Flickr::Login.new "API_KEY", "SHARED_SECRET"
flickr_endpoint = flickr.login_handler(return_to: "/any-path")

use Rack::Session::Cookie
run Rack::URLMap.new "/" => Sinatra::Application,
                     "/login" => flickr_endpoint
```

That's it. Just enable sessions in your `app.rb`:

```ruby
# app.rb
enable :sessions
```

## What it does

The user will first get redirected to Flickr to approve your application. The
user is then redirected back to your app (back to the path specified with `:return_to`),
with `session[:flickr_access_token]` and `session[:flickr_user]` filled in.

- `session[:flickr_access_token]` – an array of access token and access secret
- `session[:flickr_user]` – a hash of information about the authenticated user

## Configuration

Available options for `Flickr::Login` are:

- `:return_to` – where the user is redirected to after authentication (defaults to `"/"`)
- `:site` – the API endpoint that is used (defaults to [http://www.flickr.com/services](http://www.flickr.com/services))

You can also set the permissions you're asking from the user. You do this by passing the
`perms` GET parameter in the URL. For example, going to `http://localhost:9393/login?perms=delete`
would ask the user for "delete" permissions. You can ask the user for "read", "write" or "delete" permissions.

## Helpers

The `Flickr::Login::Helpers` module adds these methods to your app:

- `#flickr_user` (Hash) – The information about the user who just authenticated
- `#flickr_access_token` (Array) – The access token and secret
- `#flickr_clear` – Erases the session that was filled after authentication, effectively logging out the user

In **Rails** you can include the module in your controller:

```ruby
# app/controllers/session_controller.rb
class SessionController < ApplicationController
  include Flickr::Login::Helpers
end
```

In **Sinatra** you can just call the `helpers` method:

```ruby
helpers Flickr::Login::Helpers
```

## Credits

This gem is almost a direct copy of **@mislav**'s [twitter-login](https://github.com/mislav/twitter-login)
and [facebook-login](https://github.com/mislav/facebook) gems.

## License

[MIT](https://github.com/janko-m/flickr-login/blob/master/LICENSE)
