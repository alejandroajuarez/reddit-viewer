require "http"
require "tty-prompt"
require "json"
require "tty-progressbar"

prompt = TTY::Prompt.new
bar = TTY::ProgressBar.new("Grabbing subreddits from the Etheral Plane [:bar]", bar_format: :box, total:30)

# Greeting Message
puts "Welcome to the Reddit Terminal App!"
puts "Enter the Subreddit you want to view: "
user_input = gets.chomp.downcase

# Retrival of subreddit message
puts "Please wait a moment while I retrieve posts from /r/#{user_input}"

30.times do
  sleep(0.05)
  bar.advance
end

response = HTTP.headers(
  "User-Agent" => "Mac Terminal App/1.0"
).get("https://www.reddit.com/r/#{user_input}/top.json?limit=10")

data = response.parse

puts data
