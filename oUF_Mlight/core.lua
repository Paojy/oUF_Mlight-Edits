local ADDON_NAME, ns = ...
local cfg = ns.cfg

local symbols = "Interface\\Addons\\oUF_Mlight\\media\\PIZZADUDEBULLETS.ttf"

oUF.colors.power["MANA"] = {.3, .8, 1}
oUF.colors.power["RAGE"] = {.9, .1, .1}
oUF.colors.power["FUEL"] = {0, 0.55, 0.5}
oUF.colors.power["FOCUS"] = {.9, .5, .1}
oUF.colors.power["ENERGY"] = {.9, .9, .1}
oUF.colors.power["AMMOSLOT"] = {0.8, 0.6, 0}
oUF.colors.power["RUNIC_POWER"] = {.1, .9, .9}
oUF.colors.power["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61}
oUF.colors.power["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17}

oUF.colors.reaction[1] = {255/255, 30/255, 60/255}
oUF.colors.reaction[2] = {255/255, 30/255, 60/255}
oUF.colors.reaction[3] = {255/255, 30/255, 60/255}
oUF.colors.reaction[4] = {1, 1, 0.3}
oUF.colors.reaction[5] = {0.26, 1, 0.22}
oUF.colors.reaction[6] = {0.26, 1, 0.22}
oUF.colors.reaction[7] = {0.26, 1, 0.22}
oUF.colors.reaction[8] = {0.26, 1, 0.22}

oUF.colors.smooth = {1,0,0, 1,1,0, 1,1,0}	

local backdrop = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {top = 0, left = 0, bottom = 0, right = 0},
}

local frameBD = {
    edgeFile = cfg.glowTex, edgeSize = 1,
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = {left = 1, right = 1, top = 1, bottom = 1}
}

local FormatValue = ns.FormatValue
local FormatTime = ns.FormatTime
local hex = ns.hex
--=============================================--
--[[                 Functions               ]]--
--=============================================--
local function multicheck(check, ...)
    for i=1, select('#', ...) do
        if check == select(i, ...) then return true end
    end
    return false
end

local createBackdrop = function(parent, anchor, a, m, c) 
    local frame = CreateFrame("Frame", nil, parent)
	
	local flvl = parent:GetFrameLevel()
	if flvl - 1 >= 0 then
    frame:SetFrameLevel(flvl-1)
	end
	
	frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -1, 1)
    frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 1, -1)
	
    frame:SetBackdrop(frameBD)
	if not c then
		frame:SetBackdropColor(.25, .25, .25, a)
		frame:SetBackdropBorderColor(0, 0, 0)
	end

    return frame
end
ns.createBackdrop = createBackdrop

local fixStatusbar = function(bar)
    bar:GetStatusBarTexture():SetHorizTile(false)
    bar:GetStatusBarTexture():SetVertTile(false)
end

local createStatusbar = function(parent, tex, layer, height, width, r, g, b, alpha)
    local bar = CreateFrame"StatusBar"
    bar:SetParent(parent)
    if height then
        bar:SetHeight(height)
    end
    if width then
        bar:SetWidth(width)
    end
    bar:SetStatusBarTexture(tex, layer)
    bar:SetStatusBarColor(r, g, b, alpha)
    fixStatusbar(bar)

    return bar
end

local createFont = function(parent, layer, f, fs, outline, r, g, b, justify)
    local string = parent:CreateFontString(nil, layer)
    string:SetFont(f, fs, outline)
    string:SetShadowOffset(0, 0)
    string:SetTextColor(r, g, b)
    if justify then
        string:SetJustifyH(justify)
    end
    return string
end
ns.createFont = createFont
--=============================================--
--[[    dropdown menu and hover highlight    ]]--
--=============================================--
local dropdown = CreateFrame('Frame', ADDON_NAME .. 'DropDown', UIParent, 'UIDropDownMenuTemplate')

local menu = function(self)
    dropdown:SetParent(self)
    return ToggleDropDownMenu(1, nil, dropdown, 'cursor', 0, 0)
end

