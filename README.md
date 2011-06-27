Introduction
------------

This project is a re-imagining of the iLab project, initiated at MIT. 
It aims to make experiments available online as RESTful resources.

This project is written for nodejs in coffeescript.

Dependencies
------------

* Express

Project layout
--------------

* app.coffee: the entry point for the program, pretty much just an express based REST API description
* handlers and handler.coffee: handlers for various experiment types, where the actual work of running the experiment is done
* experiment.coffee: the internal description of experiments.
* error.coffee: a set of known error types
