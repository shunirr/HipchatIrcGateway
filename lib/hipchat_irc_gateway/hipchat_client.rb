# -*- coding: utf-8 -*-

require 'xmpp4r'
require 'xmpp4r/muc/helper/simplemucclient'
require 'open-uri'
require 'cgi'
require 'json'
require 'facets'
require 'facets/random'

module HipchatIrcGateway
  class HipchatClient
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
end
