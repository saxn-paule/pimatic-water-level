# iframe configuration options
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
	}
}
