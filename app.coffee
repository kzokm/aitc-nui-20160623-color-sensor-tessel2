tessel = require 'tessel'

port_i2c = tessel.port.A
led_clock_pin = tessel.port.B.pin[6]
led_data_pin = tessel.port.B.pin[7]

ColorSensor = require './TCS3414'
color_sensor = new ColorSensor new port_i2c.I2C ColorSensor.I2C_ADDRESS

LuxSensor = require './TSL2561'
lux_sensor = new LuxSensor new port_i2c.I2C LuxSensor.I2C_ADDRESS

ColorLED = require './P9813'
led = new ColorLED led_clock_pin, led_data_pin

setInterval ->
  color_sensor.readRGB (data)->
    console.log data
    led.setColorRGB data.rgb
    @latest = data

    lux_sensor.readLux (data)->
      console.log data
      @latest = data
, 1000


http = require 'http'

server = http.createServer (request, response)->
  data =
    color: color_sensor.latest
    lux: lux_sensor.latest
  console.log data
  response.writeHead 200, 'Content-Type': 'application/json'
  response.write JSON.stringify data
  response.end '\r\n'

server.listen 8080, ->
  console.log 'Server running at http://[tessel-name].local:8080/'
