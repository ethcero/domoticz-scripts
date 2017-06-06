--[[ 
	~/domoticz/scripts/lua/script_time_customDarkSky.lua
]]--


-- Variables -----------------------------------
local localhost = '127.0.0.1:8080'
local latitude = uservariables['homeLat']
local longitude = uservariables['homeLng']
local darkSkyAPIkey = uservariables['darkSkyAPIkey']
local DEBUG = 1 						-- 0 , 1 for domoticz log , 2 for file log


--- devices indexes -----------------------------
local idxTHB = 26
local idxWind = 28
local idxRain = 27

local idxPredTempMax = 29
local idxPredTempMin = 30
local idxPredRain = 31




function humidityStatus(humidity)
	if(humidity >= 70) then
		return 3 
	elseif (humidity < 70 and humidity > 45) then
		return  2
	elseif (humidity <= 45 and humidity >30) then
		return 0
	else
		return 1
	end
end

function deg2compass(num)
	local val=math.floor((num/22.5)+.5)
	arr={"N","NNE","NE","ENE","E","ESE", "SE", "SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"}
	return arr[(val % 16)]

end



commandArray = {}

time = os.date("*t")
if((time.min % 3) == 0) then  --Run every 3 minutes

json = (loadfile "/home/domoticz/domoticz/scripts/lua/JSON.lua")()

local config =assert(io.popen('curl "https://api.darksky.net/forecast/'..darkSkyAPIkey..'/'..latitude..','..longitude..','..os.time(time)..'?exclude=minutely,hourly,alerts,flags&lang=es&units=si"'))
local location = config:read('*all')
config:close()
local jsonLocation = json:decode(location)
if( DEBUG == 1 ) then
	local latitude = jsonLocation.latitude
	local longitude = jsonLocation.longitude
	print('Lat: '..latitude..' Long: '..longitude)
end

if( DEBUG == 2 ) then
	print(location)
end

if( jsonLocation.currently ) then

local currentTemp = jsonLocation.currently.temperature
local currentHum = jsonLocation.currently.humidity * 100
local currentPressure = jsonLocation.currently.pressure
local currentRainRate = jsonLocation.currently.precipIntensity
local currentRainProbability = jsonLocation.currently.precipProbability
local currentWindBearing = jsonLocation.currently.windBearing
local currentWindSpeed = jsonLocation.currently.windSpeed
local predTemMax = jsonLocation.daily.data[1].temperatureMax
local predTemMin = jsonLocation.daily.data[1].temperatureMin
local predRain = jsonLocation.daily.data[1].precipProbability




if(DEBUG == 1 ) then
	print('Temp: '..currentTemp..' Hum: '..currentHum..' Pressure: '..currentPressure)
end

local urlParam = currentTemp..';'..currentHum..';'..humidityStatus(currentHum)..';'..currentPressure..';0'

commandArray[#commandArray + 1]={['OpenURL']="http://"..localhost.."/json.htm?type=command&param=udevice&idx="..idxTHB.."&nvalue=0&svalue="..urlParam }
commandArray[#commandArray + 1]={['OpenURL']="http://"..localhost.."/json.htm?type=command&param=udevice&idx="..idxRain.."&nvalue=0&svalue="..currentRainRate..';'..currentRainProbability }
commandArray[#commandArray + 1]={['OpenURL']="http://"..localhost.."/json.htm?type=command&param=udevice&idx="..idxWind.."&nvalue=0&svalue="..currentWindBearing..';'..deg2compass(currentWindBearing)..';'..currentWindSpeed..';0;0;0' }

---predictions
commandArray[#commandArray + 1]={['OpenURL']="http://"..localhost.."/json.htm?type=command&param=udevice&idx="..idxPredTempMax.."&nvalue=0&svalue="..predTemMax }
commandArray[#commandArray + 1]={['OpenURL']="http://"..localhost.."/json.htm?type=command&param=udevice&idx="..idxPredTempMin.."&nvalue=0&svalue="..predTemMin }
commandArray[#commandArray + 1]={['OpenURL']="http://"..localhost.."/json.htm?type=command&param=udevice&idx="..idxPredRain.."&nvalue=0&svalue="..predRain }


end

end


return commandArray
