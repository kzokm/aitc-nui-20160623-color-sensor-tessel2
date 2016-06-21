tessel = require 'tessel'

port_i2c = tessel.port.A
led_clock_pin = tessel.port.B.pin[6]
led_data_pin = tessel.port.B.pin[7]

ColorSensor = require './TCS3414'
color_sensor = new ColorSensor new port_i2c.I2C ColorSensor.I2C_ADDR

ColorLED = require './P9813'
led = new ColorLED led_clock_pin, led_data_pin

setInterval ->
  color_sensor.readRGB (data)->
    console.log data
    led.setColorRGB data.rgb
, 1000
