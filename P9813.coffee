
class P9813
  constructor: (@clk_pin, @data_pin, @number_of_leds = 1)->
    @led_colors = []
    @setColorRGB 0, red: 0, green: 0, blue: 0
    return

  setColorRGB: (color, position = 0)->
    @led_colors[position] =
      red: constrain Math.round color.red, 0, 255
      green: constrain Math.round color.green, 0, 255
      blue: constrain Math.round color.blue, 0, 255

    send.call @, [0, 0, 0, 0]
    for i in [0..@number_of_leds] by 1
      sendColor.call @, @led_colors[i]
    send.call @, [0, 0, 0, 0]

  setColorHSB: (color, position)->
    h = constrain color.hue, 0.0, 1.0
    s = constrain color.saturation, 0.0, 1.0
    v = constrain color.brightness, 0.0, 1.0

    r = g = b = v
    if s > 0.0
      h *= 6.0
      i = Math.floor h
      f = h - i * 6
      switch i
        when 0
          g *= 1.0 - s * (1.0 - f)
          b *= 1.0 - s
        when 1
          r *= 1.0 - s * f
          b *= 1.0 - s
        when 2
          r *= 1.0 - s
          b *= 1.0 - s * (1.0 - f)
        when 3
          r *= 1.0 - s
          g *= 1.0 - s * f
        when 4
          r *= 1.0 - s * (1.0 - f)
          g *= 1.0 - s
        when 5
          g *= 1.0 - s
          b *= 1.0 - s * f

    setColorRGB
      red: Math.round r * 255
      green: Math.round g * 255
      blue: Math.round b * 255
    , position

  constrain = (value, min, max)->
    value ?= min
    switch
      when value < min then min
      when value > max then max
      else value


  HIGH = 1
  LOW = 0
  CLK_PULSE_DELAY = 20

  delay = (μs)->
    for mi in [0...μs] by 1
      for i in [0...11] by 1 # expect 1 micro-second
        i
    return

  send = (data)->
    for byte in data
      for i in [1..8]
        @data_pin.output if byte & 0x80 then HIGH else LOW # write MSB
        byte <<= 1 # next bit

        @clk_pin.output LOW
        delay CLK_PULSE_DELAY
        @clk_pin.output HIGH
        delay CLK_PULSE_DELAY
    return

  sendColor = (color = {})->
    blue = color.blue ? 0
    green = color.green ? 0
    red = color.red ? 0

    prefix = 0xC0
    prefix |= 0x20 if (blue & 0x80) == 0
    prefix |= 0x10 if (blue & 0x40) == 0
    prefix |= 0x08 if (green & 0x80) == 0
    prefix |= 0x04 if (green & 0x40) == 0
    prefix |= 0x02 if (red & 0x80) == 0
    prefix |= 0x01 if (red & 0x40) == 0

    send.call @, [prefix, blue, green, red]

module.exports = P9813
