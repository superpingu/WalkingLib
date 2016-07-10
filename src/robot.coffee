{imu, toolbox, ax12} = require 'walkingdriver'
sequencer = require './sequence'

module.exports = =>
    imu.init()
    toolbox.init()
    ax12.init 115200

    result =
        ax12: require('./ax12')(ax12)

        heading: imu.heading
        pitch: imu.pitch
        roll: imu.roll

        motorBattery: toolbox.motorPowerLevel
        logicBattery: toolbox.logicPowerLevel
        PMW: toolbox.PWM
        LED: toolbox.LED
        button: toolbox.button

        sequence: -> sequencer(result)
        
    return result
