------------------------------------------------------------------------------
--	FILE:	 Pangaea.lua
--	AUTHOR:  
--	PURPOSE: Base game script - Simulates a Pan-Earth Supercontinent.
------------------------------------------------------------------------------
--	Copyright (c) 2014 Firaxis Games, Inc. All rights reserved.
------------------------------------------------------------------------------

include "MapEnums"
include "MapUtilities"
include "MountainsCliffs"
include "RiversLakes"
include "FeatureGenerator"
include "TerrainGenerator"
include "NaturalWonderGenerator"
include "ResourceGenerator"
include "AssignStartingPlots"

local g_iW, g_iH = 50,45;
local g_iFlags = {};
local g_continentsFrac = nil;
local g_iNumTotalLandTiles = 0; 
local mTiles = {};
local iM = 1;
-------------------------------------------------------------------------------
function GenerateMap()
	print("Generating Liquid Map");

	local pPlot;
	-- Set globals
	g_iW, g_iH = Map.GetGridSize();

	print("########################## MAP SIZE " .. g_iW .. "," .. g_iH .. " ########################## ");
	
	--for row in GameInfo.Maps() do
	--	print(row.MapSizeType);
	--end
	

	g_iFlags = TerrainBuilder.GetFractalFlags();
	local temperature = 2; --MapConfiguration.GetValue("temperature"); -- Default setting is Temperate.
	if temperature == 4 then
		temperature  =  1 + TerrainBuilder.GetRandomNumber(3, "Random Temperature- Lua");
	end
	
	--bShift = -0.2;
	
	local allcomplete = false;

	while allcomplete == false do
		plotTypes = GeneratePlotTypes();

		--check to make sure map has not failed
		local iNumLandTilesInUse = 0;
		local iW, iH = Map.GetGridSize();
		local iPercent = (iW * iH) * 0.10;

		for y = 0, iH - 1 do
			for x = 0, iW - 1 do
				local i = iW * y + x;
				--print("PlotType", plotTypes[i])
				if plotTypes[i] ~= g_PLOT_TYPE_OCEAN then
					iNumLandTilesInUse = iNumLandTilesInUse + 1;
				end
			end
		end
 
		--print("######### Map Failure Check #########");
		--print("30% Of Map Area: ", iPercent);
		--print("Map Land Tiles: ", iNumLandTilesInUse);

		--if iNumLandTilesInUse >= iPercent then
			allcomplete = true;
		--	print("######### Map Pass #########");
		--else
		--	print("######### Map Failure #########");
		--end
		--[[
		for i = 1, iM - 1 do
			
			local iPlot = mTiles[i];
			--print("AddingMountain: " .. iPlot);
			plotTypes[iPlot] = g_PLOT_TYPE_MOUNTAIN;
		end

		for i = 65, 81 do
			plotTypes[i] = g_PLOT_TYPE_MOUNTAIN;
		end

		for i = 1829, 1845 do
			plotTypes[i] = g_PLOT_TYPE_MOUNTAIN;
		end
		--]]
	end

	terrainTypes = GenerateTerrainTypes(plotTypes, g_iW, g_iH, g_iFlags, true, temperature, bShift);

	for i = 0, (g_iW * g_iH) - 1, 1 do
		pPlot = Map.GetPlotByIndex(i);
		if (plotTypes[i] == g_PLOT_TYPE_HILLS) then
			terrainTypes[i] = terrainTypes[i] + 1;
		end
		TerrainBuilder.SetTerrainType(pPlot, terrainTypes[i]);
	end

	-- Temp
	AreaBuilder.Recalculate();

	local biggest_area = Areas.FindBiggestArea(false);
	print("After Adding Hills: ", biggest_area:GetPlotCount());

	-- River generation is affected by plot types, originating from highlands and preferring to traverse lowlands.
	local bRivers = MapConfiguration.GetValue("LQRivers");
	print("==============================================   " .. bRivers .. "   ==============================================");
	if (bRivers == "1") then
		AddRivers();
	end
	
	-- Lakes would interfere with rivers, causing them to stop and not reach the ocean, if placed any sooner.
	local numLargeLakes = math.ceil(GameInfo.Maps[Map.GetMapSize()].Continents * 1.5);
	--AddLakes(numLargeLakes);

	AddFeatures();
	
	print("Adding cliffs");
	--AddCliffs(plotTypes, terrainTypes);
	
	local args = {
		numberToPlace = GameInfo.Maps[Map.GetMapSize()].NumNaturalWonders,
	};

	local nwGen = NaturalWonderGenerator.Create(args);

	AreaBuilder.Recalculate();
	TerrainBuilder.AnalyzeChokepoints();
	TerrainBuilder.StampContinents();
	
	resourcesConfig = 2; --MapConfiguration.GetValue("resources");
	local args = {
		resources = resourcesConfig,
		bLandBias = true,
	}
	local resGen = ResourceGenerator.Create(args);

	-- remove ice
	--for x = 0, g_iW do
	--	for y = 0, g_iH-2 do
	--		local i = y * g_iW + x + 1;
	--		if terrainTypes[i] == g_TERRAIN_TYPE_COAST then
	--			print("Removingcoast: " .. i);
	--			plotTypes[i] = g_PLOT_TYPE_OCEAN;
	--		end
	--	end
	--end
	
	--mirror the map
	
	print("---------------------------------------------------------------------------------")

	for tRows = 1, #mTiles, 2 do

		local iRStart = mTiles[tRows];
		local iREnd = mTiles[tRows+1];
		
		local iLoops = math.ceil((iREnd-iRStart)/2);
		local iHalf = iLoops+iRStart;
		
		print("Start: " .. iRStart .. " Half: " .. iHalf .. " Loops: " , iLoops);

		for ip = 0, (iLoops-1) do
			ipc = iREnd-ip;
			ipo = iRStart+ip;

			--print("Setting Tile: " .. ipc .. " To Tile: " .. ipo);
			
			local plot = Map.GetPlotByIndex(ipo);
			local plotc = Map.GetPlotByIndex(ipc);

			local featureType = plot:GetFeatureType();
			
			local resourceType = plot:GetResourceType(ipo);

			local terrainType = plot:GetTerrainType();

			print("Tile Feature: " .. featureType .. " Tile Resource: " .. resourceType);

			plotTypes[ipc] = plotTypes[ipo];
			terrainTypes[ipc] = terrainTypes[ipo];

			TerrainBuilder.SetTerrainType(ipc, terrainType); --terrainTypes[ipo]);
			TerrainBuilder.SetFeatureType(plotc, featureType);
			ResourceBuilder.SetResourceType(plotc, resourceType, 1);

			--fix jungles
			if featureType == g_FEATURE_JUNGLE then
				if(terrainType == g_TERRAIN_TYPE_PLAINS_HILLS or terrainType == g_TERRAIN_TYPE_GRASS_HILLS) then
					TerrainBuilder.SetTerrainType(plotc, g_TERRAIN_TYPE_PLAINS_HILLS);
				else
					TerrainBuilder.SetTerrainType(plotc, g_TERRAIN_TYPE_PLAINS);
				end
			end
		end
	end

		
	-- make sure the 6 starting locations have no features
	playerStarts = {};
	
	--team 1 (west)
	playerStarts[0] = 29 * g_iW + 20; --1295;
	playerStarts[1] = 22 * g_iW + 18; --948;
	playerStarts[2] = 15 * g_iW + 20; --609;
	
	--team 2 (east)
	playerStarts[3] = 29 * g_iW + 28; --1302;
	playerStarts[4] = 22 * g_iW + 31; --962;
	playerStarts[5] = 15 * g_iW + 28; --616;

	for i = 0, 5 do
		pPlot = playerStarts[i];
		
		local plotc = Map.GetPlotByIndex(pPlot);

		plotTypes[pPlot] = g_PLOT_TYPE_HILLS;
		terrainTypes[pPlot] = g_TERRAIN_TYPE_PLAINS_HILLS;
		TerrainBuilder.SetTerrainType(pPlot, g_TERRAIN_TYPE_PLAINS_HILLS);
		TerrainBuilder.SetFeatureType(plotc, g_FEATURE_NONE);
		ResourceBuilder.SetResourceType(plotc, -1, 1);
	end
	print("---------------------------------------------------------------------------------")

	local plotZ = Map.GetPlotByIndex(0);
	plotTypes[0] = g_PLOT_TYPE_OCEAN;
	terrainTypes[0] = g_TERRAIN_TYPE_OCEAN;
	TerrainBuilder.SetTerrainType(0, g_TERRAIN_TYPE_OCEAN);

	AreaBuilder.Recalculate();
