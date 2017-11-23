module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  t = env.require('decl-api').types

  class WaterLevelPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      deviceConfigDef = require("./device-config-schema")
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

  waterLevelPlugin = new WaterLevelPlugin
  return waterLevelPlugin