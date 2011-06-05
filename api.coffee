express = require 'express'
util = require 'util'
experiments = require './experiment'
handlers = require './handler'
errors = require './error'
io = require 'socket.io'

class API extends express.HTTPServer
    constructor: (@exphandler) ->
        super()
        @use express.bodyParser()
        @use express.logger()

        @post '/experiment', (req, res) =>
            @exphandler.createExperiment req.body, (exp) =>
                resp = if exp instanceof errors.ExperimentError then exp else {experiment: @makeUri req, exp}
                @respond res, resp

        @get '/experiment/:id', (req, res) =>
            @exphandler.getExperiment req.params.id, (exp) =>
                @respond res, exp

        @get '/experiment/:id/result', (req, res) =>
            @exphandler.getResult req.params.id, (exp) =>
                @respond res, exp


        @del '/experiment/:id', (req, res) =>
            @exphandler.cancelExperiment req.params.id, (exp) =>
                @respond res, exp

        @error (err, req, res, next) =>
            util.log err
            res.send({error: err.message}, err.code);

    respond: (res, response) ->
        if response instanceof errors.ExperimentError
            throw response
        else
            res.send response

    makeUri: (req, exp) ->
        "http://#{req.header 'host'}/experiment/#{exp.id}"
        
#api = new API (new handlers.TimeOfDayWithDelaysHandler())

class SocketApi extends API
    constructor: (@exphandler) ->
        super @exphandler
        @iosock = io.listen(@)

        @exphandler.on 'experimentAdded', (id) =>
            msg = "Experiment #{id} created with parameters #{util.inspect @exphandler.experiments[id].description}"
            an = {announcement: msg}
            util.log msg
            @iosock.broadcast an

        @exphandler.on 'experimentStarted', (id) =>
            msg = "Experiment #{id} started"
            util.log msg
            an = {announcement: msg}
            @iosock.broadcast an

        @exphandler.on 'experimentCompleted', (id) =>
            msg =  "Experiment #{id} completed - results #{@exphandler.experiments[id].result}"
            util.log msg
            an = {announcement: msg}
            @iosock.broadcast an

        @exphandler.on 'experimentCancelled', (id) =>
            msg = "Experiment #{id} cancelled"
            util.log 'cancelled'
            an = {announcement: msg}
            @iosock.broadcast an

api = new SocketApi (new handlers.TimeOfDayWithDelaysHandler())
api.get '/json.js', (req, res) ->
    res.sendfile "#{dirname}/test/json.js"

api.get '/', (req, res) ->
    res.sendfile "#{dirname}/test/chat.html"

#api = new SocketApi (new handlers.TimeOfDayWithDelaysHandler())
api.listen 3000