--	for i = 0, (g_iW * g_iH) - 1, 1 do
--		pPlot = Map.GetPlotByIndex(i);
--		print ("i: plotType, terrainType, featureType: " .. tostring(i) .. ": " .. tostring(plotTypes[i]) .. ", " .. tostring(terrainTypes[i]) .. ", " .. tostring(pPlot:GetFeatureType(i)));
--	end

	print("Creating start plot database.");
	-- START_MIN_Y and START_MAX_Y is the percent of the map ignored for major civs' starting positions.
	local startConfig = 2; --MapConfiguration.GetValue("start");-- Get the start config
	local args = {
		MIN_MAJOR_CIV_FERTILITY = 400,
		MIN_MINOR_CIV_FERTILITY = 50, 
		MIN_BARBARIAN_FERTILITY = 1,
		START_MIN_Y = 20,
		START_MAX_Y = 20,
		START_CONFIG = startConfig,
		LAND = true,
	};

	
	local start_plot_database = AssignStartingPlots.Create(args)

	--local GoodyGen = AddGoodies(g_iW, g_iH);

	-- fix warrior spawns
	local iUnitTypeWarrior = 19;
	local iUnitTypeSettler = 0;
	for i = 0, 5 do
		
		local iPstart = playerStarts[i];

		local pPlot = Map.GetPlotByIndex(iPstart);
		Players[i]:GetUnits():Create(iUnitTypeWarrior, pPlot:GetX(), pPlot:GetY());
		Players[i]:GetUnits():Create(iUnitTypeSettler, pPlot:GetX(), pPlot:GetY());
	end