local init = function(self)
    local unit = self:GetParent().unit
    local menu, name, id

    if(not unit) then
        return
    end

    if(UnitIsUnit(unit, "player")) then
        menu = "SELF"
    elseif(UnitIsUnit(unit, "vehicle")) then
        menu = "VEHICLE"
    elseif(UnitIsUnit(unit, "pet")) then
        menu = "PET"
    elseif(UnitIsPlayer(unit)) then
        id = UnitInRaid(unit)
        if(id) then
            menu = "RAID_PLAYER"
            name = GetRaidRosterInfo(id)
        elseif(UnitInParty(unit)) then
            menu = "PARTY"
        else
            menu = "PLAYER"
        end
    else
        menu = "TARGET"
        name = RAID_TARGET_ICON
    end

    if(menu) then
        UnitPopup_ShowMenu(self, menu, unit, name, id)
    end
end
UIDropDownMenu_Initialize(dropdown, init, 'MENU')

local OnMouseOver = function(self)
    local OnEnter = function(self)
		UnitFrame_OnEnter(self)
		self.Highlight:Show()
		self.isMouseOver = true
		for _, element in ipairs(self.mouseovers) do
			element:ForceUpdate()
		end
    end
    local OnLeave = function(self)
		UnitFrame_OnLeave(self)
		self.Highlight:Hide()
		self.isMouseOver = false
		for _, element in ipairs(self.mouseovers) do
			element:ForceUpdate()
		end
    end
    self:SetScript("OnEnter", OnEnter)
    self:SetScript("OnLeave", OnLeave)
	
	local hl = CreateFrame("Frame", nil, self)
	hl:SetAllPoints()
	hl:SetFrameLevel(6)
    hl.tex = hl:CreateTexture(nil, "OVERLAY")
    hl.tex:SetAllPoints()
    hl.tex:SetTexture(cfg.highlighttexture)
    hl.tex:SetVertexColor( 1, 1, 1, .02)
    hl.tex:SetBlendMode("ADD")
    hl:Hide()
    self.Highlight = hl
end
ns.OnMouseOver = OnMouseOver
--=============================================--
--[[               Some update               ]]--
--=============================================--
local Updatehealthbar = function(self, unit, min, max)
	local r, g, b
	local perc
	
	if max ~= 0 then perc = min/max else perc = 1 end
	
	if self.value then
		if min > 0 and min < max then
			self.value:SetText(FormatValue(min).." "..hex(1, 0, 1).."+ |r"..hex(1, 1, 0)..math.floor(min/max*100+.5).."|r")
		elseif min > 0 and self.__owner.isMouseOver and UnitIsConnected(unit) then
			self.value:SetText(FormatValue(min))
		else
			self.value:SetText(nil)
		end
	end
	
	if UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		r, g, b = .6, .6, .6
	elseif not UnitIsConnected(unit) then
		r, g, b = .3, .3, .3
	elseif UnitIsGhost(unit) then
		r, g, b = .6, .6, .6
	elseif UnitIsDead(unit) then
		r, g, b = 1, 0, 0
	elseif (unit == "pet") then
		local _, playerclass = UnitClass("player")
		if cfg.classcolormode then
			r, g, b = unpack(oUF.colors.class[playerclass])
		else
			r, g, b = oUF.ColorGradient(perc, 1, unpack(oUF.colors.smooth))
		end
	elseif(UnitIsPlayer(unit)) then
		local _, unitclass = UnitClass(unit)
		if cfg.classcolormode then
			if unitclass then r, g, b = unpack(oUF.colors.class[unitclass]) else r, g, b = 1, 1, 1 end
		else
			r, g, b = oUF.ColorGradient(perc, 1, unpack(oUF.colors.smooth))
		end
	elseif unit then
		if cfg.classcolormode then
			r, g, b = unpack(oUF.colors.reaction[UnitReaction(unit, "player") or 5])
		else
			r, g, b = oUF.ColorGradient(perc, 1, unpack(oUF.colors.smooth))
		end
	end

	self:GetStatusBarTexture():SetGradient("VERTICAL", r, g, b, r/1, g/1, b/1)
	
	if not cfg.classcolormode then
		self:SetValue(max - self:GetValue()) 
	end
end
ns.Updatehealthbar = Updatehealthbar

