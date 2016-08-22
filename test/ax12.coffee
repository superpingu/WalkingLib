# using chai-spies to check driver is called
chai = require 'chai'
chai.use(require 'chai-spies')
should = chai.should()
{assert, expect} = chai

describe 'AX12', ->
    ax12 = positions = driver = callbacks = {}
    beforeEach ->
        # create a mockup for the ax12 driver object
        positions = {}
        driver =
            position: chai.spy((id) -> positions[id])
            torque: chai.spy()
            goalSpeed: chai.spy()
            move: chai.spy((id, position, callback) -> callbacks[id] = callback)
            turn : chai.spy()
            LED: chai.spy()
            reset: chai.spy()
        ax12 = require('../lib/ax12')(driver)

    describe '.position()', ->
        it 'should return the position of the AX12 if the ID is not 0', ->
            positions[126] = -138
            positions[157] = 89.35
            ax12(126).position().should.equal -138
            ax12(157).position().should.equal 89.35
            driver.position.should.have.been.called.twice()
        it 'shouldnt call the driver if the ID is 0', ->
            positions[0] = 334
            expect(ax12(0).position()).to.be.null
            driver.position.should.not.have.been.called()
    describe '.speed()', ->
        it 'should change current speed if ID isnt 0', ->
            servo = ax12(126)
            servo.speed(97)
            driver.goalSpeed.should.have.been.called.with(126, 97)
        it 'should return current speed when called without argument', ->
            servo = ax12(149)
            servo.speed(43)
            servo.speed().should.equal 43
        it 'should not call anything if ID is 0', ->
            servo = ax12(0)
            servo.speed(50)
            driver.goalSpeed.should.not.have.been.called()
        it 'should change children speed if ID isnt 0', ->
            template = ax12(0)
            template.speed(20)
            servo = template.create(129)
            servo2 = template.create(127)
            driver.goalSpeed.should.have.been.called.with(129, 20)
            template.speed(50)
            driver.goalSpeed.should.have.been.called.with(129, 50)
            driver.goalSpeed.should.have.been.called.with(127, 50)
    describe '.torque()', ->
        it 'should change current torque if ID isnt 0', ->
            servo = ax12(126)
            servo.torque(50)
            driver.torque.should.have.been.called.with(126, 50)
        it 'should return current torque when called without argument', ->
            servo = ax12(148)
            servo.torque(43)
            servo.torque().should.equal 43
        it 'should not call anything if ID is 0', ->
            servo = ax12(0)
            servo.torque(500)
            driver.torque.should.not.have.been.called()
        it 'should change children torque if ID isnt 0', ->
            template = ax12(0)
            template.torque(20)
            servo = template.create(129)
            servo2 = template.create(127)
            driver.torque.should.have.been.called.with(129, 20)
            template.torque(50)
            driver.torque.should.have.been.called.with(129, 50)
            driver.torque.should.have.been.called.with(127, 50)
    describe '.moveTo()', ->
        it 'should call driver\'s move()', (done) ->
            servo = ax12(140)
            servo.torque(20)
            servo.speed(50)
            servo.moveTo 24.7, done
            driver.torque.should.have.been.called.with(140, 20)
            driver.goalSpeed.should.have.been.called.with(140, 50)
            driver.move.should.have.been.with(140, 24.7, done)
            callbacks[140]()
        it 'should move all the children for an abstract AX12', (done) ->
            template = ax12(0)
            template.torque(20)
            template.speed(50)
            servo = template.create(129)
            servo2 = template.create(127)
            servo3 = template.create(0)
            template.moveTo 24.7, done
            driver.torque.should.have.been.called.with(129, 20)
            driver.goalSpeed.should.have.been.called.with(129, 50)
            driver.torque.should.have.been.called.with(127, 20)
            driver.goalSpeed.should.have.been.called.with(127, 50)
            driver.move.should.have.been.called.with(127, 24.7)
            driver.move.should.have.been.called.with(129, 24.7)

            callbacks[127]()
            callbacks[129]()
    describe '.turn()', ->
        it 'should call driver\'s turn()', ->
            servo = ax12(140)
            servo.torque 20
            servo.speed 50
            servo.turn 70
            driver.torque.should.have.been.called.with(140, 20)
            driver.goalSpeed.should.have.been.called.with(140, 50)
            driver.turn.should.have.been.with(140, 70)
        it 'should make all the children turn if AX12 is abstract', ->
            template = ax12(0)
            template.torque(20)
            servo = template.create(129)
            servo2 = template.create(127)
            servo3 = template.create(0)
            template.turn 70
            driver.torque.should.have.been.called.with(129, 20)
            driver.torque.should.have.been.called.with(127, 20)
            driver.goalSpeed.should.not.have.been.called()
            driver.turn.should.have.been.called.with(127, 70)
            driver.turn.should.have.been.called.with(129, 70)
            driver.turn.should.have.been.called.twice()
    describe '.preset()', ->
        it 'should create a preset, which can be called to move', (done) ->
            servo = ax12(140)
            servo.preset 'up',
                speed: 65
                torque: 30
                position: 24.7
            servo.up done
            driver.torque.should.have.been.called.with(140, 30)
            driver.goalSpeed.should.have.been.called.with(140, 65)
            driver.move.should.have.been.with(140, 24.7, done)
            callbacks[140]()
        it 'should create a preset, which can be called to turn', ->
            servo = ax12(140)
            servo.preset 'up',
                speed: 65
                torque: 30
                wheel: yes
            servo.up()
            driver.torque.should.have.been.called.with(140, 30)
            driver.goalSpeed.should.not.have.been.called()
            driver.turn.should.have.been.with(140, 65)
        it 'should be herited by children', ->
            template = ax12(0)
            template.preset 'up',
                speed: 65
                torque: 30
                wheel: yes
            servo = template.create(140)
            servo.up()
            driver.torque.should.have.been.called.with(140, 30)
            driver.goalSpeed.should.not.have.been.called()
            driver.turn.should.have.been.with(140, 65)
