$(document).on( "templateinit", (event) ->
# define the item class
	class waterLevelDeviceItem extends pimatic.DeviceItem
		apiActualUrl = "https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/uuid-placeholder/W/currentmeasurement.json"
		apiGraphUrl="https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations/uuid-placeholder/W/measurements.json"

		constructor: (templData, @device) ->
			@id = @device.id
			@uuid = @device.config.uuid
			super(templData,@device)

			setInterval ( =>
				@reLoadLevel(@id)
			), 600000

		afterRender: (elements) ->
			super(elements)

			@reLoadLevel(@id)

			return

		reLoadLevel: (id) ->
			actualUrl = apiActualUrl.replace("uuid-placeholder", @uuid)
			graphUrl = apiGraphUrl.replace("uuid-placeholder", @uuid)


			$.getJSON actualUrl, (station) ->
				valIdentifier = "#"+id+"_water_level_actual"
				$(valIdentifier).html("<div>"+station.value+" cm</div>")

			$.getJSON graphUrl, (allData) ->
				console.log(allData)
				values = new Array()
				dates = new Array()
				timestamp = ""

				for i in [0...allData.length - 1] by 1
					val = allData[i]
					if val.timestamp.substring(0, 10) isnt timestamp
						timestamp = val.timestamp.substring(0, 10)
						valDate = new Date(val.timestamp)
						console.log(valDate)
						day = valDate.getDate() + 1
						month = valDate.getMonth() + 1
						date = day + "." + month
						dates.push(date)
						values.push(val.value)

				new (Chartist.Line)('.ct-chart', {
					labels: dates
					series: [ values ]
				},
					fullWidth: true
					chartPadding: right: 40)


	# register the item-class
	pimatic.templateClasses['waterLevel'] = waterLevelDeviceItem
)