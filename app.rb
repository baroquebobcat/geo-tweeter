require 'sinatra/base'
require 'haml'
require 'active_support'
require 'sinatra-twitter-oauth'

class GeoTweeter < Sinatra::Base
  register Sinatra::TwitterOAuth
  
  set :default_location, [40.760082, -111.884841] #SLC library
  
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
  
  helpers do
    def default_location
      GeoTweeter.default_location
    end
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
    
    begin
      user.update_status(tweet[:status], tweet )
      session[:flash] = 'woot it worked!'
    rescue => e
      puts e
      session[:flash] = 'Error: guessing twitter was over capacity'
    end
    
    
    redirect '/'
  end
  
  get '/app.js' do
<<JAVASCRIPT
  var geocoder;
  var map;
  var marker;
  
  function initialize() {
    geocoder = new google.maps.Geocoder();
    
    var latlng = new google.maps.LatLng(#{default_location.join(',')});
    
    var myOptions = {
      zoom: 8,
      center: latlng,
      navigationControl: true,
      scaleControl: true,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    
    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
    
    marker = new google.maps.Marker({
      position: latlng, 
      map: map
    });
        
    google.maps.event.addListener(map, 'click', function (event) {
      marker.setPosition(event.latLng);
      
      lat = event.latLng.lat();
      lng = event.latLng.lng();
      set_form(lat,lng);

    });
    
    $("#submit_address").click(codeAddress)
  }
  
  function set_form(lat,lng) {
      lat_form = $('#tweet_lat')
      long_form = $('#tweet_long')
      
      lat_form.val(lat);
      long_form.val(lng);  
  }
  
  function codeAddress(event) {
    event.preventDefault();
    var address = $("#address").val();
    if (geocoder) {
      geocoder.geocode( { 'address': address}, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          latLng = results[0].geometry.location
          map.setCenter(latLng);
          marker.setPosition(latLng)
          set_form(latLng.lat(),latLng.lng())
          
        } else {
          alert("Geocode was not successful for the following reason: " + status);
        }
      });
    }
    return false;
  }

JAVASCRIPT
  end
  
end
