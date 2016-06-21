
class TCS3414
  constructor: (@i2c)->
    @enableADC()

  enableADC: ()->
    tx = new Buffer [TCS3414.REG_CTL, TCS3414.CTL_DAT_INIITIATE]
    @i2c.send tx

  setTiming: (data = TCS3414.INTEG_MODE_FREE | TCS3414.PARAM_NOMINAL_INTEGRATION_TIME_12ms)->
    tx = new Buffer [TCS3414.REG_TIMING, data]
    @i2c.send tx

  setGain: (data = TCS3414.GAIN_1 | TCS3414.PRESCALER_1)->
    tx = new Buffer [TCS3414.REG_GAIN, data]
    @i2c.send tx

  setInterrupt: (data = TCS3414.INTR_LEVEL | TCS3414.PERSIST_EVERY)->
    tx = new Buffer [TCS3414.REG_INT, data]
    @i2c.send tx

  clearInterrupt: ()->
    tx = new Buffer [TCS3414.CLR_INT]
    @i2c.send tx

  setInterruptSource: (data = TCS3414.INT_SOURCE_CLEAR)->
    tx = new Buffer [TCS3414.REG_INT_SOURCE, data]
    @i2c.send tx

  readRGB: (callback)->
    tx = new Buffer [TCS3414.REG_BLOCK_READ]
    @i2c.transfer tx, 8, (err, rx)->
      throw err if err
      raw =
        green: rx[1] * 256 + rx[0]
        red: rx[3] * 256 + rx[2]
        blue: rx[5] * 256 + rx[4]
        clear: rx[7] * 256 + rx[6]

      scale = 255.0 / Math.max raw.green, raw.red, raw.blue
      rgb =
        red: Math.round raw.red * scale
        green: Math.round raw.green * scale
        blue: Math.round raw.blue * scale

      callback
        raw: raw
        rgb: rgb

  # the I2C address for the color sensor
  @I2C_ADDR = 0x39

  @REG_CTL = 0x80
  @REG_TIMING = 0x81
  @REG_INT = 0x82
  @REG_INT_SOURCE = 0x83
  @REG_ID = 0x84
  @REG_GAIN = 0x87
  @REG_LOW_THRESH_LOW_BYTE = 0x88
  @REG_LOW_THRESH_HIGH_BYTE = 0x89
  @REG_HIGH_THRESH_LOW_BYTE = 0x8A
  @REG_HIGH_THRESH_HIGH_BYTE = 0x8B
  # The REG_BLOCK_READ and REG_GREEN_LOW direction are the same
  @REG_BLOCK_READ = 0xCF
  @REG_GREEN_LOW = 0xD0
  @REG_GREEN_HIGH = 0xD1
  @REG_RED_LOW = 0xD2
  @REG_RED_HIGH = 0xD3
  @REG_BLUE_LOW = 0xD4
  @REG_BLUE_HIGH = 0xD5
  @REG_CLEAR_LOW = 0xD6
  @REG_CLEAR_HIGH = 0xD7

  @CTL_DAT_INIITIATE = 0x03
  @CLR_INT = 0xE0

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
