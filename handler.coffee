util = require 'util'
errors = require './error'
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

exports.Handler = Handler
