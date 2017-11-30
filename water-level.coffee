module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  t = env.require('decl-api').types
  Request = require 'request'

  class WaterLevelPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("WaterLevelSensor", {
        configDef: deviceConfigDef.WaterLevelSensor,
        createCallback: (config, lastState) => new WaterLevelSensor(config, lastState)
      })

      @framework.deviceManager.registerDeviceClass("WaterLevelDevice",{
        configDef : deviceConfigDef.WaterLevelDevice,
        createCallback : (config) => new WaterLevelDevice(config,this)
      })

      @framework.on "after init", =>
        mobileFrontend = @framework.pluginManager.getPlugin 'mobile-frontend'
        if mobileFrontend?
          mobileFrontend.registerAssetFile 'js', "pimatic-water-level/app/water-levelTempl-page.coffee"
          mobileFrontend.registerAssetFile 'html', "pimatic-water-level/app/water-levelTempl-template.html"
          mobileFrontend.registerAssetFile 'css', "pimatic-water-level/app/css/water-level.css"
          mobileFrontend.registerAssetFile 'js', "pimatic-water-level/app/chartist.min.js"
          mobileFrontend.registerAssetFile 'css', "pimatic-water-level/app/chartist.css"

        return

  class WaterLevelDevice extends env.devices.Device
    template: 'waterLevel'

    attributes:
      uuid:
        description: 'id of the water level gauge'
        type: t.string
      showGraph:
        description: "Should the graph be displayed"
        type: t.boolean
      graphDays:
        description: "How many days should the graph contain"
        type: t.number

    constructor: (@config, @plugin) ->
      @id = @config.id
      @name = @config.name
      @uuid = @config.uuid
      @showGraph = @config.showGraph or true
      @graphDays = @config.graphDays or 7

      super()

    getUuid: -> Promise.resolve(@uuid)

    setUuid: (value) ->
      if @uuid is value then return
      @uuid = value

    getShowGraph: -> Promise.resolve(@showGraph)

    setShowGraph: (value) ->
      if @showGraph is value then return
      @showGraph = value

    getGraphDays: -> Promise.resolve(@graphDays)

    setGraphDays: (value) ->
      if @graphDays is value then return
      @graphDays = value

    destroy: ->
      super()


  class WaterLevelSensor extends env.devices.Sensor
    attributes:
      level:
        description: "current water level in cm"
        type: t.number

    constructor: (@config, lastState) ->
      env.logger.info @config
      @name = @config.name
      @id = @config.id
      @uuid = @config.uuid
      @level = 0
      @interval = @config.interval or 10

      @level = lastState?["level"]?.value

      @reloadLevel()

      @timerId = setInterval ( =>
        @reloadLevel()
      ), (@interval * 60000)


      @getLevel = () =>
        if @level? then Promise.resolve(@level)
        else @_getUpdatedLevel("level")

      updateValue = =>
        if @config.interval > 0
          @_updateValueTimeout = null
          @_getUpdatedLevel().finally( =>
            @_updateValueTimeout = setTimeout(updateValue, @interval * 60000)
          )

      super()
      updateValue()

    destroy: () ->
      clearTimeout @_updateValueTimeout if @_updateValueTimeout?

      if @timerId?
        clearInterval @timerId
        @timerId = null

      super()

    reloadLevel: ->
      apiActualUrl = "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/uuid-placeholder/W/currentmeasurement.json"
      actualUrl = apiActualUrl.replace("uuid-placeholder", @uuid)

      Request.get actualUrl, (error, response, body) =>
       	if error
          if error.code is "ENOTFOUND"
            env.logger.warn "Cannot connect to :" + actualUrl
          else
            env.logger.error error
          return

        data = JSON.parse(body)
        if data? and data.value?
          @level = data.value
        else
          env.logger.warn "got no actual data from webservice"

    _getUpdatedLevel: () ->
      @emit "level", @level
      return Promise.resolve @level


  waterLevelPlugin = new WaterLevelPlugin
  return waterLevelPlugin