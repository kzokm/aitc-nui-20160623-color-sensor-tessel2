
class TCS3414
  constructor: (@i2c)->
    @setGain()
    @enableADC()

  enableADC: ()->
    tx = new Buffer [TCS3414.REG_CONTROL, TCS3414.CTL_DAT_INIITIATE]
    @i2c.send tx

  setTiming: (data = TCS3414.INTEG_MODE_FREE | TCS3414.PARAM_NOMINAL_INTEGRATION_TIME_12ms)->
    tx = new Buffer [TCS3414.REG_TIMING, data]
    @i2c.send tx

  setGain: (data = TCS3414.GAIN_1 | TCS3414.PRESCALER_1)->
    tx = new Buffer [TCS3414.REG_GAIN, data]
    @i2c.send tx

  setInterrupt: (data = TCS3414.INTR_LEVEL | TCS3414.PERSIST_EVERY)->
    tx = new Buffer [TCS3414.REG_INTERRUPT, data]
    @i2c.send tx

  clearInterrupt: ()->
    tx = new Buffer [TCS3414.CMD_INTERRUPT_CLEAR]
    @i2c.send tx

  setInterruptSource: (data = TCS3414.INT_SOURCE_CLEAR)->
    tx = new Buffer [TCS3414.REG_INT_SOURCE, data]
    @i2c.send tx

  readRGB: (callback, is_enabled_led = false)->
    tx = new Buffer [TCS3414.REG_BLOCK_READ]
    @i2c.transfer tx, 8, (err, rx)->
      throw err if err
      raw =
        green: g = rx[1] * 256 + rx[0]
        red: r = rx[3] * 256 + rx[2]
        blue: b = rx[5] * 256 + rx[4]
        clear: rx[7] * 256 + rx[6]

      r *= 0.05
      g *= 0.05
      b *= 0.05

      if is_enabled_led
        r *= 1.7
        b *= 1.35

      max = Math.max r, g, b
      if max > 255
        scale = 255.0 / max
        r *= scale
        g *= scale
        b *= scale

      if false and is_enabled_led
        max = Math.max r, g, b
        min = Math.min r, g, b
        is_orange = max == r and g >= 2 * b and g >= 0.2 * r
        is_pink = max == r and g <= b and b >= 0.2 * r

        if r < 0.6 * max
          r *= 0.2
        else if r < 0.8 * max
          r *= 0.4

        if g < 0.6 * max
          unless is_orange
            g *= 0.2
        else if g < 0.8 * max
          g *= 0.4

        if b < 0.6 * max
          if is_orange
            b *= 0.5
          unless is_pink
            b *= 0.2
        else if b < 0.8 * max
          b *= 0.4

        min = Math.min r, g, b
        is_yellow = max == g and r >= 0.85 * max and min == b
        if is_yellow
          r = max
          b *= 0.4

      callback
        raw: raw
        rgb:
          red: Math.round r
          green: Math.round g
          blue: Math.round b

  # the I2C address for the color sensor
  @I2C_ADDRESS = 0x39

  @REG_CONTROL = 0x80
  @REG_TIMING = 0x81
  @REG_INTERRUPT = 0x82
  @REG_INT_SOURCE = 0x83
  @REG_ID = 0x84
  @REG_GAIN = 0x87
  @REG_LOW_THRESH_LOW_BYTE = 0x88
  @REG_LOW_THRESH_HIGH_BYTE = 0x89
  @REG_HIGH_THRESH_LOW_BYTE = 0x8A
  @REG_HIGH_THRESH_HIGH_BYTE = 0x8B
  # The REG_BLOCK_READ and REG_GREEN_LOW direction are the same
  @REG_BLOCK_READ = 0xCF
  @REG_GREEN_LOW = 0x90
  @REG_GREEN_HIGH = 0x91
  @REG_RED_LOW = 0x92
  @REG_RED_HIGH = 0x93
  @REG_BLUE_LOW = 0x94
  @REG_BLUE_HIGH = 0x95
  @REG_CLEAR_LOW = 0x96
  @REG_CLEAR_HIGH = 0x97

  # Command Register
  @CMD_INTERRUPT_CLEAR = 0xE0

  # Control Register
  @CTL_DAT_INIITIATE = 0x03

  # Timing Register
  @SYNC_EDGE = 0x40
  @INTEG_MODE_FREE = 0x00
  @INTEG_MODE_MANUAL = 0x10
  @INTEG_MODE_SYN_SINGLE = 0x20
  @INTEG_MODE_SYN_MULTI = 0x30

  @PARAM_NOMINAL_INTEGRATION_TIME_12ms = 0x00
  @PARAM_NOMINAL_INTEGRATION_TIME_100ms = 0x01
  @PARAM_NOMINAL_INTEGRATION_TIME_400ms = 0x02

  @PARAM_SYNC_IN_PULSE_COUNT_1 = 0x00
  @PARAM_SYNC_IN_PULSE_COUNT_2 = 0x01
  @PARAM_SYNC_IN_PULSE_COUNT_4 = 0x02
  @PARAM_SYNC_IN_PULSE_COUNT_8 = 0x03

  #Interrupt Control Register
  @INTR_STOP = 40
  @INTR_DISABLE = 0x00
  @INTR_LEVEL = 0x10
  @PERSIST_EVERY = 0x00
  @PERSIST_SINGLE = 0x01

  # Interrupt Souce Register
  @INT_SOURCE_GREEN = 0x00
  @INT_SOURCE_RED = 0x01
  @INT_SOURCE_BLUE = 0x10
  @INT_SOURCE_CLEAR = 0x03

  # Gain Register
  @GAIN_1 = 0x00
  @GAIN_4 = 0x10
  @GAIN_16 = 0x20
  @GANI_64 = 0x30
  @PRESCALER_1 = 0x00
  @PRESCALER_2 = 0x01
  @PRESCALER_4 = 0x02
  @PRESCALER_8 = 0x03
  @PRESCALER_16 = 0x04
  @PRESCALER_32 = 0x05
  @PRESCALER_64 = 0x06

module.exports = TCS3414
