require "http"
require "tty-prompt"
require "json"
require "tty-progressbar"
require "launchy"

# Will rework to add classes and encapsulate everything after week 1 project

prompt = TTY::Prompt.new
bar = TTY::ProgressBar.new("Grabbing subreddits from the Ethereal Plane [:bar]", bar_format: :box, total: 105)
browser_bar = TTY::ProgressBar.new("Opening in your default browser, one moment [:bar]", bar_format: :arrow, total: 80)

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
puts ""
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

    posts.each_with_index do |post, index|
      post_data = post["data"]
      prompt.say("#{index + 1}. #{post_data['title']}\n", color: :bright_blue) # Post's title
      prompt.say("Posted by: u/#{post_data['author']}") # Post's Author
      prompt.say("#{post_data['ups']} upvotes") # Post's Upvotes
      prompt.say("#{post_data['num_comments']} comments.") # Post's comments
      prompt.say("#{post_data['url']}") # Post's URL
      prompt.say("" + "=" * 147)# lines for clarity
    end

    # Let user select a post using TTY-prompt

    selected_post = prompt.select("Select a post to see more details using your up and down arrow keys:", 
    posts.map { |post| post['data']['title'] })

    # This validates the selection the user made with the info from the .json array
    matching_post = posts.find { |post| post["data"]["title"] == selected_post }
    if matching_post
      selected_post_data = matching_post["data"]
      prompt.say("\nDetailed view:", color: :bright_yellow)
      prompt.say(selected_post_data["selftext"]) if selected_post_data["selftext"].to_s.length > 0
      
      # Fetch comments for the selected post
      comments_response = HTTP.headers(
        "User-Agent" => "Mac Terminal App/1.0"
      ).get("https://www.reddit.com#{selected_post_data['permalink']}.json")
      
      comments_data = comments_response.parse
      
      # Comments are in the second element of the array
      if comments_data[1] && comments_data[1]["data"]["children"]
        available_comments = comments_data[1]["data"]["children"].reject { |c| c["data"]["stickied"] }
        max_comments = available_comments.length
      
        if max_comments > 0
          comment_count = prompt.select("How many comments would you like to see?") do |menu|
            menu.choice "5 comments", 5
            menu.choice "10 comments", 10
            menu.choice "20 comments", 20
            menu.choice "All comments", max_comments
          end
          
          comments = available_comments.take(comment_count)
          
          prompt.say("\nTop #{comment_count} Comments:", color: :bright_yellow)
          comments.each do |comment|
            prompt.say("\nu/#{comment['data']['author']}", color: :bright_blue)
            prompt.say("#{comment['data']['body']}")
            prompt.say("#{comment['data']['ups']} upvotes")
            prompt.say("-" * 50)
          end
        else
          prompt.say("\nNo comments found for this post.", color: :bright_yellow)
        end
      end

      prompt.say("\nReddit URL: https://reddit.com#{selected_post_data['permalink']}")
    else
      prompt.error("Couldn't find the selected post data")
    end

    # Ask the user if they want to open the post in their browser
    if prompt.yes?("Would you like to open this post in your browser?")

      105.times do
        sleep(0.01)
        browser_bar.advance
      end

      Launchy.open("https://reddit.com#{selected_post_data['permalink']}")
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