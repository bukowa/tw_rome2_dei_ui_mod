local lib_logging = require "script._lib.lib_logging"
local scripting = require "lua_scripts.EpisodicScripting"

local logger = lib_logging.new_logger("event_list_table_logging.txt", "DEBUG")

local function logit(event_name, context)
    logger:debug(event_name)

    if context.component == nil then
        -- If component is nil, handle accordingly
        local context_string = context.string or "(nil context.string)"
        logger:debug(" context: " .. context_string)
        return
    end

    local c = UIComponent(context.component)
    local context_string = context.string or "(nil context.string)"
    local state = c:CurrentState() or "(nil state)"

    -- Log the event with safe values
    logger:debug(" component: " .. context_string .. " state: " .. state)
end

local function addEventLogger(event_name)

    if event_name == "TimeTrigger" then
        return
    end

    local function callback(context)
        logger:debug("=============================================================")
        logger:pcall(function() logit(event_name, context) end)
        logger:debug("=============================================================")
    end

    scripting.AddEventCallBack(event_name, callback)
end

local event_list = {
    "AdviceDismissed",
    "AdviceFinishedTrigger",
    "AdviceIssued",
    "AdviceSuperseded",
    "AreaCameraEntered",
    "AreaEntered",
    "AreaExited",
    "ArmyBribeAttemptFailure",
    "ArmySabotageAttemptFailure",
    "ArmySabotageAttemptSuccess",
    "AssassinationAttemptCriticalSuccess",
    "AssassinationAttemptFailure",
    "AssassinationAttemptSuccess",
    "BattleBoardingActionCommenced",
    "BattleCommandingShipRouts",
    "BattleCommandingUnitRouts",
    "BattleCompleted",
    "BattleConflictPhaseCommenced",
    "BattleDeploymentPhaseCommenced",
    "BattleFortPlazaCaptureCommenced",
    "BattleShipAttacksEnemyShip",
    "BattleShipCaughtFire",
    "BattleShipMagazineExplosion",
    "BattleShipRouts",
    "BattleShipRunAground",
    "BattleShipSailingIntoWind",
    "BattleShipSurrendered",
    "BattleUnitAttacksBuilding",
    "BattleUnitAttacksEnemyUnit",
    "BattleUnitAttacksWalls",
    "BattleUnitCapturesBuilding",
    "BattleUnitDestroysBuilding",
    "BattleUnitRouts",
    "BattleUnitUsingBuilding",
    "BattleUnitUsingWall",
    "BuildingCardSelected",
    "BuildingCompleted",
    "BuildingConstructionIssuedByPlayer",
    "BuildingInfoPanelOpenedCampaign",
    "CameraMoverCancelled",
    "CameraMoverFinished",
    "CampaignArmiesMerge",
    "CampaignBuildingDamaged",
    "CampaignCoastalAssaultOnCharacter",
    "CampaignCoastalAssaultOnGarrison",
    "CampaignEffectsBundleAwarded",
    "CampaignSettlementAttacked",
    "CharacterAttacksAlly",
    "CharacterBecomesFactionLeader",
    "CharacterBesiegesSettlement",
    "CharacterBlockadedPort",
    "CharacterBrokePortBlockade",
    "CharacterBuildingCompleted",
    "CharacterCandidateBecomesMinister",
    "CharacterCanLiberate",
    "CharacterCharacterTargetAction",
    "CharacterComesOfAge",
    "CharacterCompletedBattle",
    "CharacterCreated",
    "CharacterDamagedByDisaster",
    "CharacterDeselected",
    "CharacterDiscovered",
    "CharacterDisembarksNavy",
    "CharacterEmbarksNavy",
    "CharacterEntersAttritionalArea",
    "CharacterEntersGarrison",
    "CharacterFactionCompletesResearch",
    "CharacterGarrisonTargetAction",
    "CharacterGeneralDiedInBattle",
    "CharacterInfoPanelOpened",
    "CharacterLeavesGarrison",
    "CharacterLootedSettlement",
    "CharacterMarriage",
    "CharacterParticipatedAsSecondaryGeneralInBattle",
    "CharacterPerformsActionAgainstFriendlyTarget",
    "CharacterPoliticalAction",
    "CharacterPoliticalActionPoliticalMariage",
    "CharacterPoliticalAdoption",
    "CharacterPoliticalAssassination",
    "CharacterPoliticalBribe",
    "CharacterPoliticalDivorce",
    "CharacterPoliticalEmbezzleFunds",
    "CharacterPoliticalEntice",
    "CharacterPoliticalFlirt",
    "CharacterPoliticalGatherSupport",
    "CharacterPoliticalInsult",
    "CharacterPoliticalOrganizeGames",
    "CharacterPoliticalPartyProvoke",
    "CharacterPoliticalPartyPurge",
    "CharacterPoliticalPartySecureLoyalty",
    "CharacterPoliticalPraise",
    "CharacterPoliticalPromotion",
    "CharacterPoliticalProvoke",
    "CharacterPoliticalRumours",
    "CharacterPoliticalSecureLoyalty",
    "CharacterPoliticalSendDiplomat",
    "CharacterPoliticalSendEmissary",
    "CharacterPoliticalSendGift",
    "CharacterPoliticalSuicide",
    "CharacterPostBattleEnslave",
    "CharacterPostBattleRelease",
    "CharacterPostBattleSlaughter",
    "CharacterPromoted",
    "CharacterRankUp",
    "CharacterRankUpNeedsAncillary",
    "CharacterRelativeKilled",
    "CharacterSelected",
    "CharacterSkillPointAllocated",
    "CharacterSuccessfulArmyBribe",
    "CharacterSuccessfulConvert",
    "CharacterSuccessfulDemoralise",
    "CharacterSuccessfulInciteRevolt",
    "CharacterSurvivesAssassinationAttempt",
    "CharacterTurnEnd",
    "CharacterTurnStart",
    "CharacterWoundedInAssassinationAttempt",
    "ClanBecomesVassal",
    "ComponentCreated",
    "ComponentLClickUp",
    "ComponentMouseOn",
    "ComponentMoved",
    "ConvertAttemptFailure",
    "DemoraliseAttemptFailure",
    "DuelDemanded",
    "DummyEvent",
    "EncylopediaEntryRequested",
    "evaluate_mission",
    "EventMessageOpenedBattle",
    "EventMessageOpenedCampaign",
    "FactionAboutToEndTurn",
    "FactionBattleDefeat",
    "FactionBattleVictory",
    "FactionBecomesLiberationProtectorate",
    "FactionBecomesLiberationVassal",
    "FactionBecomesShogun",
    "FactionBecomesWorldLeader",
    "FactionBeginTurnPhaseNormal",
    "FactionCapturesKyoto",
    "FactionCapturesWorldCapital",
    "FactionCivilWarEnd",
    "FactionEncountersOtherFaction",
    "FactionFameLevelUp",
    "FactionGovernmentTypeChanged",
    "FactionLeaderDeclaresWar",
    "FactionLeaderSignsPeaceTreaty",
    "FactionPoliticsGovernmentActionTriggered",
    "FactionPoliticsGovernmentTypeChanged",
    "FactionRoundStart",
    "FactionSecessionEnd",
    "FactionSubjugatesOtherFaction",
    "FactionTurnEnd",
    "FactionTurnStart",
    "FirstTickAfterNewCampaignStarted",
    "FirstTickAfterWorldCreated",
    "FortSelected",
    "FrontendScreenTransition",
    "GarrisonAttackedEvent",
    "GarrisonOccupiedEvent",
    "GarrisonResidenceCaptured",
    "GovernorshipTaxRateChanged",
    "historical_events",
    "HistoricalCharacters",
    "HistoricalEvents",
    "HistoricBattleEvent",
    "HudRefresh",
    "InciteRevoltAttemptFailure",
    "IncomingMessage",
    "LandTradeRouteRaided",
    "LoadingGame",
    "LoadingScreenDismissed",
    "LocationEntered",
    "LocationUnveiled",
    "MapIconMoved",
    "MissionCancelled",
    "MissionCheckAssassination",
    "MissionCheckBlockadePort",
    "MissionCheckBuild",
    "MissionCheckCaptureCity",
    "MissionCheckDuel",
    "MissionCheckEngageCharacter",
    "MissionCheckEngageFaction",
    "MissionCheckGainMilitaryAccess",
    "MissionCheckMakeAlliance",
    "MissionCheckMakeTradeAgreement",
    "MissionCheckRecruit",
    "MissionCheckResearch",
    "MissionCheckSpyOnCity",
    "MissionEvaluateAssassination",
    "MissionEvaluateBlockadePort",
    "MissionEvaluateBuild",
    "MissionEvaluateCaptureCity",
    "MissionEvaluateDuel",
    "MissionEvaluateEngageCharacter",
    "MissionEvaluateEngageFaction",
    "MissionEvaluateGainMilitaryAccess",
    "MissionEvaluateMakeAlliance",
    "MissionEvaluateMakeTradeAgreement",
    "MissionEvaluateRecruit",
    "MissionEvaluateResearch",
    "MissionEvaluateSpyOnCity",
    "MissionFailed",
    "MissionIssued",
    "MissionNearingExpiry",
    "MissionSucceeded",
    "ModelCreated",
    "MovementPointsExhausted",
    "MPLobbyChatCreated",
    "MultiTurnMove",
    "NewCampaignStarted",
    "NewSession",
    "PanelAdviceRequestedBattle",
    "PanelAdviceRequestedCampaign",
    "PanelClosedBattle",
    "PanelClosedCampaign",
    "PanelOpenedBattle",
    "PanelOpenedCampaign",
    "PendingBankruptcy",
    "PendingBattle",
    "PositiveDiplomaticEvent",
    "PreBattle",
    "RecruitmentItemIssuedByPlayer",
    "RegionChangedFaction",
    "RegionGainedDevlopmentPoint",
    "RegionIssuesDemands",
    "RegionRebels",
    "RegionRiots",
    "RegionSelected",
    "RegionStrikes",
    "RegionTurnEnd",
    "RegionTurnStart",
    "ResearchCompleted",
    "ResearchStarted",
    "SabotageAttemptFailure",
    "SabotageAttemptSuccess",
    "SavingGame",
    "ScriptedAgentCreated",
    "ScriptedAgentCreationFailed",
    "ScriptedCharacterUnhidden",
    "ScriptedCharacterUnhiddenFailed",
    "ScriptedForceCreated",
    "SeaTradeRouteRaided",
    "SettlementDeselected",
    "SettlementOccupied",
    "SettlementSelected",
    "ShortcutTriggered",
    "SiegeLifted",
    "SlotOpens",
    "SlotRoundStart",
    "SlotSelected",
    "SlotTurnStart",
    "StartRegionPopupVisible",
    "StartRegionSelected",
    "TechnologyInfoPanelOpenedCampaign",
    "TestEvent",
    "TimeTrigger",
    "TooltipAdvice",
    "TouchUsed",
    "TradeLinkEstablished",
    "TradeNodeConnected",
    "TradeRouteEstablished",
    "UICreated",
    "UIDestroyed",
    "UngarrisonedFort",
    "UnitCompletedBattle",
    "UnitCreated",
    "UnitSelectedCampaign",
    "UnitTrained",
    "UnitTurnEnd",
    "VictoryConditionFailed",
    "VictoryConditionMet",
    "WorldCreated",
}

local function addAllEventLoggers()
    for _, event_name in ipairs(event_list) do
        addEventLogger(event_name)
    end
end

return {
    event_list = event_list,
    addEventLogger = addEventLogger,
    addAllEventLoggers = addAllEventLoggers,
}
