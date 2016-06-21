tessel = require 'tessel'
port = tessel.port.A

ColorSensor = require './TCS3414'
color_sensor = new ColorSensor new port.I2C ColorSensor.I2C_ADDR

setInterval ->
  color_sensor.readRGB (data)->
    console.log data
, 1000