local Updatepowerbar = function(self, unit, min, max)
	if not self.value then return end	
	local _, type = UnitPowerType(unit)
	local color = oUF.colors.power[type] or oUF.colors.power.FUEL

	if self.__owner.isMouseOver and type == "MANA" and UnitIsConnected(unit) then
		self.value:SetText(hex(unpack(color))..FormatValue(min).."|r")
	elseif min > 0 and min < max then
		if type == "MANA" then
			self.value:SetText(hex(1, 1, 1)..math.floor(min/max*100+.5).."|r"..hex(.6, .85, .91).."%|r")
		else
			self.value:SetText(hex(color.r, color.g, color.b)..FormatValue(min).."|r")
		end
	else
		self.value:SetText(nil)
	end
end
		
local PostEclipseUpdate = function(element, unit)
    if element.hasSolarEclipse then
        element.bd:SetBackdropBorderColor(1, .6, 0)
        element.bd:SetBackdropColor(1, .6, 0)
    elseif element.hasLunarEclipse then
        element.bd:SetBackdropBorderColor(0, .4, 1)
        element.bd:SetBackdropColor(0, .4, 1)
    else
        element.bd:SetBackdropBorderColor(0, 0, 0)
        element.bd:SetBackdropColor(0, 0, 0)
    end
end

local PostAltUpdate = function(altpp, min, cur, max)
    local self = altpp.__owner
	
	altpp.value:SetText(cur)
	
    local tPath, r, g, b = UnitAlternatePowerTextureInfo(self.unit, 2)
    if(r) then
        altpp:SetStatusBarColor(r, g, b, 1)
    else
        altpp:SetStatusBarColor(1, 1, 1, .8)
    end 
end

local HarmonyOverride = function(self, event, unit, powerType)
	if(self.unit ~= unit or (powerType and powerType ~= 'LIGHT_FORCE')) then return end
	
	local cholder = self.Harmony
	
	local chi = UnitPower("player", SPELL_POWER_LIGHT_FORCE)
	local maxchi = UnitPowerMax("player", SPELL_POWER_LIGHT_FORCE)
	
	if not cholder.maxchi then cholder.maxchi = 5 end
	
	if cholder.maxchi ~= maxchi then
		for i = 1, 5 do
			cholder[i]:SetWidth((cfg.width+3)/maxchi-3)
		end
		
		cholder.maxchi = maxchi
	end

	for i = 1, 5 do
		if i <= chi then
			cholder[i]:SetAlpha(1)
		else
			cholder[i]:SetAlpha(0)
		end
	end
end

local HolyPowerOverride = function(self, event, unit, powerType)
	if(self.unit ~= unit or (powerType and powerType ~= 'HOLY_POWER')) then return end
	
	local hholder = self.HolyPower
	
	local holypower = UnitPower("player", SPELL_POWER_HOLY_POWER)
	local maxholypower = UnitPowerMax("player", SPELL_POWER_HOLY_POWER)
	
	if not hholder.maxholypower then hholder.maxholypower = 5 end
	
	if hholder.maxholypower ~= maxholypower then
		for i = 1, 5 do
			hholder[i]:SetWidth((cfg.width+3)/maxholypower-3)
		end
		
		hholder.maxholypower = maxholypower
	end

	for i = 1, 5 do
		if i <= holypower then
			hholder[i]:SetAlpha(1)
		else
			hholder[i]:SetAlpha(0)
		end
	end
end
--=============================================--
--[[                 Castbars                ]]--
--=============================================--
local PostCastStart = function(castbar, unit)
	local uc = cfg.uninterruptable
    if unit ~= 'player' then
        if castbar.interrupt then
			castbar.IBackdrop:SetBackdropBorderColor(uc[1], uc[2], uc[3])
			castbar:SetStatusBarColor(uc[1], uc[2], uc[3])
        else
			castbar:SetStatusBarColor(0.2, .8, 1)
			castbar.IBackdrop:SetBackdropBorderColor(0, 0, 0)
        end
	else
		castbar:SetStatusBarColor(0.2, .8, 1)
		castbar.IBackdrop:SetBackdropBorderColor(0, 0, 0)
    end
end

local CustomTimeText = function(castbar, duration)
    if castbar.casting then
        castbar.Time:SetFormattedText("%.1f / %.1f", duration, castbar.max)
    elseif castbar.channeling then
        castbar.Time:SetFormattedText("%.1f / %.1f", castbar.max - duration, castbar.max)
    end
