#!/usr/bin/ruby
require 'open-uri'
require 'json'
require "date"
require 'net/smtp'

def callapi(uri)
    open(uri)
  rescue => exception
    puts "Summoner cannot be found on EUW"
    exit 1
end

def send_email(to,opts={})
  opts[:server]      ||= 'localhost'
  opts[:from]        ||= 'pudgey@localhost'
  opts[:from_alias]  ||= 'Decay Bot'
  opts[:subject]     ||= "Your decay status"
  opts[:body]        ||= ""

  msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE

  Net::SMTP.start(opts[:server]) do |smtp|
    smtp.send_message msg, opts[:from], to
  end
end


if ARGV.empty?
  puts 'No usernames given, please provide a list of summoner names to do the lookup! eg. "ruby tool.rb username1 username2 username3"'
  exit
end
api_key = 'RGAPI-070a85ab-5cca-41dc-997e-40b050d32747'

ARGV.each do |summoner_name|
    puts "Looking up: #{summoner_name}"

    api_call = callapi("https://euw1.api.riotgames.com/lol/summoner/v3/summoners/by-name/#{summoner_name}/?api_key=#{api_key}")
    api_page = api_call.read
    api_page_json = JSON.parse(api_page)
    account_id = api_page_json['accountId']
    
    api_id_call = open("https://euw1.api.riotgames.com/lol/match/v3/matchlists/by-account/#{account_id}/?api_key=#{api_key}")
    api_id_page = api_id_call.read
    api_id_page_json = JSON.parse(api_id_page)
    match_timestamp = (api_id_page_json['matches'].detect{|x| x['queue'] ==420}||{})["timestamp"].to_s[0..-4].to_i


    last_date = Time.at(match_timestamp).strftime("%d/%m/%Y")


    from = Date.parse("#{last_date}")
    to = Date.today
    difference = to.mjd - from.mjd
    puts "#{difference} days since last ranked game"
    days_till_decay = difference - 28

    if difference > 28
      puts "You are in decay"
    elsif days_till_decay < 10
      puts "You have less then 10 days till decay"
    else
      puts "You have #{days_till_decay} days left till decay"
    end

  #send_email "#{email_address}", :body => "You have #{days_till_decay} till you decay"
end