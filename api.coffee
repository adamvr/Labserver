express = require 'express'
util = require 'util'
experiments = require './experiment'
handlers = require './handler'
errors = require './error'

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
        

api = new API (new handlers.TimeOfDayWithDelaysHandler())
api.listen 3000

'''
app = express.createServer()
app.handler = new handlers.TimeOfDayWithDelaysHandler()
app.use express.bodyParser()
app.use express.logger()

app.post '/experiment', (req, res) ->
    app.handler.createExperiment req.body, (exp) ->
        if exp instanceof errors.ExperimentError
            throw exp
        else
            res.send exp

app.get '/experiment/:id', (req, res) ->
    util.log 'experiment get'
    app.handler.getExperiment req.params.id, (exp) ->
        if exp instanceof errors.ExperimentError
            throw exp
        else
            res.send exp

app.get '/experiment/:id/result', (req, res) ->
    app.handler.getResult req.params.id, (exp) ->
        if exp instanceof errors.ExperimentError
            throw exp
        else
            res.send exp

app.del '/experiment/:id', (req, res) ->
    app.handler.cancelExperiment req.params.id, (exp) ->
        if exp instanceof errors.ExperimentError
            throw exp
        else
            res.send 200

app.error (err, req, res, next) ->
    util.log err
    res.send({error: err.message}, err.code)

app.listen 3000
'''