end

-------------------------------------------------------------------------------
function fillplots(plotTypes, iStart, iEnd, y, iW)

	local is = y * iW + iStart;
	local ie = y * iW + iEnd;

	mTiles[iM] = is;
	iM = iM + 1;
	mTiles[iM] = ie
	iM = iM + 1;

	for x = iStart, iEnd do
		local i = y * iW + x;
		plotTypes[i] = g_PLOT_TYPE_LAND;
	end
end

-------------------------------------------------------------------------------
function addedgemountains(plotTypes, iW, iH)

	local iStart = 15;
	local iEnd = 33;
	local HexStep = false;
	local centerX = math.floor(iW/2);
	local centerY = math.floor(iH/2);
	--[[
	for x = 0, iW - 1 do
		for y = 0, iH - 1 do
			local plot = Map.GetPlot(x, y)
			local i = y * iW + x + 1;
				print("CoastCheck")
			if plot:IsCoastalLand() then
				print("AddingMountain: " .. x .. "," .. y);
				--plot:SetPlotType(g_PLOT_TYPE_MOUNTAIN, false, true);
				plotTypes[i] = g_PLOT_TYPE_MOUNTAIN;
				--terrainTypes[i] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;
			end
		end
	end
	--]]
	--[[
	for y = 1, centerY do

		print("AddingMountain");
		terrainTypes[iStart] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;
		terrainTypes[iEnd] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;

 		if (HexStep) then
			iStart = iStart - 1;
		else
			iEnd = iEnd + 1
		end

		HexStep = not(HexStep);
	end

	local iStart = 7;
	local iEnd = 42;

	local HexStep = false;
	for y = centerY+1, iH-2 do
		
		terrainTypes[iStart] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;
		terrainTypes[iEnd] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;

		if (HexStep) then
			iStart = iStart + 1;
		else
			iEnd = iEnd - 1
		end

		HexStep = not(HexStep);
	end]]

	return plotTypes;
end

-------------------------------------------------------------------------------
function GetMapInitData(worldSize)
	-- This function can reset map grid sizes or world wrap settings.
	return {
		Width = 50,
		Height = 45,
		WrapX = true,
	}      
end

