# -*- coding: utf-8 -*-

require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
require 'open-uri'
require 'cgi'
require 'json'

module HipchatIrcGateway
  class HipchatClient
    def initialize(config, irc)
      @config = config
      @client = Jabber::Client.new(@config[:jid])
      @irc = irc
      @mucs = {}
      @config[:rooms].each do |room|
        room = "#{@config[:rooms_prefix]}_#{room}"
        @mucs[room] = Jabber::MUC::SimpleMUCClient.new(@client)
        @irc.send_join room2channel(room)
      end

      if Jabber.logger = config[:debug]
        Jabber.debug = true
      end

      self
    end

    def connect
      @client.connect
      @client.auth(@config[:password])
      @client.send(Jabber::Presence.new.set_type(:available))

      @mucs.each do |room, muc|
        muc.on_message do |time, nick, text|
          #next if nick == @config[:nick]
          warn "#{room}: #{nick}: #{text}"
          @irc.send_privmsg room2channel(room), nick, text
        end
        muc.join(room + '/' + @config[:nick])
      end

      self
    end
    
    def send_message(room, msg)
      msg  = msg.force_encoding('utf-8')
      room = channel2room(room).force_encoding('utf-8')

      muc = @mucs[room]
      muc.send Jabber::Message.new(room, msg)
    end

    private
    def room2channel(room)
      "##{room.match(/^[^_]+_([^@]+)/)[1]}"
    end

    def channel2room(channel)
      "#{@config[:rooms_prefix]}_#{channel.sub('#', '')}@conf.hipchat.com"
    end
  end

end

