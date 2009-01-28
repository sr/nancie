# Meh, I went overboard. Usage:
#
# To tweet, write in channel:
#   nancie: tweet this: some nice thing about sinatra and stuff
# To give permissions, private message:
#   /msg nancie allow awesome_user

require 'rubygems'
require 'isaac'
require 'rest_client'
require 'yaml'

module Nancie
  extend self

  attr_reader :config

  def load_config
    @config = YAML.load_file('config.yml')
  end

  def write_config
    File.open('config.yml', 'w') do |f|
      YAML.dump(@config, f)
    end
  end

  def allow!(nick)
    @config['allowed'] << nick
    write_config
  end
end

Nancie.load_config

config do |c|
  c.nick    = 'nancie'
  c.server  = 'irc.freenode.net'
end

helpers do
  def allowed?(nick)
    Nancie.config['allowed'].include?(nick)
  end
end

on :connect do
  join '#sinatra'
  msg 'nickserv', "identify #{Nancie.config['nickserv_password']}"
end

on :channel, /^nancie.*tweet this: (.*)/ do
  if allowed?(nick)
    RestClient.post "http://sinatrarb:#{Nancie.config['twitter_password']}@twitter.com/statuses/update.json", :status => match[1]
  else
    msg nick, "We're fucking ninjas! Move, bitch!"
  end
end

on :private, /^allow (\S+)/ do
  if allowed?(nick)
    Nancie.allow!(match[1])
    msg nick, "#{match[1]} has throwing stars!"
  else
    msg nick, "Lulz, where are your throwing stars?"
  end
end
