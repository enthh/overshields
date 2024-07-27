local ABSORB_GLOW_ALPHA = 0.6
local ABSORB_GLOW_OFFSET = -7

hooksecurefunc(
    "UnitFrameHealPredictionBars_Update",
    function(frame)
        local absorbBar = frame.totalAbsorbBar
        if not absorbBar or absorbBar:IsForbidden() then
            return
        end

        local absorbGlow = frame.overAbsorbGlow
        if not absorbGlow or absorbGlow:IsForbidden() then
            return
        end

        local healthBar = frame.healthbar
        if not healthBar or healthBar:IsForbidden() then
            return
        end

        -- From StatusBar
        local healthBarTexture = healthBar:GetStatusBarTexture()

        -- From StatusBarOverlaySegmentTemplate
        local absorbFillTexture = absorbBar.Fill
        local absorbFillMaskTexture = absorbBar.FillMask

        local curHealth = healthBar:GetValue()
        if curHealth <= 0 then
            return
        end

        local _, maxHealth = healthBar:GetMinMaxValues()
        if maxHealth <= 0 then
            return
        end

        local totalAbsorb = UnitGetTotalAbsorbs(frame.unit) or 0
        if totalAbsorb <= 0 then
            return
        end

        local effectiveHealth = curHealth + totalAbsorb
        if effectiveHealth <= maxHealth then
            -- normal - fill health deficit with absorb bar
            absorbGlow:ClearAllPoints()
            absorbGlow:SetPoint("TOPLEFT", healthBarTexture, "TOPRIGHT", ABSORB_GLOW_OFFSET, 0)
            absorbGlow:SetPoint("BOTTOMLEFT", healthBarTexture, "BOTTOMRIGHT", ABSORB_GLOW_OFFSET, 0)
            absorbGlow:SetAlpha(ABSORB_GLOW_ALPHA)
        else
            -- overshield - fill health deficit and remaining absorb percentage into health bar
            local xOffset = (maxHealth / effectiveHealth) - 1
            absorbBar:UpdateFillPosition(healthBar:GetStatusBarTexture(), totalAbsorb, xOffset)

            -- anchor overabsorb glow left into health bar
            absorbGlow:ClearAllPoints()
            absorbGlow:SetPoint("TOPLEFT", absorbFillMaskTexture, "TOPLEFT", ABSORB_GLOW_OFFSET, 0)
            absorbGlow:SetPoint("BOTTOMLEFT", absorbFillMaskTexture, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, 0)
            absorbGlow:SetAlpha(ABSORB_GLOW_ALPHA)
        end
    end
)

hooksecurefunc(
    "CompactUnitFrame_UpdateHealPrediction",
    function(frame)
        local absorbBar = frame.totalAbsorb
        if not absorbBar or absorbBar:IsForbidden() then
            return
        end

        local absorbOverlay = frame.totalAbsorbOverlay
        if not absorbOverlay or absorbOverlay:IsForbidden() then
            return
        end

        local absorbGlow = frame.overAbsorbGlow
        if not absorbGlow or absorbGlow:IsForbidden() then
            return
        end

        local healthBar = frame.healthBar
        if not healthBar or healthBar:IsForbidden() then
            return
        end

        local _, maxHealth = healthBar:GetMinMaxValues()
        if maxHealth <= 0 then
            return
        end

        local totalAbsorb = UnitGetTotalAbsorbs(frame.displayedUnit) or 0
        if totalAbsorb > maxHealth then
            totalAbsorb = maxHealth
        end

        if totalAbsorb > 0 then -- show overlay when there's a positive absorb amount
            absorbOverlay:SetParent(healthBar)
            absorbOverlay:ClearAllPoints() -- we'll be attaching the overlay on heal prediction update.

            if absorbBar:IsShown() then -- If absorb bar is shown, attach absorb overlay to it; otherwise, attach to health bar.
                absorbOverlay:SetPoint("TOPRIGHT", absorbBar, "TOPRIGHT", 0, 0)
                absorbOverlay:SetPoint("BOTTOMRIGHT", absorbBar, "BOTTOMRIGHT", 0, 0)
            else
                absorbOverlay:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT", 0, 0)
                absorbOverlay:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 0, 0)
            end

            local totalWidth, totalHeight = healthBar:GetSize()
            local barSize = totalAbsorb / maxHealth * totalWidth

            absorbOverlay:SetWidth(barSize)
            absorbOverlay:SetTexCoord(0, barSize / absorbOverlay.tileSize, 0, totalHeight / absorbOverlay.tileSize)
            absorbOverlay:Show()

            absorbGlow:ClearAllPoints()
            absorbGlow:SetPoint("TOPLEFT", absorbOverlay, "TOPLEFT", ABSORB_GLOW_OFFSET, 0)
            absorbGlow:SetPoint("BOTTOMLEFT", absorbOverlay, "BOTTOMLEFT", ABSORB_GLOW_OFFSET, 0)
            absorbGlow:SetAlpha(ABSORB_GLOW_ALPHA)

        -- frame.overAbsorbGlow:Show();	--uncomment this if you want to ALWAYS show the glow to the left of the shield overlay
        end
    end
)
