function Initialize()
  if (Game.GetLocalPlayer() ~= -1) then
    numPlayers = PlayerManager.GetAliveMajorsCount();
   		
    if numPlayers == 7 then
      local pVis = PlayersVisibility[6];
      for iPlotIndex = 0, Map.GetPlotCount()-1, 1 do
        --Set 2nd argument to to 1 to reveal all, Set to 0 to lead fog of war and avoid leader intros
        pVis:ChangeVisibilityCount(iPlotIndex, 1); 
      end
    end
  end

  print("-- Observer Remove Warrior!");
  --remove the warrior
  local pPlayer:table = Players[6];

  if (pPlayer) then
    local pPlayerUnits:table = pPlayer:GetUnits();

    if (pPlayerUnits) then
      for i, pUnit in pPlayerUnits:Members() do
          pPlayer:GetUnits():Destroy(pUnit)
      end
    end
  end
end
Initialize();