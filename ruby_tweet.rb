require 'jumpstart_auth'

class MicroBlogger
  attr_reader :client

  def initialize
    @client = JumpstartAuth.twitter
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
       when 'h' then puts "t- tweet, q - quit, dm- direct message, fl - follower list, friends - list friends, spam - message to all followers, lt - everyone's last tweet, h - help"
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
      else
         puts "Unknown command #{command}. Use 'h' for help"
      end
    end
  end

end

blogger = MicroBlogger.new
blogger.run
