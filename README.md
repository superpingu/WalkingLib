# WalkingLib #

This library provides high-level control over a Raspberry Pi-controlled robot,
in javascript with nodeJS.
It includes AX12 and BNO055 IMU driver control.

## Install ##

First, you need the [WalkingDriver](https://github.com/TelecomParistoc/WalkingDriver) library.

Then, just add WalkingLib to your node project using (from the Raspberry Pi) :

```
npm install @superpingu/walkinglib
```

## Usage ##

First create the robot with

```javascript
var robot = require("@superpingu/walkinglib")();
```

#### robot.heading() ####
(requires BNO055 connected to I2C port)  
Return the robot heading in deg, from 0 to 360 clockwise.
Heading is set to 0 when the robot is powered on.

#### robot.heading(value) ####
(requires BNO055 connected to I2C port)  
Set heading to a specified value. This will offset the value for every following
read.  
**value** : the desired value for the current heading, in deg, 0-360.

#### robot.pitch() ####
(requires BNO055 connected to I2C port)  
Return the robot pitch in deg, from 0 to 360 clockwise.
Pitch is set to 0 when the robot is powered on.

#### robot.pitch(value) ####
(requires BNO055 connected to I2C port)  
Set pitch to a specified value. This will offset the value for every following
read.  
**value** : the desired value for the current pitch, in deg, 0-360.

#### robot.roll() ####
(requires BNO055 connected to I2C port)  
Return the robot roll in deg, from 0 to 360 clockwise.
Roll is set to 0 when the robot is powered on.

#### robot.roll(value) ####
(requires BNO055 connected to I2C port)  
Set roll to a specified value. This will offset the value for every following
read.  
**value** : the desired value for the current roll, in deg, 0-360.

#### robot.motorBattery() ####
(requires [Toolbox Board](https://github.com/TelecomParistoc/toolboxboard))  
Returns motor battery voltage in volts.

#### robot.logicBattery() ####
(requires [Toolbox Board](https://github.com/TelecomParistoc/toolboxboard))  
Returns logic battery voltage in volts.

#### robot.LED(LEDnumber, state) ####
(requires [Toolbox Board](https://github.com/TelecomParistoc/toolboxboard))  
Set the state of a LED connected to Toolbox board LED connector.  
**LEDnumber** : the LED to set, from 1 to 4  
**state** : 1 for ON (5V), 0 for OFF (0V)

#### robot.PWM(PWMnumber, dutyCycle) ####
(requires [Toolbox Board](https://github.com/TelecomParistoc/toolboxboard))  
Set the duty cycle of a PWM channel.  
**PWMnumber** : the PWM channel to set, from 1 to 4  
**dutyCycle** : duty cycle, from 0 to 255

#### robot.button(number) ####
(requires [Toolbox Board](https://github.com/TelecomParistoc/toolboxboard))  
Returns the logical state of a button connected to Toolbox board button connector.  
**number** : button number, from 1 to 3  

### AX12 ###

#### robot.ax12(id) ####
Create a new AX12 object.  
You can use it to control real AX12 directly, or create a virtual AX12, to control
a family a servos at once.  
**id** : the ID of the AX12, 0 zero to create a virtual AX12, 1-255 otherwise.

#### ax12.create(id) ####
Create a new AX12 inheriting the all the attributes. Additionally, any action on
ax12 will affect all the servos created from it.

#### ax12.speed() ####
Get the target speed, in %

#### ax12.speed(speed) ####
Set the target speed, in % (0-100)

#### ax12.torque() ####
Get the target torque, in %

#### ax12.torque(torque) ####
Set the target torque, in % (0-100)

#### ax12.moveTo(position, callback) ####
Set AX12 to position control mode and move to the desired position.  
**position** : desired position in deg, -150 to 150  
**callback** : optional. A function to call when target position has been reached.
for a virtual AX12 (ID=0), callback is called when all the children have reached
their target.  

#### ax12.cancelCallback() ####
Cancel moveTo callback.

#### ax12.turn(speed) ####
Set AX12 to wheel mode and turn.  
**speed** : from -100 to 100 in %

#### ax12.preset(presetName, preset, force) ####
Create a new preset. A preset should have the following structure :

```javascript
var preset = {
    speed: 50,
    torque: 20,
    position: -120,
    wheel: false
}
```

All parameter can be omitted, and will just remain unchanged.  
Position will be ignored if wheel is set to true.  
If omitted, wheel defaults to false. However, if wheel and position are omitted,
AX12 will remain unchanged.  

Preset can be later applied using ax12.<presetName>()

**force** : optional. When set to true, allows to replace an existing preset with the same name.

#### ax12.LED(status) ####
Turn AX12 LED on or off.  
**status** : 1 for on, 0 for off

#### ax12.position() ####
Get current position in deg, -150 to 150.

#### ax12.moving() ####
Returns true if the AX12 is moving by its own power.

#### ax12.temperature() ####
Returns AX12 temperature in °C.

#### ax12.voltage() ####
Returns AX12 power voltage in volts.

#### ax12.error() ####
Returns 0 for no error, an error flags otherwise. See WalkingDriver for more info.

### Sequence ###

To make complex action programming easier, it is possible to create sequences of
instructions, that will executed automatically.

Here is a simple example :

```javascript
// two AX12 are connected to the robot
robot.xAxis = robot.ax12(140);
robot.yAxis = robot.ax12(141);

var seq = robot.sequence()
     .xAxis.moveTo(-50)
     .yAxis.moveTo(90)
     .then() // wait until the actions are completed before going on
     .xAxis.moveTo(0)
     .then() // wait until the actions are completed before going on
     .yAxis.moveTo(-90);

// a callback can be called when the sequence has been fully executed
seq.done(function() { console.log("sequence finished !") });

// execute the sequence
seq.start();
```

#### robot.sequence() ####
Returns a new empty sequence. All functions in the robot object when this function
is called will be available in the returned sequence.

#### sequence.then() ####
Wait for all the previous actions to be completed before going on.
Returns the sequence (is therefore chainable)

#### sequence.run() ####
Run a function in the sequence. If the function calls a callback after completing
its task, its only argument should be named exactly 'callback'.

For example :

```javascript
var seq = robot.sequence().run(function(callback) { /* ... */ })
    .then()
    /* ... */
    .start();
```
#### sequence.done(callback) ####
Set up a function called when the sequence is fully executed.

#### sequence.start() ####
Start a sequence from the beginning. A sequence can be executed several times.

#### sequence.stop() ####
Stop sequence execution.

#### sequence.create() ####
Returns a new sequence starting with the sequence it is created from.
