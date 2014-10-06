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
  redirect_uri: "http://127.0.0.1:4567/redirect",
  client_secret: "B21956F4A83DF4CBDB464DCB6697BF5364B3A9B036E665E0D522AD0E9A87884D0080A165D0F3BB71B48506B5DA61C822D51CF4CC587A87E4C9729908A0B0F67B"
} 

get '/' do
  erb :index, locals: { token: session[:token] }
end

get '/account-info' do
  api = YandexMoney::Api.new(token: session[:token])
  result = api.account_info.to_yaml
  erb :index, locals: { result: result, token: session[:token] }
end

get '/operation-history' do
  api = YandexMoney::Api.new(token: session[:token])
  if params[:records]
    result = api.operation_history(records: params[:records].to_i).to_yaml
  else
    result = api.operation_history.to_yaml
  end
  erb :index, locals: { result: result, token: session[:token] }
end

get '/request-payment' do
  api = YandexMoney::Api.new(token: session[:token])
  result = api.request_payment(
    pattern_id: "p2p",
    to: "410011161616877",
    amount_due: "0.02",
    comment: "test payment comment from yandex-money-ruby",
    message: "test payment message from yandex-money-ruby",
    label: "testPayment"
  )
  erb :index, locals: {
    result: result.to_yaml,
    token: session[:token],
    show_process_payment: true,
    request_id: result.request_id
  }
end

get '/process-payment' do
  api = YandexMoney::Api.new(token: session[:token])
  result = api.process_payment(
    request_id: params[:request_id]
  ).to_yaml
  erb :index, locals: { result: result, token: session[:token] }
end

get '/logout' do
  session[:token] = nil
  redirect "/"
end

# OBTAINING TOKEN CODE
get '/obtain-token' do
  api = YandexMoney::Api.new(
    client_id: CONFIG[:client_id],
    redirect_uri: CONFIG[:redirect_uri],
    scope: params[:scope],
    client_secret: CONFIG[:client_secret]
  )
  redirect api.client_url
end

get '/redirect' do
  api = YandexMoney::Api.new(
    client_id: CONFIG[:client_id],
    redirect_uri: CONFIG[:redirect_uri],
    scope: params[:scope],
    client_secret: CONFIG[:client_secret]
  )
  api.code = params[:code]
  api.obtain_token
  if api.token
    session[:token] = api.token
    redirect "/"
  else
    raise 'Error obtaining token!'
  end
end
# OBTAINING TOKEN CODE