end

local CreateCastbars = function(self, unit)
    local u = unit:match('[^%d]+')
    if multicheck(u, "target", "player", "boss", "focus") then
        local cb = createStatusbar(self, cfg.texture, "OVERLAY", cfg.height, nil, nil, 0, 0, 0, 0) -- transparent
        cb:SetToplevel(true)

		local cbbg = cb:CreateTexture(nil, "BACKGROUND")
        cbbg:SetAllPoints(cb)
        cbbg:SetTexture(cfg.texture)
        cbbg:SetVertexColor(0,0,0,0.5)
		
        cb.Spark = cb:CreateTexture(nil, "OVERLAY")
        cb.Spark:SetBlendMode("ADD")
        cb.Spark:SetAlpha(0)
        cb.Spark:SetSize(18, cfg.height*3)
		
        cb.Time = createFont(cb, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
			if (unit == "focus" or unit == "boss") then
				cb.Time:SetAlpha(0)
				cb.Time:SetPoint("CENTER", cb, "TOP", 0, 6)
			else
				cb.Time:SetPoint("CENTER", cb, "BOTTOM", 0, -cfg.height*(1-cfg.hpheight)-6)
			end
        cb.CustomTimeText = CustomTimeText

        cb.Text = createFont(cb, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
		if (unit == "boss")	then
			cb.Text:SetPoint("LEFT", cb, "LEFT", 0, 0)
		else	
			cb.Text:SetPoint("CENTER") 
		end

        cb.Icon = cb:CreateTexture(nil, 'ARTWORK')
        cb.Icon:SetSize(cfg.cbIconsize, cfg.cbIconsize)
        cb.Icon:SetTexCoord(.1, .9, .1, .9)
		cb.IBackdrop = createBackdrop(cb, cb.Icon,0,3,1)
		
		--safezone for castbar of player
        if (unit == "player") then
            cb.SafeZone = cb:CreateTexture(nil,'ARTWORK')
            cb.SafeZone:SetPoint('TOPRIGHT')
            cb.SafeZone:SetPoint('BOTTOMRIGHT')
            cb.SafeZone:SetTexture(cfg.texture)
            cb.SafeZone:SetVertexColor(1,1,0.3, 1)
        end
		
		if (unit == "player") then
                cb:SetPoint("CENTER", UIParent, "CENTER", 0, -142)
				cb:SetWidth(cfg.width+5)
		elseif (unit == "target") then	
				cb:SetPoint("CENTER", UIParent, "CENTER", 0, 225)
                cb.Icon:SetPoint("TOP", cb, "TOP", 0, 38)
				cb:SetWidth(cfg.width+5)		
			else
		        cb:SetAllPoints(self)
				cb.Icon:SetPoint("TOPRIGHT", cb, "TOPLEFT", -4, 7)
				cbbg:SetAlpha(0)
		    end
		
		cb.Backdrop = createBackdrop(cb, cb,0,3)

        cb.PostCastStart = PostCastStart
        cb.PostChannelStart = PostCastStart

        cb.bg = cbbg
        self.Castbar = cb
    end
end

--=============================================--
--[[                   Auras                 ]]--
--=============================================--
local PostCreateIcon = function(auras, icon)
    icon.icon:SetTexCoord(.07, .93, .07, .93)

    icon.count:ClearAllPoints()
    icon.count:SetPoint("BOTTOMRIGHT", 3, 0)
    icon.count:SetFontObject(nil)
    icon.count:SetFont(cfg.font, cfg.fontsize, cfg.fontflag)
    icon.count:SetTextColor(.9, .9, .1)

	icon.overlay:SetTexture(cfg.texture)
	icon.overlay:SetDrawLayer("BACKGROUND")
    icon.overlay:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    icon.overlay:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)

	icon.bg = createBackdrop(icon, icon,0,3)

	icon.remaining = createFont(icon, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, .8, .8, .8)
    icon.remaining:SetPoint("CENTER", 1,0)

    if cfg.auraborders then
        auras.showDebuffType = true
	end
end

local CreateAuraTimer = function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed

    if self.elapsed < .2 then return end
    self.elapsed = 0

    local timeLeft = self.expires - GetTime()
    if timeLeft <= 0 then
        self.remaining:SetText(nil)
    else
        self.remaining:SetText(FormatTime(timeLeft))
    end
end

local PostUpdateIcon = function(icons, unit, icon, index, offset)
	local name, _, _, _, _, duration, expirationTime = UnitAura(unit, index, icon.filter)

	if icon.isPlayer or UnitIsFriend('player', unit) or not icon.isDebuff then
		icon.icon:SetDesaturated(false)
		if duration and duration > 0 then
			icon.remaining:Show()
		else
			icon.remaining:Hide()
		end
	else
		icon.icon:SetDesaturated(true) -- grey other's debuff casted on enemy.
		icon.overlay:Hide()
		icon.remaining:Hide()
		icon.count:Hide()
	end
		
	if duration then
		icon.bg:Show() -- if the aura is not a gap icon show it's bg
	end
		
	icon.expires = expirationTime
	icon:SetScript("OnUpdate", CreateAuraTimer)
end

local PostUpdateGapIcon = function(auras, unit, icon, visibleBuffs)
	icon.bg:Hide()
	icon.remaining:Hide()
end

local CustomFilter = function(icons, unit, icon, ...)
	local _, _, _, _, _, _, _, _, _, _, spellID = ...
	if icon.isPlayer then -- show all my auras
		return true
	elseif UnitIsFriend('player', unit) and (not cfg.AuraFilter.ignoreBuff or icon.isDebuff) then
		return true
	elseif not UnitIsFriend('player', unit) and (not cfg.AuraFilter.ignoreDebuff or not icon.isDebuff) then
		return true
	elseif cfg.AuraFilter.whitelist[spellID] then
		return true
	end
end

local BossAuraFilter = function(icons, unit, icon, ...)
	if icon.isPlayer or not icon.isDebuff then -- show buff and my auras
		return true
	end
end

local CreateAuras = function(self, unit)
	local u = unit:match('[^%d]+')
    if multicheck(u, "target", "focus", "pet", "boss") then
		local Auras = CreateFrame("Frame", nil, self)
		Auras:SetHeight(cfg.height*2)
		Auras:SetWidth(cfg.width)
		Auras.gap = true
		Auras.disableCooldown = true
		Auras.showStealableBuffs = true
		Auras.size = (cfg.width+4)/cfg.auraperrow-4
		Auras.spacing = 4
		Auras.PostCreateIcon = PostCreateIcon
		Auras.PostUpdateIcon = PostUpdateIcon
		Auras.PostUpdateGapIcon = PostUpdateGapIcon
		
		if unit == "target" or unit == "focus" then
			Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 8)
			Auras.initialAnchor = "BOTTOMLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "UP"
			Auras.numDebuffs = cfg.auraperrow
			Auras.numBuffs = cfg.auraperrow
			if cfg.AuraFilter.ignoreBuff or cfg.AuraFilter.ignoreDebuff then
				Auras.CustomFilter = CustomFilter
			end
		elseif unit == "pet" then
			Auras:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 5, 0)
			Auras.initialAnchor = "BOTTOMLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "DOWN"
			Auras.numDebuffs = 0
			Auras.numBuffs = 0
		else -- boss 1-5
			Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
			Auras.initialAnchor = "BOTTOMLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "UP"	
			Auras.numDebuffs = 0
			Auras.numBuffs = 0
			Auras.CustomFilter = BossAuraFilter
		end
	
		self.Auras = Auras
	end
