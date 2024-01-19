require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sqlite3'
require 'bcrypt'

enable :sessions



get('/') do
    slim(:"users/register")
end

get ('/login') do
    slim(:"users/login")
end