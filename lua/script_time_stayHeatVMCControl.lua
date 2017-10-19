
commandArray = {}

print ("Iniciando control de VMC Stay Heat")

if ( timeofday['Nighttime']
    and otherdevices['VMC Standby'] == 'Off'
    and uservariables['stayHeatStatus'] == 'Off'
    and otherdevices_temperature['VMC Temp interior'] < uservariables['stayHeatTint']
    and otherdevices_temperature['VMC Temp Exterior'] < uservariables['stayHeatTint']
    ) then

    print('Apagando VMC')
    commandArray['VMC Standby'] = 'On'
    commandArray['Variable:stayHeatStatus'] = 'On'
end

if ( timeofday['Daytime']
     and otherdevices['VMC Standby'] == 'On'
     and uservariables['stayHeatStatus'] == 'On'
     ) then
     print('Arrancando VMC')
    commandArray['VMC Standby'] = 'Off'
    commandArray['Variable:stayHeatStatus'] = 'Off'
end


return commandArray
