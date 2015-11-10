require 'jumpstart_auth'
require 'bitly'
require 'klout'


class MicroBlogger
  attr_reader :client
  attr_reader :bitly

  def initialize
    @client = JumpstartAuth.twitter

    Bitly.use_api_version_3
    @bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')

    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'


  end

  def tweet(message)
     if message.length <= 140
       @client.update(message)
     else
       puts "Tweet too long. Tweets are limited to 140 characters or less."
     end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message
    message = "d @#{target} #{message}"
    tweet(message)
  end

  def followers_list
    @client.followers.collect { |follower| @client.user(follower).screen_name }
  end

  def spam_my_followers(my_followers, message)
    print "spamming '#{message}' to your followers...\n"
    my_followers.each do |follower|
	dm(follower, message)
    end
  end


  def friends_list
    @client.friends.collect { |friend| @client.user(friend) }
  end

  def list_friends
    friends_list.each { |friend| print "#{friend.screen_name}\n"}
  end


  def everyones_last_tweet
    friends = friends_list.sort_by { |friend| friend.screen_name.downcase  }
    print "\nList of friends:\n"
    friends.each { |friend| print "#{friend.screen_name}\n" }

    print "\nRetrieving last tweets of all friends...\n\n"
    friends.each do |friend|
    print "#{friend.name} (#{friend.screen_name}): #{friend.status.text}. Created #{friend.status.created_at.strftime("%A, %b %d")}\n\n" 
    end
  end

  def shorten(original_url)
    @bitly.shorten(original_url).short_url
  end


  def klout_score
    friends = friends_list.sort_by { |friend| friend.screen_name.downcase  }
    print "\nList of friends:\n"
    friends.each { |friend| print "#{friend.screen_name}\n" }

    print "\nRetrieving Klout scores of all friends...\n\n"
    friends.each do |friend|
      identity = Klout::Identity.find_by_screen_name(friend.screen_name)
      user = Klout::User.new(identity.id)
      print "#{friend.name} (#{friend.screen_name}): #{user.score.score}\n\n" 
    end
  end




  def run
    puts "Twitter interface via API."
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
       when 'q' then puts "Goodbye!"
       when 'h' then puts "t- tweet, q - quit, dm- direct message, fl - follower list, friends - list friends, spam - message to all followers, lt - everyone's last tweet, turl - tweet with shortened url, s - shorten url using bitly, ks - klout score of all friends, h - help"
       when 't' then tweet(parts[1..-1].join(" "))
       when 'dm' then
	screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
	if screen_names.include?(parts[1])
	  dm(parts[1], parts[2..-1].join(" "))
	else
	  print "Error: Unable to tweet to non-follower username '#{parts[1]}'\n"
	end
       when 'fl' then
	 print "followers = #{followers_list}\n"
       when 'spam'
	  spam_my_followers(followers_list, parts[1..-1].join(" "))
       when 'lt' then everyones_last_tweet
       when 'friends' then list_friends
       when 's' then
          puts "Shortening this URL: #{parts[-1]}\n"
	  print "#{shorten(parts[-1])}\n"
       when 'turl'
          puts "Shortening this URL: #{parts[-1]}\n"
	  tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]) )
       when 'ks' then klout_score
       else
         puts "Unknown command #{command}. Use 'h' for help"
      end
    end
  end

end

blogger = MicroBlogger.new
blogger.run
