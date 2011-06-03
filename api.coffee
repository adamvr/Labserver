express = require 'express'
util = require 'util'
experiments = require './experiment'
handlers = require './handler'
errors = require './error'

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
