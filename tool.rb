#!/usr/bin/ruby
require 'open-uri'
require 'json'
require "date"

if ARGV.empty?
  puts 'No variables given, please provide a list of summoner names to do the lookup! eg. "ruby tool.rb username1 username2 username3"'
  exit
end
###Global Variables###
api_key = 'RGAPI-070a85ab-5cca-41dc-997e-40b050d32747'

#Loop through the account names provided and grab the ID's
ARGV.each do |summoner_name|
    puts "Looking up: #{summoner_name}"
    #Get the page and print it
    api_call = open("https://euw1.api.riotgames.com/lol/summoner/v3/summoners/by-name/#{summoner_name}/?api_key=#{api_key}") or raise "Username not found or API unavailable"
    api_page = api_call.read
    api_page_json = JSON.parse(api_page)
    account_id = api_page_json['accountId']
    #puts "#{summoner_name} id is #{account_id}"
    
    api_id_call = open("https://euw1.api.riotgames.com/lol/match/v3/matchlists/by-account/#{account_id}/?api_key=#{api_key}")
    api_id_page = api_id_call.read
    api_id_page_json = JSON.parse(api_id_page)
    match_timestamp = (api_id_page_json['matches'].detect{|x| x['queue'] ==420}||{})["timestamp"].to_s[0..-4].to_i

    #puts "Last match played for #{summoner_name} was on #{match_timestamp}"

    last_date = Time.at(match_timestamp).strftime("%d/%m/%Y")

    #puts "#{last_date}"

    from = Date.parse("#{last_date}")
    to = Date.today
    difference = to.mjd - from.mjd
    puts "#{difference} days since last ranked game"
    days_till_decay = difference - 28

    if difference > 28
      puts "You are in decay"
    else
      puts "You have #{days_till_decay} days left till decay"
    end
end