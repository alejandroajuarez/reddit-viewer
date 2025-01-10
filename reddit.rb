require "http"
require "tty-prompt"
require "json"

prompt = TTY::Prompt.new

puts "Welcome to the Reddit Terminal App!"
puts "Enter the Subreddit you want to view: "
user_input = gets.chomp

response = HTTP.get("https://www.reddit.com/.json#{user_input}")
data = response.parse

# pp reddit_data