# -*- coding: utf-8 -*-

require 'net/irc'

module HipchatIrcGateway
  class IrcServer < Net::IRC::Server::Session
    def server_name
      "$HipchatIrcGateway$"
    end

    def server_version
      "0.0.0"
    end

    def initialize(server, socket, logger, opts={})
      super
    end

    def on_user(m)
      super
      @real = @opts.name || @real.split(/\s+/)

      @client = HipchatClient.new(@opts.hipchat, self)
      @client.connect
    end

    def send_privmsg(channel, nick, msg)
      post server_name, PRIVMSG, channel, "#{nick}: #{msg}"
    end

    def send_join(channel)
      post @prefix, JOIN, channel
      post server_name, MODE, channel, "+o", @prefix.nick
    end

    def on_disconnected
    end

    def on_privmsg(m)
      @client.send_message m[0], m[1]
    end

    def on_ctcp(target, message)
    end

    def on_whois(m)
    end

    def on_who(m)
    end
  end
end

