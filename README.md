# YandexMoney SDK API example application

## Running example application

Fetch source code and install dependencies

```
  git clone git@github.com:yandex-money/yandex-money-sdk-ruby-sample.git
  cd yandex-money-sdk-ruby-sample
  bundle install
```

Update application configuration (`CONFIG`) in `app.rb` file.

```ruby
  # app.rb
  # To get this data, register application at https://sp-money.yandex.ru/myservices/new.xml
  CONFIG = {
    client_id: "B08E93852757D204A4FCADA4A229835D7AABD3A2B106B46ECCB245D70D73C515",
    redirect_uri: "http://127.0.0.1:4567/redirect",
  }

  # uncomment if you're using client_secret.
  CONFIG[:client_secret] =  "B21956F4A83DF4CBDB464DCB6697BF5364B3A9B036E665E0D522AD0E9A87884D0080A165D0F3BB71B48506B5DA61C822D51CF4CC587A87E4C9729908A0B0F67B"
```

Now you can run application:

```
  bundle exec ruby app.rb
```

After this visit [this](http://127.0.0.1:4567/) page in your browser.

## Documentation

Documentation for Yandex Money SDK gem you could find at [yandex-money/yandex-money-sdk-ruby](https://github.com/yandex-money/yandex-money-sdk-ruby).

## Contributing

1. Fork it ( https://github.com/yandex-money/yandex-money-sdk-ruby-sample/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
4. Write code
5. Test code
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create a new Pull Request
