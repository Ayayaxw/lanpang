if GameSetup == nil then
    GameSetup = class({})
  end
  
  --nil will not force a hero selection
  --local forceHero = nil --"templar_assassin"--
local forceHero = "axe"
  




  
function GameSetup:init()
  -- 基础游戏规则设置（共同部分）
  GameRules:EnableCustomGameSetupAutoLaunch(true)
  GameRules:SetCustomGameSetupAutoLaunchDelay(0)
  GameRules:SetHeroSelectionTime(100)
  GameRules:SetStrategyTime(100)
  GameRules:SetPreGameTime(0)
  GameRules:SetShowcaseTime(0)
  GameRules:SetPostGameTime(5)
  GameRules:SetUseUniversalShopMode(true)

  local GameMode = GameRules:GetGameModeEntity()

  -- 禁用各种效果（共同部分）
  
  GameMode:SetAnnouncerDisabled(true)
  GameMode:SetKillingSpreeAnnouncerDisabled(true)
  GameMode:SetDaynightCycleDisabled(true)
  GameMode:DisableHudFlip(true)
  GameMode:SetDeathOverlayDisabled(true)
  GameMode:SetWeatherEffectsDisabled(true)
  GameMode:SetGoldSoundDisabled(false)
  GameMode:SetCameraZRange(0,5000)

  -- 音乐和声音设置（共同部分）
  GameRules:SetCustomGameAllowHeroPickMusic(false)
  GameRules:SetCustomGameAllowMusicAtGameStart(false)
  GameRules:SetCustomGameAllowBattleMusic(false)
  GameRules:SetStartingGold(0)
  GameRules:SetCustomGameAllowMusicAtGameStart(false)
  GameRules:SetSameHeroSelectionEnabled(true)


  -- 调试模式特有的设置
  if IsInToolsMode() then
      GameRules:SetTreeRegrowTime(5)
      GameRules:SetCreepSpawningEnabled(false)
  end

  -- 强制英雄选择（共同部分）
  if forceHero ~= nil then
      GameMode:SetCustomGameForceHero(forceHero)
  end

  -- 事件监听（共同部分）
  ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnStateChange"), self)
end

  
  function GameSetup:OnStateChange()
    --random hero once we reach strategy phase
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_STRATEGY_TIME then
      GameSetup:RandomForNoHeroSelected()
    end
  end
  
  
  function GameSetup:RandomForNoHeroSelected()
      --NOTE: GameRules state must be in HERO_SELECTION or STRATEGY_TIME to pick heroes
      --loop through each player on every team and random a hero if they haven't picked
    local maxPlayers = 5
    for teamNum = DOTA_TEAM_GOODGUYS, DOTA_TEAM_BADGUYS do
      for i=1, maxPlayers do
        local playerID = PlayerResource:GetNthPlayerIDOnTeam(teamNum, i)
        if playerID ~= nil then
          if not PlayerResource:HasSelectedHero(playerID) then
            local hPlayer = PlayerResource:GetPlayer(playerID)
            if hPlayer ~= nil then
              hPlayer:MakeRandomHeroSelection()
            end
          end
        end
      end
    end
  end