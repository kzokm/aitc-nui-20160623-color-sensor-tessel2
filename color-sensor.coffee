tessel = require 'tessel'
port = tessel.port.A

color_sensor =
  readRGB: (callback)-> callback r: 0, g: 0, b: 0

setInterval ->
  color_sensor.readRGB (data)->
    console.log data
, 1000
