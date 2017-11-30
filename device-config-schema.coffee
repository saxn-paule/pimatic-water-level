# water level configuration options
module.exports = {
	title: "waterLevel"
	WaterLevelDevice :{
		title: "Plugin Properties"
		type: "object"
		extensions: ["xLink"]
		properties:
			uuid:
				description: "The id of the water level gauge"
				type: "string"
				default: ""
			showGraph:
				description: "Should the graph be displayed"
				type: "boolean"
				default: true
			graphDays:
				description: "How many days should the graph contain"
				type: "number"
				default: 7
			currentLevel:
				description: "Current water level in cm"
				type: "number"
				default: 0
	},
	WaterLevelSensor :{
		title: "WaterLevel Sensor"
		type: "object"
		extensions: ["xLink", "xAttributeOptions"]
		required:["uuid"]
		properties:
			interval:
				description: "the time in minutes, the water level gets updated to get a new sensor value"
				type: "integer"
				default: 10
			uuid:
				description: "id for the water level from pegelonline.de"
				type: "string"
	}
}
