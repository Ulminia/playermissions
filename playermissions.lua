GMI ={
	Version = "1.4",
	db = {},
	Char =  UnitName("player"),
	Server = GetRealmName(),
	};

local GMIframe = CreateFrame("FRAME"); -- Need a GMIframe to respond to events
local f = CreateFrame('GameTooltip', 'MyTooltip', UIParent, 'GameTooltipTemplate'); -- we load our own tooltip GMIframe

GMIframe:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
GMIframe:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out
GMIframe:RegisterEvent("PLAYER_LEAVING_WORLD"); -- Fired when about to log out


function GMIframe:OnEvent(event, arg1)
	if(UnitLevel("player") > 90 ) then
		if event == "ADDON_LOADED" and arg1 == "playermissions" then
			GMIframe:Print('Garrison Missions v'.. GMI.Version..' Loaded');
			if playermissions == nil then
				GMI.db = {}
			end
			if playermissions then
				GMI.db = playermissions;
			end

			GMIframe:init();
		elseif event == "ADDON_LOADED" and arg1 == "Blizzard_GarrisonUI" then
			GMIframe:ButtonHandler();
			GMIframe:ButtonHandler2();
		elseif event == "PLAYER_LEAVING_WORLD" then
			--GMIframe:Garrison();
			playermissions = GMI.db;
		elseif event == "PLAYER_LOGOUT" then	
			--GMIframe:Garrison();
			playermissions = GMI.db;
		end
		--GMIframe:Print('args'..arg1..'');
	end
end


function GMIframe:ButtonHandler()
	self.buttons = {}
	local button = CreateFrame("Button", "GMISAVEBUTTON", GarrisonMissionFrame, "UIPanelButtonTemplate");
	button.tooltip = "Save Missions"--L["Save Missions~!"]
	button.startTooltip = button.tooltip
	button:SetPoint("TOPRIGHT", GarrisonMissionFrame, "TOPRIGHT", -25, 0)
	button:SetWidth(79)
	button:SetHeight(22)
	button:SetText("Save Missions") --L["save"])
	button:SetScript("OnEnter", showTooltip)
	button:SetScript("OnLeave", hideTooltip)
	button:SetScript("OnClick", function(self)GMIframe:Garrison();GMIframe:followers();GMIframe:workorders(); end )
	self.buttons.save = button
end
function GMIframe:ButtonHandler2()
	self.buttons = {}
	local button = CreateFrame("Button", "GMISAVEBUTTON2", GarrisonShipyardFrame.BorderFrame, "UIPanelButtonTemplate");
	button.tooltip = "Save Missions"--L["Save Missions~!"]
	button.startTooltip = button.tooltip
	button:SetPoint("TOPRIGHT", GarrisonShipyardFrame.BorderFrame, "TOPRIGHT", -25, 0)
	button:SetWidth(79)
	button:SetHeight(22)
	button:SetText("Save Missions") --L["save"])
	button:SetScript("OnEnter", showTooltip)
	button:SetScript("OnLeave", hideTooltip)
	button:SetScript("OnClick", function(self)GMIframe:Garrison();GMIframe:followers();GMIframe:workorders(); end )
	self.buttons.save = button
end

function GMIframe:init()

	GMI.Char =  UnitName("player");
	GMI.Server = GetRealmName();
	
	if( not GMI.db[GMI.Server] ) then
		GMI.db[GMI.Server]={}; 
	end
	
	if( not GMI.db[GMI.Server][GMI.Char] ) then
		GMI.db[GMI.Server][GMI.Char]={};
	end
	if( not GMI.db[GMI.Server][GMI.Char]["Garrison"] ) then
		GMI.db[GMI.Server][GMI.Char]["Garrison"]={};
		GMIframe:Print('Profile for '.. GMI.Char ..' Created');
	else
		GMIframe:Print('Profile for '.. GMI.Char ..' Loaded');
	end
	
end

GMIframe:SetScript("OnEvent", GMIframe.OnEvent);
SLASH_GMI1 = "/gmi";
function SlashCmdList.GMI(argline)

	local msg = GMIframe.Str2Ary(argline);
	local server = GMI.Server;
	
	if msg[1] == 'test' then
	
		GMIframe:test();
		
	elseif (msg[1] == "save") then
	
		GMIframe:Garrison();
		GMIframe:followers();
		GMIframe:workorders();
		
	end
end
function GMIframe:test()
end