end
--=============================================--
--[[              Unit Frames                ]]--
--=============================================--

local func = function(self, unit)
	local u = unit:match('[^%d]+')
	
	OnMouseOver(self)
    self:RegisterForClicks"AnyUp"
	self.mouseovers = {}
	self.menu = menu
	
    -- height, width and scale --
	if multicheck(u, "targettarget", "focustarget", "pet") then
        self:SetSize(cfg.width1, cfg.height)
	elseif unit:match'(boss)%d?$' == 'boss' then
		self:SetSize(cfg.width2, cfg.height)
	else
	    self:SetSize(cfg.width, cfg.height)
    end
    self:SetScale(cfg.scale)
	
	-- shadow border for health bar --
    self.backdrop = createBackdrop(self, self, 0, 3) -- this also use for dispel border

	-- health bar --
    local hp = createStatusbar(self, cfg.texture, nil, nil, nil, .1, .1, .1, 0.5)
	hp:SetAllPoints(self)
    hp.frequentUpdates = true
    hp.Smooth = true

	-- health text --
	if (unit == "player" or unit == "target" or unit == "focus") then
		hp.value = createFont(hp, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
		hp.value:SetPoint("RIGHT", self, -1, -1)
	end
	
	-- reverse fill health --
	if not cfg.classcolormode then
		hp:SetReverseFill(true)
	end
	
	-- backdrop grey gradient --
	hp.bg = hp:CreateTexture(nil, "BACKGROUND")
	hp.bg:SetAllPoints()
	hp.bg:SetTexture(cfg.texture)
	if cfg.classcolormode then
		hp.bg:SetGradientAlpha("VERTICAL", .1, .1, .1, 1, .1, .1, .1, 1)
	else
		hp.bg:SetVertexColor(0,0,0,.2)
	end
	
    self.Health = hp
	self.Health.PostUpdate = Updatehealthbar
	tinsert(self.mouseovers, self.Health)
	
	-- power bar --
    if not (unit == "targettarget" or unit == "focustarget") then
		local pp = createStatusbar(self, cfg.texture, nil, cfg.height*-(cfg.hpheight-1), nil, 1, 1, 1, 1)
		pp:SetPoint"LEFT"
		pp:SetPoint"RIGHT"
		pp:SetPoint("TOP", self, "BOTTOM", 0, -3)
		pp.frequentUpdates = true
		pp.Smooth = true
		
		-- power color --	
		if not cfg.classcolormode then
			pp.colorClass = true
			pp.colorReaction = true
		else
			pp.colorPower = true
		end
	
		-- shadow border for power bar --	
		createBackdrop(pp, pp, 1, 3)
		
		-- power text --
		if unit ~= "pet" then
			pp.value = createFont(pp, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
			pp.value:SetPoint("LEFT", self, 4, -1)
		end

	
		self.Power = pp
		self.Power.PostUpdate = Updatepowerbar
		tinsert(self.mouseovers, self.Power)
    end

	-- altpower bar --
    if multicheck(u, "player", "boss") then
		local altpp = createStatusbar(self, cfg.texture, nil, 2, nil, 1, 1, 1, .8)
		altpp:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 0, -3)
		altpp:SetPoint('TOPRIGHT', self.Power, 'BOTTOMRIGHT', 0, -3)
		altpp.bd = createBackdrop(altpp, altpp, 1, 3)
	
		altpp.value = createFont(altpp, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
		altpp.value:SetPoint"CENTER"

		self.AltPowerBar = altpp
		self.AltPowerBar.PostUpdate = PostAltUpdate
    end
	
	-- little thing around unit frames --
    local Leader = hp:CreateFontString(nil, "OVERLAY")
	Leader:SetFont(cfg.font, cfg.fontsize, cfg.fontflag)
	Leader:SetText("|cff777777-|r")
	if(unit == "player") then
	Leader:SetPoint("TOPRIGHT", hp, "TOPRIGHT", 1,1)
	elseif(unit == "target") then
	Leader:SetPoint("TOPLEFT", hp, "TOPLEFT", 1,1)
	else
	Leader:Hide() end
	self.Leader = Leader

    if(unit == "player") then 
	local Combat = createFont(self, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, nil, nil, nil)	
		Combat:SetPoint("CENTER", self, "CENTER",0,-2)
		Combat:SetText("|cffCC3333x|r")
		self.Combat = Combat
	end
	
    local ricon = hp:CreateTexture(nil, 'OVERLAY')
    ricon:SetPoint("TOP", hp, "TOP", 0, 7)
    ricon:SetSize(15, 15)
    self.RaidIcon = ricon
	
	-- name --
    local name = createFont(hp, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
	name:SetPoint("TOPLEFT", hp, "BOTTOMLEFT", 0, -cfg.height*(1-cfg.hpheight)-6)
    if(unit == "player" or unit == "pet") then
        name:Hide()
	elseif(unit == "targettarget" or unit == "focustarget") then
	    name:SetPoint("TOPLEFT", hp, "BOTTOMLEFT", 0, -3)
        if cfg.classcolormode then
            self:Tag(name, '[Mlight:shortname2]')
        else
            self:Tag(name, '[Mlight:color][Mlight:shortname2]')
        end
    elseif cfg.classcolormode then
        self:Tag(name, '[difficulty][level]|r[shortclassification] [name] [status]')
    else
        self:Tag(name, '[difficulty][level]|r[shortclassification][Mlight:color] [name] [status]')
    end
    
    if cfg.castbars then
        CreateCastbars(self, unit)
    end
	
	if cfg.auras then
		CreateAuras(self, unit)
	end
	
    self.FadeMinAlpha = 0
	self.FadeInSmooth = 0.4
	self.FadeOutSmooth = 1.5
    self.FadeCasting = true
    self.FadeCombat = true
    self.FadeTarget = true
    self.FadeHealth = true
    self.FadePower = true
    self.FadeHover = true

end

local barcolor1 = { -- purple - pink
	[1] = {180/255, 140/255, 255/255, 1},
	[2] = {220/255, 130/255, 255/255, 1},
	[3] = {255/255, 60/255, 255/255, 1},
	[4] = {255/255, 10/255, 220/130, 1},
	[5] = {220/255, 10/255, 50/255, 1},
}

local barcolor2 = { -- lightblue - deepblue
	[1] = {125/255, 255/255, 245/255, 1},
	[2] = {55/255, 170/255, 255/255, 1},
	[3] = {0/255, 100/255, 180/255, 1},
	[4] = {0/255, 30/255, 220/255, 1},
	[5] = {0/255, 0/255, 150/255, 1},
}

local barcolor3 = { -- yellow - red
	[1] = {230/255, 230/255, 0/255, 1},
	[2] = {255/255, 180/255, 0/255, 1},
	[3] = {250/255, 120/255, 20/255, 1},
	[4] = {255/255, 70/255, 20/255, 1},
	[5] = {255/255, 0/255, 0/255, 1},
}

local UnitSpecific = {

    --========================--
    --  Player
    --========================--
    player = function(self, ...)
        func(self, ...)
        local _, class = UnitClass("player")
		
        -- Runes, Shards, HolyPower and so on --
        if multicheck(class, "DEATHKNIGHT", "WARLOCK", "PALADIN", "MONK", "SHAMAN", "PRIEST", "ROGUE", "DRUID") then
            local count
            if class == "DEATHKNIGHT" then 
                count = 6
			elseif class == "SHAMAN" then
				count = 4
			elseif class == "MONK" then
				count = 5
			elseif class == "WARLOCK" then
				count = 4
            elseif class == "PALADIN" then
                count = 5
			elseif class == "PRIEST" then
				count = 3
			elseif class == "ROGUE" or class == "DRUID" then
				count = 5 -- combopoints
            end

            local bars = CreateFrame("Frame", nil, self)
			bars:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 3)
            bars:SetSize(cfg.width, 10)

            for i = 1, count do
                bars[i] = createStatusbar(bars, cfg.texture, nil, cfg.height*-(cfg.hpheight-1), (cfg.width+3)/count-3, 1, 1, 1, 1)

                if class == "WARLOCK" or class == "PRIEST" then
                    bars[i]:SetStatusBarColor(unpack(barcolor1[i]))
                elseif class == "PALADIN" or class == "MONK" then
                    bars[i]:SetStatusBarColor(unpack(barcolor2[i]))
				elseif class == "ROGUE" or class == "DRUID" then
				    bars[i]:SetStatusBarColor(unpack(barcolor3[i]))
                end
				
                if i == 1 then
                    bars[i]:SetPoint("BOTTOMLEFT", bars, "BOTTOMLEFT")
                else
                    bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", 3, 0)
                end

                bars[i].bd = createBackdrop(bars[i], bars[i], 1, 3)
            end

            if class == "DEATHKNIGHT" then
                bars[3], bars[4], bars[5], bars[6] = bars[5], bars[6], bars[3], bars[4]
                self.Runes = bars
            elseif class == "WARLOCK" then
                self.WarlockSpecBars = bars
            elseif class == "PALADIN" then
                self.HolyPower = bars
				self.HolyPower.Override = HolyPowerOverride
			elseif class == "MONK" then
				self.Harmony = bars
				self.Harmony.Override = HarmonyOverride
			elseif class == "SHAMAN" then
				self.TotemBar = bars
			elseif class == "PRIEST" then 
				self.ShadowOrbs = bars
			elseif class == "ROGUE" or class == "DRUID" then
			    self.CPoints = bars
            end
        end
	
		-- eclipse bar --
        if class == "DRUID" then
            local ebar = CreateFrame("Frame", nil, self)
		    local Ewidth,Eheight
			Ewidth = cfg.width
			Eheight = cfg.height*-(cfg.hpheight-1)

            ebar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 3)
			ebar:SetSize(Ewidth, Eheight)
            ebar.bd = createBackdrop(ebar, ebar,1,3)

            local lbar = createStatusbar(ebar, cfg.texture, nil, Eheight, Ewidth, .2, .9, 1, 1)
            lbar:SetPoint("LEFT", ebar, "LEFT")
            ebar.LunarBar = lbar

            local sbar = createStatusbar(ebar, cfg.texture, nil, Eheight, Ewidth, 1, 1, 0.15, 1)
            sbar:SetPoint("LEFT", lbar:GetStatusBarTexture(), "RIGHT")
            ebar.SolarBar = sbar

            ebar.Spark = sbar:CreateTexture(nil, "OVERLAY")
            ebar.Spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
            ebar.Spark:SetBlendMode("ADD")
            ebar.Spark:SetAlpha(0.5)
            ebar.Spark:SetHeight(25)
            ebar.Spark:SetPoint("LEFT", sbar:GetStatusBarTexture(), "LEFT", -15, 0)
			
            self.EclipseBar = ebar
			self.EclipseBar.PostUnitAura = PostEclipseUpdate
        end
		
		-- resting Zzz and PvP---
		local playerstatus = createFont(self.Health, "OVERLAY", cfg.font, cfg.fontsize, cfg.fontflag, 1, 1, 1)
		playerstatus:SetPoint("CENTER", self.Health, "CENTER",0,-2)
		self:Tag(playerstatus, '[raidcolor][resting]|r')
		
    end,

    --========================--
    --  Target
    --========================--
    target = function(self, ...)
        func(self, ...)
    end,

    --========================--
    --  Focus
    --========================--
    focus = function(self, ...)
        func(self, ...)
    end,

    --========================--
    --  Focus Target
    --========================--
    focustarget = function(self, ...)
        func(self, ...)
    end,

    --========================--
    --  Pet
    --========================--
    pet = function(self, ...)
        func(self, ...)
    end,

    --========================--
    --  Target Target
    --========================--
    targettarget = function(self, ...)
        func(self, ...)
    end,

    --========================--
    --  Boss
    --========================--
    boss = function(self, ...)
        func(self, ...)
    end,
}

oUF:RegisterStyle("Mlight", func)
for unit,layout in next, UnitSpecific do
    oUF:RegisterStyle('Mlight - ' .. unit:gsub("^%l", string.upper), layout)
end

local spawnHelper = function(self, unit, ...)
    if(UnitSpecific[unit]) then
        self:SetActiveStyle('Mlight - ' .. unit:gsub("^%l", string.upper))
    elseif(UnitSpecific[unit:match('[^%d]+')]) then -- boss1 -> boss
        self:SetActiveStyle('Mlight - ' .. unit:match('[^%d]+'):gsub("^%l", string.upper))
    else
        self:SetActiveStyle'Mlight'
    end

    local object = self:Spawn(unit)
    object:SetPoint(...)
    return object
end

oUF:Factory(function(self)
    spawnHelper(self, "player",unpack(cfg.playerpos))
    spawnHelper(self, "pet",unpack(cfg.petpos))
    spawnHelper(self, "target",unpack(cfg.targetpos))
    spawnHelper(self, "targettarget",unpack(cfg.totpos))
    spawnHelper(self, "focus",unpack(cfg.focuspos))
    spawnHelper(self, "focustarget",unpack(cfg.focustarget))

    if cfg.bossframes then
        for i = 1, MAX_BOSS_FRAMES do		
			spawnHelper(self,'boss' .. i, cfg.boss1pos[1], cfg.boss1pos[2], cfg.boss1pos[3], cfg.boss1pos[4], cfg.boss1pos[5] - (cfg.bossspace * (i-1)))
        end
    end
end)