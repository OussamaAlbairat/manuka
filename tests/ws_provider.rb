require 'json'
require 'rubygems'
require 'bundler/setup'
require 'faye/websocket'
require 'eventmachine'

  EM.run {


      reg_msg = {type: "register",
                 content: [{token: "123"}]}.to_json
      disp_msg = {type: "dispatch",
                  content: [{token: "123", data: "test message."}]}.to_json

      p "starting"

      url = "ws://localhost:8082/"

      ws = Faye::WebSocket::Client.new(url, nil, {})

      ws.onopen = lambda do |event|
        p [:open, ws.headers]
	ws.send(reg_msg)
        timer = EventMachine::PeriodicTimer.new(10) do
                        p "sending :#{disp_msg}"
                        ws.send(disp_msg)
                end
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


