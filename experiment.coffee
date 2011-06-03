util = require 'util'

ExperimentState = {Queued: 0, Running: 1, Completed: 2, Cancelled: 3}

class Experiment
    constructor: (@description) -> 
        @created = new Date
        @state = ExperimentState.Queued
        
    run: () ->
        @started = new Date
        @state = ExperimentState.Running
    complete: () ->
        @completed = new Date
        @state = ExperimentState.Completed
    cancel: () ->
        @cancelled = new Date
        @state = ExperimentState.Cancelled

exports.Experiment = Experiment
