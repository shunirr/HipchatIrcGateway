# -*- coding: utf-8 -*-

require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
require 'open-uri'
require 'cgi'
require 'json'
require 'facets'
require 'facets/random'
require 'pit'
require 'net/irc'

class REXML::IOSource < REXML::Source
  def match(pattern, cons=false)
    rv = pattern.match(@buffer.force_encoding('utf-8'))
    @buffer = $' if cons and rv
    while !rv and @source
      begin
        @buffer << readline
        rv = pattern.match(@buffer)
        @buffer = $' if cons and rv
      rescue
        @source = nil
      end
    end
    rv.taint
    rv
  end
end

class HipChatIrcGateway < Net::IRC::Server::Session
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

    @client = HipChatClient.new($settings, self)
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

  def on_join(m)
  end

  def on_part(m)
  end
end

class HipChatClient
    attr_accessor :config, :client, :muc, :irc
    def initialize(config, irc)
        self.config = config
        self.client = Jabber::Client.new(config[:jid])
        self.muc    = Jabber::MUC::SimpleMUCClient.new(client)
        self.irc    = irc

        if Jabber.logger = config[:debug]
            Jabber.debug = true
        end

        self
    end

    def connect
        client.connect
        client.auth(config[:password])
        client.send(Jabber::Presence.new.set_type(:available))

        salutation = config[:nick].split(/\s+/).first

        muc.on_message do |time, nick, text|
          warn "#{nick}: #{text}"
          irc.send_privmsg nick, text
        end

        muc.join(config[:room] + '/' + config[:nick])

        self
    end

    def send(msg)
        muc.send Jabber::Message.new(muc.room, msg.force_encoding('utf-8'))
    end
end

config = Pit.get('hipchat_client', :require => {
    'username' => 'YOUR USERNAME',
    'password' => 'YOUR PASSWORD',
    'room'     => 'ROOM NAME',
    'nickname' => 'YOUR NICKNAME',
})

# Using resource "/bot" on the user JID prevents HipChat from sending the
# history upon channel join.
$settings = {
    :server   => 'chat.hipchat.com',
    :jid      => "#{config['username']}@chat.hipchat.com/bot",
    :nick     => config['nickname'],
    :room     => "#{config['room']}@conf.hipchat.com",
    :password => config['password'],
    :debug    => Logger.new(STDOUT),
}

if __FILE__ == $0
  require "optparse"

  opts = {
  :port   => 16800,
  :host   => "localhost",
  :debug  => true,
  :log    => STDOUT,
  }

  opts[:logger] = Logger.new(opts[:log], "daily")
  opts[:logger].level = Logger::DEBUG

  Net::IRC::Server.new(opts[:host], opts[:port], HipChatIrcGateway, opts).start
end

