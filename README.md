[![Gem Version](https://badge.fury.io/rb/omniauth-meli.svg)](https://badge.fury.io/rb/omniauth-meli)

# OmniAuth Mercado Livre Strategy

Strategy to authenticate with Mercado Livre via OAuth2 in OmniAuth.

Get your APP ID and SECRET key at: https://developers.mercadolivre.com.br/devcenter  Note the Client ID and the Client Secret.

For more details, read the Meli docs: https://developers.mercadolivre.com.br/pt_br/autenticacao-e-autorizacao

## Installation

Add to your `Gemfile`:

```ruby
gem 'omniauth-meli', '~> 0.1.3'
```

Then `bundle install`.

## Mercado Livre Setup

* Go to Developer Center: https://developers.mercadolivre.com.br/devcenter
* Select your app for edit.
* Go to edit, then copy the secret and client id, as 'ID do Aplicativo' and 'Chave Secreta'.

## Usage

Here's an example for adding the middleware to a Rails app in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :meli, ENV['MELI_CLIENT'], ENV['MELI_SECRET']
end
OmniAuth.config.allowed_request_methods = %i[get]
```

You can now access the OmniAuth Meli URL: `/auth/meli`

## Usage with Devise

First define your application id and secret in `config/initializers/devise.rb`.

```ruby
config.omniauth :meli, ENV.fetch('MELI_CLIENT'), ENV.fetch('MELI_SECRET')
```

Then add the following to 'config/routes.rb' so the callback routes are defined.

```ruby
devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
```

Make sure your model is omniauthable. Generally this is "/app/models/user.rb"

```ruby
devise :omniauthable, omniauth_providers: [:meli]
```

Then make sure your callbacks controller is setup.

```ruby
# app/controllers/users/omniauth_callbacks_controller.rb:

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def meli
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Meli'
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.meli_data'] = request.env['omniauth.auth'].except('extra') # Removing extra as it can overflow some session stores
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
  end
end
```

and bind to or create the user

```ruby
def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
    # unless user
    #     user = User.create(name: data['name'],
    #        email: data['email'],
    #        password: Devise.friendly_token[0,20]
    #     )
    # end
    user
end
```

For your views you can login using:

```erb
<%# omniauth-meli 1.0.x uses OmniAuth 2 and requires using HTTP Post to initiate authentication: %>
<%= link_to "Sign in with Mercado Livre", user_meli_omniauth_authorize_path, method: :post %>
```

If you're using Rails 7 with turbo, you can use the following:

```erb
<%= link_to "Sign in with Mercado Livre", user_meli_omniauth_authorize_path, method: :post, data: { turbo: false } %>
```
## Auth Hash

Here's an example of an authentication hash available in the callback by accessing `request.env['omniauth.auth']`:

```json
{
  "provider": "meli",
  "uid": "12312312323231",
  "info": {
    "nickname": "LOJINHA",
    "email": "elton@elton.com",
    "first_name": "Ze",
    "last_name": "Coveiro",
    "url": "http://perfil.mercadolivre.com.br/perfil",
    "name": "Coveiro Ze"
  },
  "credentials": {
    "token": "APP_USR-xxx",
    "refresh_token": "TG-xxx",
    "expires_at": 1709884647,
    "expires": true
  },
  "extra": {
    "access_token": {
      "token_type": "Bearer",
      "scope": "offline_access read write",
      "user_id": 1232131,
      "access_token": "APP_USR-xxx",
      "refresh_token": "TG-xxxx",
      "expires_at": 1709884647
    },
    "raw_info": {
      "id": 23132313231,
      "nickname": "Loja",
      "registration_date": "2023-10-23T15:35:24.270-04:00",
      "first_name": "Ze",
      "last_name": "das coves",
      "country_id": "BR",
      "email": "elton@elton.com",
      "identification": {
        "number": "23123112311",
        "type": "CNPJ"
      },
      "address": {
        "address": "Rua das saladas",
        "city": "Rio de Janeiro",
        "state": "BR-RJ",
        "zip_code": "000000"
      },
      "phone": {
        "verified": false
      },
      "user_type": "normal",
      "tags": [
        "eshop",
        "messages_as_seller",
        "normal"
      ],
      "points": 3,
      "site_id": "MLB",
      "permalink": "http://perfil.mercadolivre.com.br/perfil",
      "seller_experience": "novo",
      "seller_reputation": {
        "level_id": "5_green",
        "power_seller_status": "platinum",
        "transactions": {
          "canceled": 0,
          "completed": 23400,
          "period": "historic",
          "ratings": {
            "negative": 0.0,
            "neutral": 0,
            "positive": 1
          },
          "total": 23400
        }
      },
      "buyer_reputation": {
        "canceled_transactions": 0
      },
      "status": {
        "billing": {
          "allow": true
        },
        "buy": {
          "allow": true,
          "immediate_payment": {
            "required": false
          }
        },
        "confirmed_email": true,
        "shopping_cart": {
          "buy": "allowed",
          "sell": "allowed"
        },
        "immediate_payment": false,
        "list": {
          "allow": true,
          "immediate_payment": {
            "required": false
          }
        },
        "mercadoenvios": "not_accepted",
        "mercadopago_account_type": "personal",
        "mercadopago_tc_accepted": true,
        "sell": {
          "allow": true,
          "immediate_payment": {
            "required": false
          }
        },
        "site_status": "active",
        "restrictions_coliving": {
          "verification_status": "DOK"
        }
      }
    }
  }
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
6. If you have any questions, suggestions or problems, please open an issue.

## License

Copyright (c) 2024 by Elton Fonseca

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
