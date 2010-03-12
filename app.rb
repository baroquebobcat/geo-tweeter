require 'sinatra/base'

class GeoTweeter < Sinatra::Base
  register Sinatra::TwitterOAuth
  
  configure do
  
    enable :methodoverride
    
    enable :logging

    set :views, File.dirname(__FILE__) + '/views'

    set :twitter_oauth_config, 
      :key      =>ENV['TWITTER_OAUTH_KEY'],
      :secret   =>ENV['TWITTER_OAUTH_SECRET'],
      :callback => ENV['TWITTER_OAUTH_CALLBACK']
  end
  
  get '/' do
    login_required
    haml :index
  end
  
  post '/update_status' do
    login_required
    
    user.update params['tweet']
  end
end
