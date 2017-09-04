require 'sinatra'
require 'yandex_money/api'
require 'yaml'

# Enable sessions for storing token safely
enable :sessions

# Change this for your application (http://www.sinatrarb.com/intro.html#Using%20Sessions)
set :session_secret, 'mysupersecret'

# To get this data, register application at https://sp-money.yandex.ru/myservices/new.xml
CONFIG = {
  client_id: "B08E93852757D204A4FCADA4A229835D7AABD3A2B106B46ECCB245D70D73C515",
  redirect_uri: "http://127.0.0.1:4567/redirect"
}

# uncomment if you're using client_secret.
CONFIG[:client_secret] =  "B21956F4A83DF4CBDB464DCB6697BF5364B3A9B036E665E0D522AD0E9A87884D0080A165D0F3BB71B48506B5DA61C822D51CF4CC587A87E4C9729908A0B0F67B"

get '/' do
  erb :index, locals: { token: session[:token] }
end

get '/account-info' do
  api = YandexMoney::Wallet.new(session[:token])
  result = api.account_info.to_yaml
  erb :index, locals: { result: result, token: session[:token] }
end

get '/operation-history' do
  api = YandexMoney::Wallet.new(session[:token])
  result = api.operation_history.to_yaml
  erb :index, locals: { result: result, token: session[:token] }
end

get '/request-payment' do
  api = YandexMoney::Wallet.new(session[:token])
  request_options = {
    pattern_id: "p2p",
    to: "410011161616877",
    amount_due: "0.02",
    comment: "test payment comment from yandex-money-ruby",
    message: "test payment message from yandex-money-ruby",
    label: "testPayment"
  }

  request_options.merge!(test_payment: true, test_result: :success) if params[:test] == 'true'
  request_result = api.request_payment(request_options)

  erb :index, locals: {
    result: request_result.to_yaml,
    token: session[:token],
    show_process_payment: true,
    request_id: request_result.request_id,
    amount: request_options[:amount_due]
  }
end

get '/request-payment-megafon' do
  api = YandexMoney::Wallet.new(session[:token])
  amount = "2"
  request_options = {
    pattern_id: "337",
    sum: amount,
    PROPERTY1: "921",
    PROPERTY2: "3020052",
    comment: "test payment comment from yandex-money-ruby",
    message: "test payment message from yandex-money-ruby",
    label: "testPayment"
  }
  request_result = api.request_payment(request_options)
  erb :index, locals: {
    result: request_result.to_yaml,
    token: session[:token],
    show_process_payment: true,
    request_id: request_result.request_id,
    amount: amount
  }
end

get '/process-payment' do
  api = YandexMoney::Wallet.new(session[:token])
  process_payment = api.process_payment({
    request_id: params[:request_id],
  })

  erb :index, locals: { result: process_payment.to_yaml, token: session[:token] }
end

get '/logout' do
  session[:token] = nil
  redirect "/"
end

# OBTAINING TOKEN CODE
get '/obtain-token' do
  auth_url = YandexMoney::Wallet.build_obtain_token_url(
    CONFIG[:client_id],
    CONFIG[:redirect_uri],
    params[:scope] # SCOPE
  )
  redirect auth_url
end

get '/redirect' do
  access_token = YandexMoney::Wallet.get_access_token(
    CONFIG[:client_id],
    params[:code],
    CONFIG[:redirect_uri]
  )

  if access_token
    session[:token] = access_token
    redirect "/"
  else
    raise 'Error obtaining token!'
  end
end
