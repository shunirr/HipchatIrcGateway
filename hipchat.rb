# -*- coding: utf-8 -*-

$LOAD_PATH.unshift './lib'

require 'rubygems'
require 'bundler'
Bundler.require

require 'pit'
require 'net/irc'
require "optparse"

require 'hipchat_irc_gateway'

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

opts = {
  :port   => 16800,
  :host   => "localhost",
  :debug  => true,
  :log    => STDOUT,
}

opts[:logger] = Logger.new(opts[:log], "daily")
opts[:logger].level = Logger::DEBUG

Net::IRC::Server.new(opts[:host], opts[:port], HipchatIrcGateway::IrcServer, opts).start

