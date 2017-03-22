-- Created by HellBlazer 03/11/16

-- remove all other maps
DELETE FROM Maps;

-- Add HB HexMap to maps table (So it shows in drop down selection for map)
INSERT INTO Maps (File, Name, Description, SortIndex) VALUES ('LiquidHexMap.lua','Team Liquid Hex Map','Team Liquid Hex Map For Competitive Play','5');

INSERT INTO MapSizes (Domain, MapSizeType, Name, Description, MinPlayers, MaxPlayers, DefaultPlayers, SortIndex) VALUES
	('StandardMapSizes', 'MAPSIZE_HEX', 'Team Liquid Hex Map', 'Hex Mirror Map For Competitive Play', '6', '7', '6', '5');

-- remove all map sizes but the team liquid size
DELETE FROM MapSizes WHERE MapSizeType = 'MAPSIZE_DUEL' or MapSizeType = 'MAPSIZE_TINY' or MapSizeType = 'MAPSIZE_SMALL' or MapSizeType = 'MAPSIZE_STANDARD' or MapSizeType = 'MAPSIZE_LARGE' or MapSizeType = 'MAPSIZE_HUGE';

-- remove start position and resources from the selection screen
UPDATE Parameters SET Visible = '0' WHERE ParameterId = 'StartPosition' or ParameterId = 'Resources' or ParameterId = 'NoGoodyHuts' or ParameterId = 'NoBarbarians';
UPDATE Parameters SET DefaultValue = '1' WHERE ParameterId = 'NoGoodyHuts' or ParameterId = 'NoBarbarians';


INSERT INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, Hash, SortIndex) VALUES
	('Map','LiquidHexMap.lua','LQRivers','Rivers','Enable Random Rivers','LQRivers','0','Map','LQRivers','MapOptions','0','290');

INSERT INTO DomainValues (Domain, Value, Name, Description, SortIndex) VALUES
	('LQRivers','0','Disabled','No Rivers On Map', '1'),
	('LQRivers','1','Enabled','Rivers Enabled And Spawn Randomly Acorss The Whole Map', '2');