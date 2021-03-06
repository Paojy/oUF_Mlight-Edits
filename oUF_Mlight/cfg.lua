﻿local ADDON_NAME, ns = ...
local cfg = CreateFrame("Frame")

---------------------------------------------------------------------------------------
-------------------[[        Config        ]]------------------------------------------ 
---------------------------------------------------------------------------------------
-- media
cfg.mediaPath = "Interface\\AddOns\\oUF_Mlight\\media\\"
cfg.texture = "Interface\\Buttons\\WHITE8x8"
cfg.highlighttexture = "Interface\\Buttons\\WHITE8x8"
cfg.font, cfg.fontflag = "Interface\\Addons\\sharedmedia\\fonts\\font.TTF", "OUTLINEMONOCHROME"
cfg.glowTex = "Interface\\ChatFrame\\ChatFrameBackground"
cfg.fontsize = 8

-- color mode
-- health colored based on class/disable to make health colored based on percentage
-- power colored based on power type/disable to make power colored based on class
cfg.classcolormode = false

-- size
cfg.height, cfg.width = 16, 229--height and width for player,focus and target
cfg.width1 = 70 -- width for pet and tot
cfg.width2 = 150 -- width for boss 1-5
cfg.scale = 1.0
cfg.hpheight = .90 -- hpheight/unitheight

-- postion
cfg.playerpos = {"CENTER","UIParent","CENTER", -278, -142}
cfg.petpos = {"LEFT","oUF_MlightPlayer","LEFT", -76, 0}
cfg.targetpos = {"CENTER","UIParent","CENTER", 278, -142}
cfg.totpos = {"RIGHT","oUF_MlightTarget","RIGHT", 76, 0}
cfg.focuspos = {"TOPLEFT","UIParent","CENTER", 168, 50}
cfg.focustarget = {"RIGHT","oUF_MlightFocus","RIGHT", 76, 0}
cfg.boss1pos = {"TOPRIGHT","UIParent","TOPRIGHT", -22, -200}
cfg.bossspace = 42

-- castbar
cfg.castbars = true   -- disable all castbars
cfg.cbIconsize = 35
cfg.uninterruptable = {1, 0, 0, 0.1}

-- auras
cfg.auras = true  -- disable all auras
cfg.auraborders = true -- auraborder colored based on debuff type
cfg.auraperrow = 7 -- number of auras each row, this control the size of icon
cfg.AuraFilter = { -- target and focus
	ignoreBuff = true, -- hide others' buff on friend
	ignoreDebuff = false, -- hide others' debuff on enemy
	whitelist = {  -- show auras in whitelist if they are hidden by rules above
		--[589] = true, -- sw:pain test
		--[588] = true, -- inner fire test
		},
}

-- show/hide unit
-- boss
cfg.bossframes = true

-- raid/party
cfg.enableraid = true
cfg.raidfontsize = 8 -- the fontsize of raid/party members' name
cfg.showsolo = false -- show raidframe when solo?

cfg.toggle = true
 -- Set Raidframemode(healer/dpstank) when Specialization changes.
 -- You can also use /rf to switch between them.
 -- healer mode(5*5)
cfg.healerraidposition = {"BOTTOM", UIParent, "BOTTOM", 0, 108}
cfg.healerraidheight, cfg.healerraidwidth = 32, 58
cfg.anchor = "TOP"
cfg.partyanchor = "LEFT"
cfg.showgcd = false
cfg.showarrow = false
	cfg.arrowscale = 1.0
cfg.healprediction = true
	cfg.myhealpredictioncolor = { 110/255, 210/255, 0/255, 0.5}
	cfg.otherhealpredictioncolor = { 0/255, 110/255, 0/255, 0.5}
 -- dps/tank mode(1*25)
cfg.dpsraidposition = {"TOPLEFT", UIParent, "TOPLEFT", 22, -170}
cfg.dpsraidheight, cfg.dpsraidwidth = 13, 90

---------------------------------------------------------------------------------------
-------------------[[        My         Config        ]]------------------------------- 
---------------------------------------------------------------------------------------
if GetUnitName("player") == "伤心蓝" or GetUnitName("player") == "Scarlett" then

end
  
if IsAddOnLoaded("Aurora") and IsAddOnLoaded("aCore") then
cfg.font = GameFontHighlight:GetFont()
cfg.showsolo = false
end
---------------------------------------------------------------------------------------
-------------------[[        Config        End        ]]-------------------------------  
---------------------------------------------------------------------------------------
  -- HANDOVER
  ns.cfg = cfg