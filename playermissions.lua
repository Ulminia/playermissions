GMI ={
	Version = "1.2",
	db = {},
	Char =  UnitName("player"),
	Server = GetRealmName(),
	};

local GMIframe = CreateFrame("FRAME"); -- Need a GMIframe to respond to events
local f = CreateFrame('GameTooltip', 'MyTooltip', UIParent, 'GameTooltipTemplate'); -- we load our own tooltip GMIframe

GMIframe:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
GMIframe:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out


function GMIframe:OnEvent(event, arg1)
	if event == "ADDON_LOADED" and arg1 == "playermissions" then
		GMIframe:Print('Garrison Missions v'.. GMI.Version..' Loaded');
		if playermissions == nil then
			GMI.db = {}
		end
		if playermissions then
			GMI.db = playermissions;
		end
		GMIframe:init();
	elseif event == "PLAYER_LEAVING_WORLD" then
		playermissions = GMI.db;
	elseif event == "PLAYER_LOGOUT" then	
		playermissions = GMI.db;
	end
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
	
		DEFAULT_CHAT_GMIframe:AddMessage('This is a test'..msg[1]..'-');
		
	elseif (msg[1] == "save") then
	
		GMIframe:Garrison();
		
	end
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