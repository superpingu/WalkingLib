STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg
ARGUMENT_NAMES = /([^\s,]+)/g

getParamNames = (func) ->
    fnStr = func.toString().replace(STRIP_COMMENTS, '')
    result = fnStr.slice(fnStr.indexOf('(')+1, fnStr.indexOf(')')).match(ARGUMENT_NAMES)
    return if result is null then [] else result

module.exports = (robot) ->
    sequence = [[]]
    stage = 0
    result = {}
    endCallback = null
    stageExec = 0

    pushStep = (func, args) ->
        sequence[stage].push
            func: func
            args: args
            wait: getParamNames(func).pop() is 'callback'
            cbProvided: getParamNames(func).length == args.length

    sequencify = (obj, key) ->
        if typeof obj[key] is 'function'
            res = (args...) ->
                pushStep(obj[key], args)
                return result
        else if typeof obj[key] is 'object'
            res = {}
            res[k] = sequencify obj[key], k for k of obj[key]
        return res

    result = sequencify(root: robot, 'root')
    delete result.sequence if result.sequence?

    nextStage = ->
        if stageExec > stage
            endCallback?()
        else
            willCallBack = no
            for task in sequence[stageExec]
                task.func task.args...
                willCallBack = yes if task.wait

            stageExec++
            nextStage() if sequence[stageExec - 1].length == 0 or not willCallBack

    result.then = ->
        waitingSteps = 0
        called = 0

        for step in sequence[stage] when step.wait
            waitingSteps++
            cb = step.args.pop() if step.cbProvided
            step.args.push ->
                cb?() # call callback if provided
                # if all the function we're waiting for have called their callback
                if(++called == waitingSteps)
                    nextStage() # start next

        stage++
        sequence[stage] = []
        return result

    result.done = (callback) ->
        endCallback = callback
        return result
    result.stop = ->
        stageExec = stage + 1
        endCallback = null
    result.start = (callback) ->
        result.done callback if callback?
        stageExec = 0
        result.then() if sequence[stage].length > 0
        nextStage()
        return result
    result.run = (func) ->
        pushStep(func, [])
        return result
    result.setSeq = (seq) ->
        sequence = seq.slice()
        stage = seq.length - 1
    result.create = ->
        seq = robot.sequence()
        seq.setSeq sequence
        return seq


    return result
