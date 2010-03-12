require 'sinatra/base'
require 'haml'
require 'active_support'
require 'sinatra-twitter-oauth'

class GeoTweeter < Sinatra::Base
  register Sinatra::TwitterOAuth
  
  configure do
  
    enable :methodoverride
    
    enable :logging

    set :views, File.dirname(__FILE__) + '/views'

    set :twitter_oauth_config, 
      :key      =>ENV['TWITTER_OAUTH_KEY'],
      :secret   =>ENV['TWITTER_OAUTH_SECRET'],
      :callback => ENV['TWITTER_OAUTH_CALLBACK'],
      :login_template => {:text=>'<a href="/connect">Login using Twitter</a>'}
  end
  
  get '/' do
    login_required
    haml :index
  end
  
  post '/update_status' do
    login_required
    tweet = params['tweet']
    tweet.symbolize_keys!
    
    tweet[:lat]=tweet[:lat].to_f
    tweet[:long]=tweet[:long].to_f

    user.update_status(tweet[:status], tweet )

    session[:flash] = 'woot it worked!'
    
    redirect '/'
  end
end