function GMIframe:workorders()

	local orders = {};
	--for _,building in ipairs( C_Garrison.GetBuildings() ) do
		--local buildingID, buildingName, texturePrefix, icon, description, rank, currencyID, currencyAmount, goldAmount, timeRequirement, needsPlan, isPreBuilt, possSpecs, upgrades, canUpgrade, isMaxLevel, hasFollowerSlot, knownSpecs, currentSpec, specCooldown, isBeingBuilt, timeStarted, buildDuration, timeRemainingText, canCompleteBuild = C_Garrison.GetOwnedBuildingInfo( building.plotID );
	local shipmentIndex = 1;
	local buildings = C_Garrison.GetBuildings();
	--GMI.db[GMI.Server][GMI.Char]["Buildings"] =buildings;
	for i = 1, #buildings do
		local buildingID = buildings[i].buildingID;
		if ( buildingID) then
		local buildingID, buildingName, texturePrefix, icon, description, rank, currencyID, currencyAmount, goldAmount, timeRequirement, needsPlan, isPreBuilt, possSpecs, upgrades, canUpgrade, isMaxLevel, hasFollowerSlot, knownSpecs, currentSpec, specCooldown, isBeingBuilt, timeStarted, buildDuration, timeRemainingText, canCompleteBuild = C_Garrison.GetOwnedBuildingInfo( buildings[i].plotID );
		local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemIcon, itemQuality, itemID = C_Garrison.GetLandingPageShipmentInfo( buildingID );
		if (shipmentCapacity) then
			orders[buildingID] = {
				name 				= name,
				buildingName		= buildingName,
				texture 			= texture,
				texturePrefix		= texturePrefix,
				icon				= icon,
				shipmentCapacity 	= shipmentCapacity,
				shipmentsReady 		= shipmentsReady,
				shipmentsTotal 		= shipmentsTotal,
				creationTime 		= creationTime,
				duration 			= duration,
				timeleftString 		= timeleftString,
				itemName 			= itemName,
				itemIcon 			= itemIcon,
				itemQuality 		= itemQuality,
				itemID				= itemID,
				description			= description
			};
		end
		end
		--C_Garrison.GetLandingPageShipmentInfo( buildingID );
	end
	GMI.db[GMI.Server][GMI.Char]["Orders"] = orders;
	local numorders = tablelength(orders);
	print(numorders.." Workorders Saved");

end

function GMIframe:followers()

	followers = C_Garrison.GetFollowers();
	local follow = {};
	for i = 1, #followers do
		if (followers[i].isCollected) then
			follow[i] = followers[i];
			if (not follow[i].abilities) then
				follow[i].abilities = C_Garrison.GetFollowerAbilities(followers[i].followerID);
			end
		end
	end
	GMI.db[GMI.Server][GMI.Char]["Followers"] = follow;
	local numfollow = tablelength(follow);
	print(numfollow.." Followers Saved");
end

function GMIframe:test()

	GMI.db["ATestMissions"] = {};
	
	local gmirewards = {};
	
	for i = 0, 10000 do
		gmirewards[i] =  C_Garrison.GetBasicMissionInfo(i);
		print(i.." mission count");
	end
	GMI.db["ATestMissions"] = gmirewards;
end

function GMIframe:Garrison()

	--GMI.db[GMI.Server][GMI.Char]["Garrison"] = nil;
	if(UnitLevel("player") < 91 ) then
		GMI.db[GMI.Server][GMI.Char]["Garrison"]=nil; return;
	end
	GMI.db[GMI.Server][GMI.Char]["Garrison"] = {};
	
	local items = C_Garrison.GetLandingPageItems() or {};
	local numItems = #items;

	
	local garrison = {};
	
	for i = 1, numItems do
		local item = items[i];
		--print(item.name.." - "..item.timeLeft);
		--adding fallower stuff??
		if ( item.followers ) then
			for f=1, #item.followers do
				local followerID = item.followers[f];
				local followerInfo = C_Garrison.GetFollowerInfo(followerID);
				item.followers[f]=followerInfo;
				if (not item.followers[f].abilities) then
					item.followers[f].abilities = C_Garrison.GetFollowerAbilities(followerID);
				end
				--item.traits = C_Garrison.GetFollowersTraitsForMission(item.missionID);
			end
		end
		garrison[i] = item;
		
	end
		local nummissions = tablelength(garrison);
		print(nummissions.." Missions Saved");
	GMI.db[GMI.Server][GMI.Char]["Garrison"] = garrison;
	GMI.db[GMI.Server][GMI.Char]['timestamp'] = time();

end

function GMIframe:Print(...)
	print("|cff33ff99Missions|r:", ...)
end

--[Str2Ary] str
GMIframe.Str2Ary = function(str)
	local tab={};
	if(not str ) then return end
	str = strtrim(str);
	while( str and str ~="" ) do
		local word,string;
		if( strfind(str, '^|c.+|r') ) then
			_,_,word,string = strfind( str, '^(|c.+|r)(.*)');
		elseif( strfind(str, '^"[^"]+"') ) then
			_,_,word,string = strfind( str, '^"([^"]+)"(.*)');
		else
			_,_,word,string = strfind( str, '^(%S+)(.*)');
		end
		if( word ) then
			table.insert(tab,word);
		end
		if( string ) then
			string=strtrim(string);
		end
		str = string;
	end
	return tab;
end
function tablelength(T)
	local count = 0
	for _ in pairs(T) do
		count = count + 1
	end
	return count
end 