-------------------------------------------------------------------------------
function GeneratePlotTypes()
	print("Generating Plot Types");
	local plotTypes = {};
	--local iWidth, iHeight = 74, 74;

	local sea_level_low = 48;
	local sea_level_normal = 53;
	local sea_level_high = 58;
	local world_age_old = 2;
	local world_age_normal = 3;
	local world_age_new = 5;

	local grain_amount = 3;
	local adjust_plates = 1.3;
	local shift_plot_types = true;
	local tectonic_islands = true;
	local hills_ridge_flags = g_iFlags;
	local peaks_ridge_flags = g_iFlags;
	local has_center_rift = false;
	
	--	local world_age
	local world_age = 2; --MapConfiguration.GetValue("world_age");
	if (world_age == 1) then
		world_age = world_age_new;
	elseif (world_age == 2) then
		world_age = world_age_normal;
	elseif (world_age == 3) then
		world_age = world_age_old;
	else
		world_age = 2 + TerrainBuilder.GetRandomNumber(4, "Random World Age - Lua");
	end

	--	local sea_level
    local sea_level =  2; --MapConfiguration.GetValue("sea_level");
	local water_percent;
	if sea_level == 1 then -- Low Sea Level
		water_percent = sea_level_low
	elseif sea_level == 2 then -- Normal Sea Level
		water_percent =sea_level_normal
	elseif sea_level == 3 then -- High Sea Level
		water_percent = sea_level_high
	else
		water_percent = TerrainBuilder.GetRandomNumber(sea_level_high - sea_level_low, "Random Sea Level - Lua") + sea_level_low + 1; 
	end

	-- Generate continental fractal layer and examine the largest landmass. Reject
	-- the result until the largest landmass occupies 100% or more of the total land.

	local iW, iH = Map.GetGridSize();
	print("WIDTH: ", iW);
	-- Fill all rows with water plots.
	plotTypes = table.fill(g_PLOT_TYPE_OCEAN, iW * iH);
	
	-- generate hex of land
	local centerX = math.floor(iW/2);
	local centerY = math.floor(iH/2);
	local HexRow = 9;
	local HexStep = false;

	local iStart = 15;
	local iEnd = 33;

	--print("Center X: " .. centerX);
	--print("Center Y: " .. centerY);

	for y = 3, centerY do
		fillplots(plotTypes, iStart, iEnd, y, iW);

		if (HexStep) then
			iStart = iStart - 1;
		else
			iEnd = iEnd + 1
		end

		HexStep = not(HexStep);
	end

	local iStart = 6;
	local iEnd = 42;

	local HexStep = true;
	for y = centerY+1, iH-5 do
		fillplots(plotTypes, iStart, iEnd, y, iW);

		if (HexStep) then
			iStart = iStart + 1;
		else
			iEnd = iEnd - 1
		end

		HexStep = not(HexStep);
	end

	local args = {};
	args.world_age = world_age;
	args.iW = g_iW;
	args.iH = g_iH
	args.iFlags = g_iFlags;
	args.blendRidge = 10;
	args.blendFract = 1;
	args.extra_mountains = 4;
	plotTypes = ApplyTectonics(args, plotTypes);
	
	local mRatioVal = 2; --MapConfiguration.GetValue("MountDensity");
	
	mRatio = 15;
	if (mRatioVal == 1) then
		mRatio = 20;
	elseif (mRatioVal == 3) then
		mRatio = 10;
	end
	
	--print("Mount Ratio: ", mRatio)
	
	--plotTypes = AddLonelyMountains(plotTypes, mRatio);
	
	return plotTypes;
end

function InitFractal(args)

	if(args == nil) then args = {}; end

	local continent_grain = args.continent_grain or 2;
	local rift_grain = args.rift_grain or -1; -- Default no rifts. Set grain to between 1 and 3 to add rifts. - Bob
	local invert_heights = args.invert_heights or false;
	local polar = args.polar or true;
	local ridge_flags = args.ridge_flags or g_iFlags;

	local fracFlags = {};
	
	if(invert_heights) then
		fracFlags.FRAC_INVERT_HEIGHTS = true;
	end
	
	if(polar) then
		fracFlags.FRAC_POLAR = true;
	end
	
	if(rift_grain > 0 and rift_grain < 4) then
		local riftsFrac = Fractal.Create(g_iW, g_iH, rift_grain, {}, 6, 5);
		g_continentsFrac = Fractal.CreateRifts(g_iW, g_iH, continent_grain, fracFlags, riftsFrac, 6, 5);
	else
		g_continentsFrac = Fractal.Create(g_iW, g_iH, continent_grain, fracFlags, 6, 5);	
	end

	-- Use Brian's tectonics method to weave ridgelines in to the continental fractal.
	-- Without fractal variation, the tectonics come out too regular.
	--
	--[[ "The principle of the RidgeBuilder code is a modified Voronoi diagram. I 
	added some minor randomness and the slope might be a little tricky. It was 
	intended as a 'whole world' modifier to the fractal class. You can modify 
	the number of plates, but that is about it." ]]-- Brian Wade - May 23, 2009
	--
	local MapSizeTypes = {};
	for row in GameInfo.Maps() do
		MapSizeTypes[row.MapSizeType] = row.PlateValue;
	end
	local sizekey = Map.GetMapSize();

	local numPlates = MapSizeTypes[sizekey] or 4

	-- Blend a bit of ridge into the fractal.
	-- This will do things like roughen the coastlines and build inland seas. - Brian

	g_continentsFrac:BuildRidges(numPlates, {}, 1, 2);
end

function AddFeatures()
	print("Adding Features");

	-- Get Rainfall setting input by user.
	local rainfall = 2; --MapConfiguration.GetValue("rainfall");
	if rainfall == 4 then
		rainfall = 1 + TerrainBuilder.GetRandomNumber(3, "Random Rainfall - Lua");
	end
	
	local args = {rainfall = rainfall}
	local featuregen = FeatureGenerator.Create(args);

	featuregen:AddFeatures(true);
end
