DEFAULT = 0
WHEEL = 1

ax12 = (driver) ->
    create = (id) ->
        currentSpeed = -2000
        currentTorque = -1
        upToDate =
            speed: false,
            torque: false
        presets = {}
        children = []
        moveCallback = -> console.log "AX12 #{id} move finished"

        realID = (toCall) ->
            return ->
                if id != 0
                    return toCall()
                else
                    return null

        result =
            # send speed and torque (if needed) to the AX12
            update: ->
                return if id == 0
                driver.goalSpeed(id, currentSpeed) unless upToDate.speed
                driver.torque(id, currentTorque) unless upToDate.torque
                upToDate.speed = upToDate.torque = true;

            # set speed and torque are lazy, they don't actually change the value
            # they both are in % (from 0 to 100)

            # set speed from -100 to 100 % (sign ignored in default mode)
            speed: (speed) ->
                return currentSpeed unless speed?
                upToDate.speed = speed == currentSpeed;
                currentSpeed = speed
                child.speed(speed) for child in children
            # set torque from 0 to 100% (0 disables output drive)
            torque: (torque) ->
                return currentTorque unless torque?
                upToDate.torque = torque == currentTorque;
                currentTorque = torque
                child.torque(torque) for child in children

            LED: (status) -> driver.LED(id, status) if id != 0

            # return AX12 data (if the AX12 is real, returns null otherwise)
            position: realID -> driver.position(id)
            moving: realID -> driver.moving(id)
            temperature: realID -> driver.temperature(id)
            voltage: realID -> driver.voltage(id)
            error: realID -> driver.status(id)

            # set to default mode and go to a position (from -150 to +150 deg)
            moveTo: (position, callback) ->
                moveCallback = callback if callback?
                if id != 0 # real AX12
                    result.update()
                    driver.move(id, position, moveCallback);
                else if children.length != 0 # abstract template : move all the real children
                    childrenLeft = children.length;
                    # call the callback only when all the real children finished moving
                    childCallback = -> moveCallback() if --childrenLeft == 0
                    child.moveTo(position, childCallback) for child in children
                else # abstract template without any child : call callback now
                    moveCallback()
            cancelCallback: ->
                driver.cancelCallback(id) if id != 0

            # set to wheel mode (endless turn mode) and set speed, from -100 to 100%
            turn: (speed) ->
                if id != 0 # real AX12
                    upToDate.speed = true;
                    result.update()
                    driver.turn(id, speed);
                else if children.length != 0 # abstract template : move all the real children
                    child.turn(speed) for child in children

            # create a preset
            preset: (name, preset, force) ->
                if result[name]? and not force
                    console.log "This name is already is use, please choose another one"
                    return

                presets[name] = preset
                if preset.wheel? # wheel mode
                    result[name] = ->
                        result.torque preset.torque if preset.torque?
                        result.turn preset.speed if preset.speed?
                else  # position mode
                    result[name] = (callback) ->
                        result.torque preset.torque if preset.torque?
                        result.speed preset.speed if preset.speed?
                        result.moveTo preset.position, callback if preset.position?

            #import an array of presets
            presets: (presets) ->
                result.preset name, preset for name, preset of presets

            create: (id) ->
                newAX = create id
                newAX.speed currentSpeed
                newAX.torque currentTorque
                newAX.preset(k, v, yes) for k, v of presets
                children.push newAX
                return newAX

        return result

module.exports = ax12
