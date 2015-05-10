require 'json'
require 'rubygems'
require 'bundler/setup'
require 'faye/websocket'
require 'eventmachine'
require 'timers'

  EM.run {

      timers = Timers::Group.new
      sub_msg = {type: "subscribe",
                 content: [{token: "123"}]}.to_json

      p "starting"

      url = "ws://localhost:8082/"

      ws = Faye::WebSocket::Client.new(url, nil, {})

      ws.onopen = lambda do |event|
        p [:open, ws.headers]
	ws.send(sub_msg)
      end

      ws.onclose = lambda do |close|
        p [:close, close.code, close.reason]
        EM.stop
      end

      ws.onerror = lambda do |error|
        p [:error, error.message]
      end

      ws.onmessage = lambda do |message|
        p [:message, message.data]
        #EM.stop
        #ws.send(msg)
        #ws.send(msg) if count < 5 #message.data && message.data.include?("stop")
      end

  }


