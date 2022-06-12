-- ServiceProvider v0.2: a script by buur. It provides radio and other stuff from servic provider like tanker, AWACS or FAC
-- ToDo: FARPS and Carrier. JTACs with more than one target will have several entries for their own position
-- Changelog: protect Tanker, AWACS again late activated units. (not shown in mist database); EWR Radars are added
function infoAWACS()
	local msg = {}
	msg[#msg + 1] = "AWACS\\EWR:"
	msg[#msg + 1]='\n'
	local ServiceProvider = coalition.getServiceProviders(2 , 1 )
	if next(ServiceProvider) ~= nil then
	do
		for ke,val in pairs(ServiceProvider) 
		do
		 if ServiceProvider[ke]:getCallsign() then
			 callsign = ServiceProvider[ke]:getCallsign()
		 else
			 callsign = "N/A"
		 end
		 local nametype = ServiceProvider[ke]:getTypeName()
		 msgstr = nametype.." "..callsign.." "
		 local ServiceProvider = ServiceProvider[ke]:getGroup():getName()
		 local groupServiceProvider = mist.getGroupData(ServiceProvider)
		 local routeServiceProvider = mist.getGroupRoute(ServiceProvider , true)
		 Modulation = {[0]="AM", [1]="FM"}
		 if groupServiceProvider["frequency"] then -- get the values from lua database only when they exists
			 msgstr = msgstr.."Freq: "..groupServiceProvider["frequency"].." "..Modulation[groupServiceProvider["modulation"]].." "
			 local t=mist.getGroupRoute( ServiceProvider , true )[1]["task"]["params"]["tasks"]
		 elseif routeServiceProvider[1]["task"]["params"]["tasks"][1]["id"] == "EWR" then
			Modulation = {[0]="AM", [1]="FM"}
			EWR_tasks = routeServiceProvider[1]["task"]["params"]["tasks"]
			for key,value in pairs(EWR_tasks) 
			
				do
				 if EWR_tasks[key]["id"] == "WrappedAction" then
					local EWR_frequency = EWR_tasks[key]["params"]["action"]["params"]["frequency"]
					local EWR_Modulation = EWR_tasks[key]["params"]["action"]["params"]["modulation"]
					 msgstr = msgstr.."Freq: "..EWR_frequency/1000000 .." "..Modulation[EWR_Modulation]	 
				end			
			   end
		 end
		 msg[#msg + 1] = msgstr
		 msg[#msg + 1]='\n'
		end
	trigger.action.outText(table.concat(msg), 30, false)
	end
	end
end

function infoFAC()
	msg = {}
	msg[#msg + 1] = "FAC:"
	msg[#msg + 1]='\n'
	local ServiceProvider = coalition.getServiceProviders(2 , 3 )
	if next(ServiceProvider) ~= nil then
		do
			for ke,val in pairs(ServiceProvider) 
			do
			 local callsign = ServiceProvider[ke]:getCallsign()
			 local curPoint = ServiceProvider[ke]:getPoint()
			 local lat, lon, alt = coord.LOtoLL(curPoint)
			 local grid = coord.LLtoMGRS(lat,lon)
			 local msgstr = callsign.." ".."at Position: " ..grid.UTMZone .. ' ' .. grid.MGRSDigraph .. ' '.. grid.Easting .. ' ' .. grid.Northing.." "--..lat.." "..lon
			 local ServiceProvider = ServiceProvider[ke]:getGroup():getName()
			 
			 
			 local t=mist.getGroupRoute( ServiceProvider , true )[1]["task"]["params"]["tasks"]

			 for key,value in pairs(t) 
				do
					  if (t[key]["id"] == "FAC_AttackGroup") or (t[key]["id"] == "FAC") or (t[key]["id"] == "FAC_EngageGroup") then 
					Modulation = {[0]="AM", [1]="FM"}
					local FAC_frequency = (t[key]["params"]["frequency"])
					local FAC_Modulation = (t[key]["params"]["modulation"])
					local msgstr = msgstr.."Freq: "..FAC_frequency/1000000 .." "..Modulation[FAC_Modulation]
					msg[#msg + 1] = msgstr
					msg[#msg + 1]='\n'

					 
					  end
				end
			end
		trigger.action.outText(table.concat(msg), 30, false)
		end
	end
end

function infoTanker()
	msg = {}
	msg[#msg + 1] = "Tanker:"
	msg[#msg + 1]='\n'
	local ServiceProvider = coalition.getServiceProviders(2 , 2 )
		if next(ServiceProvider) ~= nil then
		do
				for ke,val in pairs(ServiceProvider) 
				do
				 local callsign = ServiceProvider[ke]:getCallsign()
				 local nametype = ServiceProvider[ke]:getTypeName()
				 msgstr = nametype.." "..callsign.." "
				 local ServiceProvider = ServiceProvider[ke]:getGroup():getName()
				 
				 
				 local groupServiceProvider = mist.getGroupData(ServiceProvider)
				 Modulation = {[0]="AM", [1]="FM"}
				 if groupServiceProvider["frequency"] then -- get the values from lua database only when they exists
					msgstr = msgstr.."Freq: "..groupServiceProvider["frequency"].." "..Modulation[groupServiceProvider["modulation"]].." "
					local t=mist.getGroupRoute( ServiceProvider , true )[1]["task"]["params"]["tasks"]

					for key,value in pairs(t) 
						do
							 if t[key]["id"] == "WrappedAction" then

							local TCN_channel = t[key]["params"]["action"]["params"]["channel"]
							local TCN_modeChannel = t[key]["params"]["action"]["params"]["modeChannel"]
							local TCN_callsign = t[key]["params"]["action"]["params"]["callsign"]
							local msgstr = msgstr.."TCN: "..TCN_channel..TCN_modeChannel.." "..TCN_callsign
							msg[#msg + 1] = msgstr
							msg[#msg + 1]='\n'

							 
							 end
						end
					end
			end
			trigger.action.outText(table.concat(msg), 30, false)
		end
	end
end



local displayInfo = missionCommands.addSubMenuForCoalition(2, "Display Information", nil)
local displayAWACS = missionCommands.addCommandForCoalition(2 , "Diplay AWACS\\EWR" , displayInfo , infoAWACS, {} )
local displayFAC = missionCommands.addCommandForCoalition(2 , "Diplay FAC" , displayInfo , infoFAC, {} )
local displayTanker = missionCommands.addCommandForCoalition(2 , "Diplay Tanker" , displayInfo , infoTanker, {} )