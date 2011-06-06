{Handler} = require '../handler'
{Experiment} = require '../experiment'
errors = require '../error'
util = require 'util'

class TimeOfDayHandler extends Handler
    constructor: () ->
        @queue = []
        @experiments = []
        @running = false

        @on 'experimentAdded', (id) =>
            if not @running
                @running = true
                @_runHead()

        @on 'experimentStarted', (id) =>
            # Purely informational, I guess.
            head = @queue[0]

        @on 'experimentCompleted', (id) =>
            @_removeHead()
            if @queue.length is 0
                @running = false
            else
                @_runHead()

    createExperiment: (description, callback) ->
        util.log util.inspect description
        if description? and description.type?
            if description.type is 'TimeOfDay'
                exp = new Experiment description
                @_addExperiment exp
                callback exp
            else
                callback new errors.UnknownExperimentType()
        else
            callback new errors.BadExperimentDescription()

    getExperiment: (experimentId, callback) ->
        callback @experiments[experimentId]?.experiment ? new errors.ExperimentNotFound()
    getResult: (experimentId, callback) ->
        exp = @experiments[experimentId]
        if exp?
            if exp.result?
                result = exp.result
            else
                result = new errors.ResultNotFound()
        else
            result = new errors.ExperimentNotFound()

        callback result
        
    cancelExperiment: (experimentId, callback) ->
        if @experiments[experimentId]?
            @_cancelExp experimentId

            callback 'OK'
        else 
            callback new errors.ExperimentNotFound()

    _addExperiment: (exp) ->
        exp.id = @experiments.length
        @queue.push exp
        @experiments.push {experiment: exp, result: undefined}
        @emit 'experimentAdded', exp.id


    _runHead: () ->
        head = @queue[0]

        @emit 'experimentStarted', head.id
        head.run()
        head.complete()
        @_setResult head.id, new Date()
        @emit 'experimentCompleted', head.id

    _cancelExp: (id) ->
        @experiments[id].cancel()
        @queue = @queue.filter (q) ->
            q.id != id

        @emit 'experimentCancelled', id

    _setResult: (id, result) ->
        @experiments[id].result = result

    _removeHead: () ->
        @queue = @queue[1..@queue.length]

class TimeOfDayWithDelaysHandler extends TimeOfDayHandler
    _runHead: () ->
        head = @queue[0]

        @emit 'experimentStarted', head.id
        head.run()
        setTimeout () =>
            head.complete()
            @_setResult head.id, {time: new Date()}
            @emit 'experimentCompleted', head.id
        , head.description.delay ? 0

class TimeOfDayWithTz extends TimeOfDayHandler
    _runHead: () ->
        head = @queue[0]
        @emit 'experimentStarted', head.id
        head.run()
        process.env.TZ = head.description.tz ? 'GMT'
        @_setResult head.id, {time: new Date(), tz: head.description.tz}
        head.complete()
        @emit 'experimentCompleted', head.id
        

exports.TimeOfDayHandler = TimeOfDayHandler
exports.TimeOfDayWithDelaysHandler = TimeOfDayWithDelaysHandler
exports.TimeOfDayWithTz = TimeOfDayWithTz
