
-- EnlightenmentPolicyChanges.sql
-- Created using Sublime Text, by Steven A. Warren (ScottishRamblyMan), on 19/11/2016
-- Related File: EnlightenmentPolicyDescriptionUpdates.xml, Location: Root\Text

/*
	'The Enlightenment' Civic unlocks 3 Policies:
		- Rationalism (+100% Science from Campus district buildings)
		- Free Market (+100% Gold yield from Commercial Hub district buildings)
		- Liberalism  (+1 Amenity to all cities with at least 2 specialty districts)
	
	The changes below increase these bonuses five-fold (to facilitate a faster paced end-game). Additionally,
	the descriptions of these Policies are updated to reflect the changes. This discription is displayed on hovering, 
	as well as in the Civilopedia.
*/

-- Rationalism
UPDATE ModifierArguments SET Value='500' WHERE ModifierId='RATIONALISM_DOUBLELIBRARY' AND Name='Amount';
UPDATE ModifierArguments SET Value='500' WHERE ModifierId='RATIONALISM_DOUBLEUNIVERSITY' AND Name='Amount';
UPDATE ModifierArguments SET Value='500' WHERE ModifierId='RATIONALISM_DOUBLERESEARCHLABS' AND Name='Amount';

-- Free Market
UPDATE ModifierArguments SET Value='500' WHERE ModifierId='FREEMARKET_DOUBLEMARKET' AND Name='Amount';
UPDATE ModifierArguments SET Value='500' WHERE ModifierId='FREEMARKET_DOUBLEBANK' AND Name='Amount';
UPDATE ModifierArguments SET Value='500' WHERE ModifierId='FREEMARKET_DOUBLESTOCKEXCHANGE' AND Name='Amount';

-- Liberalism
UPDATE ModifierArguments SET Value='5' WHERE ModifierId='LIBERALISM_SPECIALTYAMENITY' AND Name='Amount';

