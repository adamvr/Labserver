util = require 'util'
errors = require './error'
time = require 'time'
{EventEmitter} = (require 'events')
{Experiment} = (require './experiment')

class Handler extends EventEmitter
    createExperiment: (description, callback) ->
        callback errors.NotImplemented()
    getExperiment: (experimentId, callback) ->
        callback errors.NotImplemented()
    getResult: (experimentId, callback) ->
        callback errors.NotImplemented()
    cancelExperiment: (experimentId, callback) ->
        callback errors.NotImplemented()

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
        callback @experiments[experimentId] ? new errors.ExperimentNotFound()
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
        @experiments.push exp
        @emit 'experimentAdded', exp.id


    _runHead: () ->
        head = @queue[0]

        @emit 'experimentStarted', head.id
        head.run()
        head.complete()
        head.result = new Date()
        @emit 'experimentCompleted', head.id

    _cancelExp: (id) ->
        @experiments[id].cancel()
        @queue = @queue.filter (q) ->
            q.id != id

        @emit 'experimentCancelled', id



    _removeHead: () ->
        @queue = @queue[1..@queue.length]

class TimeOfDayWithDelaysHandler extends TimeOfDayHandler
    _runHead: () ->
        head = @queue[0]

        @emit 'experimentStarted', head.id
        head.run()
        setTimeout () =>
            head.complete()
            head.result = new Date()
            @emit 'experimentCompleted', head.id
        , head.description.delay ? 0

class TimeOfDayWithTz extends TimeOfDayHandler
    _runHead: () ->
        head = @queue[0]
        @emit 'experimentStarted', head.id
        head.run()
        time.tzset(head.description.tz ? 'GMT')
        head.result = time.Date()
        head.complete()
        @emit 'experimentCompleted', head.id
        

exports.TimeOfDayHandler = TimeOfDayHandler
exports.TimeOfDayWithDelaysHandler = TimeOfDayWithDelaysHandler
exports.TimeOfDayWithTz = TimeOfDayWithTz
