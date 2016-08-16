# Description
#   Hubot MQTT bridge
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Ronny Stauffer <ronny.stauffer@wir-entwickeln.ch>

mqtt = require('mqtt')

#mqttUrl = 'mqtt://localhost'
mqttUrl = 'mqtt://m21.cloudmqtt.com:17429'
mqttOptions =
  protocolId: 'MQIsdp'
  protocolVersion: 3
#  host: 'localhost'
  host: 'm21.cloudmqtt.com'
#  port: 1883
  port: 17429
  username: 'varda'
  password: new Buffer('varda')
# block comment out the rest of thes if no tls
#  ca: TRUSTED_CA_LIST
#  rejectUnauthorized: true
# block comment out the rest of these if no client_cert auth
#  protocol: 'mqtts'
#  secureProtocol: 'TLSv1_method'
#  key: KEY
#  cert: CERT
#  ciphers: 'ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-RSA-RC4-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES128-SHA:AES256-SHA256:AES256-SHA:RC4-SHA:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!EDH'

mqttClient = mqtt.connect(mqttUrl, mqttOptions)

mqttClient.on 'connect', ->
  console.log "Connected to MQTT broker (v2)."

mqttClient.subscribe('hubot-outbound')

module.exports = (robot) ->
  # Tests

  robot.respond /hello/, (res) ->
    res.reply "hello!"

  robot.hear /orly/, (res) ->
    res.send "yarly"

  robot.respond /keyboard/i, (res) ->
    res.envelope.telegram = { reply_markup: { keyboard: [ [ "option1", "option2" ] ] } }
    res.reply "Select the option from the keyboard specified."

  robot.respond /ask me/i, (res) ->
    res.envelope.telegram = { reply_markup: { keyboard: [ [ "answer1", "answer2" ] ] } }
    res.reply "What is your answer?"

  robot.hear /keyword/i, (req) ->
    req.envelope.telegram = { reply_markup: { keyboard: [ [ "Yes", "No" ] ] } }
    req.send "I heard the keyword, am I right?"

  # Utilities

  robot.respond /show room/, (res) ->
    res.reply "The room's ID is #{res.message.room}."

  # MQTT Bridging

  robot.respond /(.*)/i, (res) ->
    mqttClient.publish('hubot-inbound', res.match[1])

  mqttClient.on('message', (topic, message) ->
    robot.messageRoom('-146056206', "#{message}") # room: shir-khan-test  # [#{topic}]
  )