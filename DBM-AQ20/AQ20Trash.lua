local mod	= DBM:NewMod("AQ20Trash", "DBM-AQ20", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetModelID(15741)-- Qiraji Gladiator
mod:SetZone()
mod:SetMinSyncRevision(20200710000000)--2020, 7, 10

mod.isTrashMod = true

mod:RegisterEvents(
	"SPELL_AURA_APPLIED 22997 25698",
	"SPELL_AURA_REMOVED 22997",
	"SPELL_MISSED"
)

mod:AddRangeFrameOption(10, 22997)

local eventsRegistered = false

do-- Anubisath Plague/Explode - keep in sync - AQ40/AQ40Trash.lua AQ20/AQ20Trash.lua
	local warnPlague                    = mod:NewTargetAnnounce(22997, 2)
	local specWarnPlague                = mod:NewSpecialWarningMoveAway(22997, nil, nil, nil, 1, 2)
	local yellPlague                    = mod:NewYell(22997)
	local specWarnExplode               = mod:NewSpecialWarningRun(25698, nil, nil, nil, 4, 2)

	local Plague = DBM:GetSpellInfo(22997)
	local Explode = DBM:GetSpellInfo(25698)

	-- aura applied didn't seem to catch the reflects and other buffs
	function mod:SPELL_AURA_APPLIED(args)
		if args.spellName == Plague then
			if args:IsPlayer() then
				specWarnPlague:Show()
				specWarnPlague:Play("runout")
				yellPlague:Yell()
				if self.Options.RangeFrame then
					DBM.RangeCheck:Show(10)
				end
			else
				warnPlague:Show(args.destName)
			end
		elseif args.spellName == Explode then
			specWarnExplode:Show()
			specWarnExplode:Play("justrun")
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		if args.spellName == Plague then
			if args:IsPlayer() and self.Options.RangeFrame then
				DBM.RangeCheck:Hide()
			end
		end
	end
end

do-- Anubisath Reflect - keep in sync - AQ40/AQ40Trash.lua AQ20/AQ20Trash.lua
	local ShadowFrostReflect 			= DBM:GetSpellInfo(19595)
	local FireArcaneReflect 			= DBM:GetSpellInfo(13022)

	local specWarnShadowFrostReflect    = mod:NewSpecialWarningReflect(19595, nil, nil, nil, 1, 2)
	local specWarnFireArcaneReflect     = mod:NewSpecialWarningReflect(13022, nil, nil, nil, 1, 2)

	-- todo: thorns, shadow storm

	local playerGUID = UnitGUID("player")
	function mod:SPELL_MISSED(sourceGUID, _, _, _, destGUID, destName, _, _, _, _, spellSchool, missType)
		if (missType == "REFLECT" or missType == "DEFLECT") and sourceGUID == playerGUID then
			if spellSchool == 32 or spellSchool == 16 then
				specWarnShadowFrostReflect:Show(destName)
				specWarnShadowFrostReflect:Play("stopattack")
			elseif spellSchool == 4 or spellSchool == 64 then
				specWarnFireArcaneReflect:Show(destName)
				specWarnFireArcaneReflect:Play("stopattack")
			end
		end
		if eventsRegistered then-- for AQ40 timer
			self:SPELL_DAMAGE(nil, nil, nil, nil, destGUID)
		end
	end
end