
local maxTemp = 24
local probRain = 20
local sunriseOffset = 30
local sunsetOffset = 30

commandArray = {}

print ("Iniciando control de persianas")

nowInMinutes = (os.date("%H")*60) + os.date("%M")

sunriseDiff = nowInMinutes - timeofday['SunriseInMinutes']

if ( sunriseDiff == sunriseOffset
    and otherdevices_scenesgroups['Persianas salon'] == 'Off' 
    and otherdevices_temperature['Prediccion temperatura max'] < maxTemp
    and otherdevices_utility['Probabilidad lluvia'] < probRain
    ) then
    
    print('Abriendo persianas salon')
    commandArray['Group:Persianas salon'] = 'On'
end

sunsetDiff = nowInMinutes - timeofday['SunsetInMinutes']

if ( (sunsetDiff == sunsetOffset) 
     and otherdevices_scenesgroups['Persianas salon'] == 'On' 
     ) then
     print('Cerrando persianas salon')
    commandArray['Group:Persianas salon'] = 'Off'
end

-- Cambiar por sensor de lluvia local deviceName=='isRainning?'
if (otherdevices_rain_lasthour['Lluvia'] > 0 
    and otherdevices_scenesgroups['Persianas salon'] == 'On' 
    ) then
     print('Cerrando persianas salon por lluvia')
    commandArray['Group:Persianas salon'] = 'Off'
end




return commandArray

