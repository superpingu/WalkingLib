chai = require 'chai'
chai.use(require 'chai-spies')
should = chai.should()
{assert, expect} = chai

describe 'sequence', ->
    seq = robot = {}
    cb = -> console.log "lol"
    cb2 = -> console.log "lol"

    beforeEach (done) ->
        # create a mockup for the robot object
        robot =
            test: chai.spy((a, b) -> "lol")
            testObj:
                a: chai.spy(),
                b: chai.spy((callback) -> cb2 = callback)
            move: (callback) -> cb = callback
            move2: (callback) -> cb2 = callback

        seq = require('../lib/sequence')(robot)
        done()

    it 'should make all the function available in sequence', ->
        expect(seq.test).to.be.a('function')
        expect(seq.move).to.be.a('function')
        expect(seq.testObj).to.be.a('object')
        expect(seq.testObj.a).to.be.a('function')
        expect(seq.testObj.b).to.be.a('function')
    it 'should allow to call the sequenced functions', ->
        seq.test("bla", "lol").start()
        robot.test.should.have.been.called.with("bla", "lol")
    describe '.then()', ->
        it 'should call the next stage when all functions called their callback', (done) ->
            seq.test("bla", "lol").move().move2().then().run(done).start()
            cb()
            cb2()
    describe '.done()', ->
        it 'should call a callback after sequence has been competely executed', (done) ->
            seq.test("bla", "lol").done(done).start()
