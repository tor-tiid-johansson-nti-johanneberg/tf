require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'

enable :sessions
## använd before do för att se om man är inloggad

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

get('/') do
    slim(:"login")
end

get ('/register') do
    slim(:"register")
end

post ('/login') do
    username = params[:username]
    password = params[:password]

    db = connect_to_db("db/db.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?", username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        redirect('/users/:id')
    else
        "Password is incorrect!"
    end
end

get ('/users/:id') do
    id = session[:id].to_i
    db = connect_to_db("db/db.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE id = ?", id).first
end


post ('/users/new') do

    username = params[:username]
    password = params[:password]
    confirm_password = params[:confirm_password]


    if password == confirm_password
        ## lägg till användare i databasen
        password_digest = BCrypt::Password.create(password)
        db = connect_to_db("db/db.db")
        db.execute("INSERT INTO users (username, pwdigest) VALUES (?, ?)", username, password_digest)
        redirect('/')

    else
        ## felhantering
        "Passwords don't match!"
    end
end