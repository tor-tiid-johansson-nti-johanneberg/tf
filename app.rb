require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/flash' ## popups

require_relative './model.rb'

enable :sessions
## använd before do för att se om man är inloggad

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

get('/') do
    slim(:"start")
end

get ('/users/login') do
    slim(:"users/login")
end

get ('/users/register') do
    slim(:"users/register")
end

get ('/users/index') do
    slim(:"users/index")
end

get ('/adverts') do
    slim(:"adverts/index")
end

post ('/users/login') do
    username = params[:username]
    password = params[:password]

    db = connect_to_db("db/db.db")
    result = db.execute("SELECT * FROM users WHERE username = ?", username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        slim(:"users/index", locals: {users:result, username:username})
    else
        flash[:error] = "Wrong username or password"
        redirect('/users/login')
    end
end

get ('/users/:id') do
    id = session[:id].to_i
    db = connect_to_db("db/db.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE id = ?", id).first
end


post ('/users/new') do

    db = connect_to_db("db/db.db")

    username = params[:username]
    password = params[:password]
    confirm_password = params[:confirm_password]

    ## kolla om användarnamnet redan finns, måste vara unikt
    if db.execute("SELECT * FROM users WHERE username = ?", username).empty?
        if password == confirm_password
            ## lägg till användare i databasen
            password_digest = BCrypt::Password.create(password)
            db = connect_to_db("db/db.db")
            db.execute("INSERT INTO users (username, pwdigest) VALUES (?, ?)", username, password_digest)
            flash[:success] = "User created successfully!"
            redirect('/')
    
        else
            ## felhantering
            flash[:error] = "Passwords do not match"
            redirect('/users/register')
        end
    else
        ## felhantering
        flash[:error] = "Username already exists"
        redirect('/users/register')
    end

    
end