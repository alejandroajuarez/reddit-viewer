require "http"
require "tty-prompt"
require "json"
require "tty-progressbar"

prompt = TTY::Prompt.new
bar = TTY::ProgressBar.new("Grabbing subreddits from the Ethereal Plane [:bar]", bar_format: :box, total:105)

# Greeting Message
welcome_banner = <<-'ASCII'
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗    ████████╗ ██████╗     ████████╗██╗  ██╗███████╗                                //
// ██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝    ╚══██╔══╝██╔═══██╗    ╚══██╔══╝██║  ██║██╔════╝                                //
// ██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗         ██║   ██║   ██║       ██║   ███████║█████╗                                  //
// ██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝         ██║   ██║   ██║       ██║   ██╔══██║██╔══╝                                  //
// ╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗       ██║   ╚██████╔╝       ██║   ██║  ██║███████╗                                //
//  ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝       ╚═╝    ╚═════╝        ╚═╝   ╚═╝  ╚═╝╚══════╝                                //
// ██████╗ ███████╗██████╗ ██████╗ ██╗████████╗    ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗          █████╗ ██████╗ ██████╗ ██╗ //
// ██╔══██╗██╔════╝██╔══██╗██╔══██╗██║╚══██╔══╝    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║         ██╔══██╗██╔══██╗██╔══██╗██║ //
// ██████╔╝█████╗  ██║  ██║██║  ██║██║   ██║          ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║         ███████║██████╔╝██████╔╝██║ //
// ██╔══██╗██╔══╝  ██║  ██║██║  ██║██║   ██║          ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║         ██╔══██║██╔═══╝ ██╔═══╝ ╚═╝ //
// ██║  ██║███████╗██████╔╝██████╔╝██║   ██║          ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗    ██║  ██║██║     ██║     ██╗ //
// ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═════╝ ╚═╝   ╚═╝          ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝ //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
ASCII

puts welcome_banner
user_input = prompt.ask("Enter the Subreddit you want to view: ") do |q|
  q.required true
  q.modify   :down
end

# Retrival of subreddit message
puts "Please wait a moment while I retrieve posts from /r/#{user_input}"

# Progress bar
105.times do
  sleep(0.01)
  bar.advance
end

# Headers method to call redit .json API
begin
  response = HTTP.headers(
    "User-Agent" => "Mac Terminal App/1.0"
  ).get("https://www.reddit.com/r/#{user_input}/top.json?limit=10")

  data = response.parse

# Exception Handling 

  raise RuntimeError, "Subreddit 'r/#{user_input}/' not found" if response.code == 404
  raise RuntimeError, "Subreddit 'r/#{user_input}/' is private" if response.code == 403
  raise RuntimeError, "Rate limit exceeded" if response.code == 429
  raise RuntimeError, "Reddit API error" unless response.status.success?
  raise RuntimeError, "Empty subreddit" if data["data"]["children"].empty?

# Process and display posts

  if data["data"] && data["data"]["children"]
    posts = data["data"]["children"]
  
    posts.each_with_index do |data, index|

    end
  end
# Exception handling
rescue HTTP::ConnectionError
  prompt.error("Cannot connect to Reddit. Please check your internet connection.")
  exit

rescue HTTP::TimeoutError
  prompt.error("Request timed out. Please try again.")
  exit

rescue HTTP::ResponseError => e
  case e.response.code
  when 404
    prompt.error("Subreddit 'r/#{user_input}/' not found.")
  when 403
    prompt.error("This subreddit is private or quarantined.")
  when 429
    prompt.error("Too many requests. Please wait a moment and try again.")
  else
    prompt.error("An error occurred while accessing Reddit: #{e.message}")
  end
  exit

rescue RuntimeError => e
  prompt.error(e.message)
  exit

rescue StandardError => e
  prompt.error("An unexpected error occurred: #{e.message}")
  exit
end