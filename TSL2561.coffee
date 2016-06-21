
class TSL2561
  constructor: (@i2c)->
    @powerUp()

  powerUp: ()->
    tx = new Buffer [TSL2561.REG_CONTROL, TSL2561.CTL_POWER_UP]
    @i2c.send tx

  powerDown: ()->
    tx = new Buffer [TSL2561.REG_CONTROL, TSL2561.CTL_POWER_DOWN]
    @i2c.send tx

  setTiming: (data = TSL2561.GAIN_1 | TSL2561.INTEG_TIME_13ms)->
    tx = new Buffer [TSL2561.REG_TIMING, data]
    @i2c.send tx

  setInterrupt: (data = TSL2561.INTR_DISABLED | TSL2561.PERSIST_EVERY)

  readLux: (callback)->
    tx = new Buffer [TSL2561.REG_ADC_0_WORD]

    (i2c = @i2c).transfer tx, 2, (err, rx)->
      throw err if err
      ch0 = rx[1] * 256 + rx[0]
      tx = new Buffer [TSL2561.REG_ADC_1_WORD]
      i2c.transfer tx, 2, (err, rx)->
        throw err if err
        ch1 = rx[1] * 256 + rx[0]
        callback
          raw: [ch0, ch1]
          lux: Math.round calculateLux ch0, ch1, TSL2561.GAIN_1, TSL2561.INTEG_TIME_13ms

  @I2C_ADDRESS = 0x29

  @PROTOCOL_BYTE = 0x00
  @PROTOCOL_WORD = 0x00

  @REG_CONTROL = 0x80
  @REG_TIMING = 0x81
  @REG_LOW_THRESH_LOW_BYTE = 0x82
  @REG_LOW_THRESH_HIGH_BYTE = 0x83
  @REG_HIGH_THRESH_LOW_BYTE = 0x84
  @REG_HIGH_THRESH_HIGH_BYTE = 0x85
  @REG_INTERRUPT = 0x86
  @REG_ID = 0x8A
  @REG_ADC_0_WORD = 0xAC
  @REG_ADC_0_LOW = 0x8C
  @REG_ADC_0_HIGH = 0x8D
  @REG_ADC_1_WORD = 0xAE
  @REG_ADC_1_LOW = 0x8E
  @REG_ADC_1_HIGH = 0x8F

  # Command Register
  @CMD_INTERRUPT_CLEAR = 0xC0

  # Control Register
  @CTL_POWER_DOWN = 0x00
  @CTL_POWER_UP = 0x03

  # Timing Register
  @GAIN_1 = 0x00
  @GAIN_16 = 0x10
  @INTEG_MODE_MANUAL = 0x0B
  @INTEG_TIME_13ms = 0x00 # 13.7ms
  @INTEG_TIME_101ms = 0x01
  @INTEG_TIME_402ms = 0x02

  #Interrupt Control Register
  @INTR_DISABLED = 0x00
  @INTR_LEVEL = 0x10
  @PERSIST_EVERY = 0x00
  @PERSIST_SINGLE = 0x01


  PACKAGE_TYPE_TMB = 0
  PACKAGE_TYPE_CHIPSCALE = 1

  calculateLux = (ch0, ch1, gain, integ_time, package_type = PACKAGE_TYPE_TMB)->
    scale = switch integ_time
      when TSL2561.INTEG_TIME_13ms then 322 / 11
      when TSL2561.INTEG_TIME_101ms then 322 / 81
      else 1
    scale *= 16 if gain == TSL2561.GAIN_1
    ch0 *= scale
    ch1 *= scale

    ratio = if ch0 > 0 then ch1 / ch0 else 0

    [b, m, r = 1] =
      if package_type == TSL2561.PACKAGE_TYPE_TMB
        switch
          #when ratio <= 0.125 then [0.0304, 0.0272]
          #when ratio <= 0.250 then [0.0325, 0.0440]
          #when ratio <= 0.375 then [0.0351, 0.0544]
          #when ratio <= 0.50 then [0.0381, 0.0624]
          when ratio <= 0.50 then [0.0304, 0.062, Math.pow(ratio, 1.4)]
          when ratio <= 0.61 then [0.0224, 0.031]
          when ratio <= 0.80 then [0.0128, 0.0153]
          when ratio <= 1.3 then [0.00146, 0.00112]
          else [0.000, 0.000]
      else # package_type == TSL2561.PACKAGE_TYPE_CS
        switch
          #when ratio <= 0.13 then [0.0315, 0.0262, ratio]
          #when ratio <= 0.26 then [0.0337, 0.0430]
          #when ratio <= 0.39 then [0.0363, 0.0529]
          #when ratio <= 0.52 then [0.0392, 0.0605]
          when ratio <= 0.52 then [0.0315, 0.0593, Math.pow(ratio, 1.4)]
          when ratio <= 0.65 then [0.0229, 0.0291]
          when ratio <= 0.80 then [0.0157, 0.0180]
          when ratio <= 1.3 then [0.00338, 0.00260]
          else [0.000, 0.000]
    ch0 * b - ch1 * m * r

module.exports = TSL2561
