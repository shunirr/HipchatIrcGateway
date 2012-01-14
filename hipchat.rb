# -*- coding: utf-8 -*-

$LOAD_PATH.unshift './lib'

require 'rubygems'
require 'bundler'
Bundler.require

require 'pit'
require 'net/irc'

require 'hipchat_irc_gateway'

pit = Pit.get('hipchat_irc_gateway', :require => {
  'username' => 'YOUR USERNAME',
  'password' => 'YOUR PASSWORD',
  'nick'     => 'YOUR NICK',
  'rooms_prefix' => 'ROOMS PREFIX',
  'rooms'    => ['ROOM NAME (EXCLUDE PREFIX)'],
})

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

opts = {
  :port   => 16800,
  :host   => 'localhost',
  :logger => logger,
  :hipchat => {
    :server   => 'chat.hipchat.com',
    :jid      => "#{pit['username']}@chat.hipchat.com/bot",
    :rooms_prefix => pit['rooms_prefix'],
    :rooms    => pit['rooms'].map {|r| "#{r}@conf.hipchat.com"},
    :nick     => pit['nick'],
    :password => pit['password'],
    :debug    => logger,
  }
}

Net::IRC::Server.new(opts[:host], opts[:port], HipchatIrcGateway::IrcServer, opts).start

