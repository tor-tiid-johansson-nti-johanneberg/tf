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
    slim(:"users/login")
end

get ('/login') do
    slim(:"users/register")
end