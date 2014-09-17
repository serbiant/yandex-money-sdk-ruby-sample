require 'sinatra'
require 'yandex_money/api'
require 'yaml'

# To get this data, register application at https://sp-money.yandex.ru/myservices/new.xml
CONFIG = {
  client_id: "PROVIDE_CLIENT_ID_HERE",
  redirect_uri: "http://127.0.0.1:4567/redirect",
  client_secret: "PROVIDE_CLIENT_SECRET_HERE"
} 

get '/' do
  erb :index, locals: { token: params[:token] }
end

get '/account-info' do
  api = YandexMoney::Api.new(token: params[:token])
  result = api.account_info.to_yaml
  erb :index, locals: { result: result, token: params[:token] }
end

get '/operation-history' do
  api = YandexMoney::Api.new(token: params[:token])
  if params[:records]
    result = api.operation_history(records: params[:records].to_i).to_yaml
  else
    result = api.operation_history.to_yaml
  end
  erb :index, locals: { result: result, token: params[:token] }
end

get '/request-payment' do
  api = YandexMoney::Api.new(token: params[:token])
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
    token: params[:token],
    show_process_payment: true,
    request_id: result.request_id
  }
end

get '/process-payment' do
  api = YandexMoney::Api.new(token: params[:token])
  result = api.process_payment(
    request_id: params[:request_id]
  ).to_yaml
  erb :index, locals: { result: result, token: params[:token] }
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
    redirect "/?token=#{api.token}"
  else
    raise 'Error obtaining token!'
  end
end
# OBTAINING TOKEN CODE
