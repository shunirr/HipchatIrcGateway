# -*- coding: utf-8 -*-

require 'net/irc'

module HipchatIrcGateway
  class IrcServer < Net::IRC::Server::Session
    def server_name
      "HipChat"
    end

    def server_version
      "0.0.0"
    end

    def main_channel
      "#hcig"
    end

    def initialize(*args)
      super
    end

    def on_user(m)
      super
      post @prefix, JOIN, main_channel
      post server_name, MODE, main_channel, "+o", @prefix.nick

      @real, *@opts = @opts.name || @real.split(/\s+/)
      @opts ||= []

      @client = HipchatClient.new($settings, self)
      @client.connect
    end

    def send_privmsg(nick, msg)
      post server_name, PRIVMSG, main_channel, "#{nick}: #{msg}"
    end

    def on_disconnected
    end

    def on_privmsg(m)
      puts "#{m[0]}: #{m[1]}"
      @client.send m[1] 
    end

    def on_ctcp(target, message)
    end

    def on_whois(m)
    end

    def on_who(m)
    end
  end
end
