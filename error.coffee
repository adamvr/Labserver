util = require 'util'

class ExperimentError extends Error
    constructor: () ->
        @.message = ''
        if path?
            Error.call @, 'Cannot find #{path}'
        else
            Error.call @, 'Not found'
        Error.captureStackTrace @, arguments.callee

    toJson: () ->
        {code: @code, message: @message}

class NotImplemented extends ExperimentError
    constructor: () ->
        super
        @code = 500
        @message = 'Not implemented'

class UnknownExperimentType extends ExperimentError
    constructor: () ->
        super
        @code = 400
        @message = 'Unknown experiment type'

class ExperimentNotFound extends ExperimentError
    constructor: () ->
        super
        @code = 404
        @message = 'Experiment not found'

class ResultNotFound extends ExperimentError
    constructor: () ->
        super
        @code = 404
        @message = 'Result not found'

class BadExperimentDescription extends ExperimentError
    constructor: () ->
        super
        @code = 400
        @message = 'Bad experiment description'

exports.ExperimentError = ExperimentError
exports.NotImplemented = NotImplemented
exports.UnknownExperimentType = UnknownExperimentType
exports.ExperimentNotFound = ExperimentNotFound
exports.BadExperimentDescription = BadExperimentDescription
exports.ResultNotFound = ResultNotFound

