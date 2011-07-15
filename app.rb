require "digest/sha1"
require "digest/md5"

require "./helpers/login.rb"
require "./models/user.rb"
require "./models/text.rb"
require "./config/db.rb"


enable :sessions
use Rack::Flash

#login & logout
get "/" do
  if logged_in?
    redirect to "/user/#{current_user.id}"
  else
  redirect to "/login"
  end
end

get "/login" do
  erb :login
end

post "/login" do
  user = log_in(params)
  if user then
    flash[:notice] = "erfolgreich angemeldet!"
    redirect to "/user/#{user}"
  else 
    flash[:error] = "Username oder Passwort falsch!"
    redirect to "/"
  end
end


get "/logout" do
  log_out
  flash[:notice] = "erfolgreich abgemeldet!"
  redirect to "/"
end

#registrieren
get "/register" do
  erb :register
end
post "/register" do
  user = User.new
  user.email = params[:email]
  user.password = params[:password]
  
  if user.save then
    flash[:notice] = "erfolgreich registriert!"
    session[:user_id] = user.id
    redirect to "/user/#{user.id}"
  else 
    flash[:error] = "sorry, noch mal..."
    redirect to "/register"
  end
end

#user_workspace
get "/user/:id" do
  @user = User.first(:id => params[:id])
  unless logged_in?
    redirect to "/login"
  else
  erb :user_workspace
  end
end

#einzelne texte ansehen & löschen
get "/text/:id" do 
  @text = Text.get(params[:id])
  erb :text

end

delete "/text/:id" do
  unless logged_in?
  redirect to "/login"
  else
  current_user.texts.get(params[:id]).destroy
  redirect to "/user/#{current_user.id}"
  end
end

#einzelne Sätze editieren
get "/sentence/:id" do
  @sentence = Sentence.get(params[:id])
  erb :sentence
end

put "/sentence/:id/edit" do
  current_s = Sentence.get(params[:id])
  current_s.german = (params[:edit_sentence]).to_s.strip
  if current_s.save
    status 201
    redirect to "/text/#{current_s.text.id}"
  else
    status 412
    redirect to "/sentence/#{current_s.id}"
  end
end

#neuw Texte hinzufügen
post "/text/new" do
  text_array = Text.fill params[:new_text].to_s
  t = Text.create(:title => params[:text_titel])
  t.user = current_user
  text_array.each do |sentence|
    s = Sentence.new(:japanese => sentence)
    s.text = t
    s.save
  end
  redirect to "/user/#{current_user.id}"
end

#download
post "/user/:id/download" do
  user = User.first(:id => params[:id])
  texts = user.texts
  texts.map{|text| text.title + "\n" + text.sentence}
  texts = texts.join("\n")
  attachment "texts.txt"
  texts  
end  
