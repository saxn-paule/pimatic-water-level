This plugin provides the water level for the river of your choice

# Configuration
There is only one configuration parameter
* uuid - the id of the water level gauge of you choice. Get it from https://www.pegelonline.wsv.de/webservices/rest-api/v2/stations.json

### Sample Device Config:
```javascript
{
  "id": "river-town",
  "name": "River Town",
  "class": "WaterLevelDevice",
  "uuid": "522286e2-b2b3-4d0d-9a11-01b3ea418c76"
}
```

### Sample Sensor Config:
```javascript
{
  "class": "WaterLevelSensor",
  "id": "water-level",
  "name": "Wasserstand",
  "interval": 10,
  "uuid": "522286e2-b2b3-4d0d-9a11-01b3ea418c76",
  "xAttributeOptions": []
}
```

# Beware
This plugin is in an early alpha stadium and you use it on your own risk.
I'm not responsible for any possible damages that occur on your health, hard- or software.

# License
MIT
