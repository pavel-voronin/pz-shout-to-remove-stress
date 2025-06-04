local config = {}

local options = PZAPI.ModOptions:create("ShoutToRemoveStress", "Shout To Remove Stress")

config.tarzanYellKey = options:addKeyBind("0", getText("UI_options_ShoutToRemoveStress_tarzanYellKey"),
    Keyboard.KEY_PERIOD, getText("UI_options_ShoutToRemoveStress_tarzanYellKey_tooltip")):getValue()

return config
