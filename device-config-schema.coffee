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
	}
}
