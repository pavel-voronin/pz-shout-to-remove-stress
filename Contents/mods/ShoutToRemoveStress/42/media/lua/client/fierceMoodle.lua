require "MF_ISMoodle"

local fierceMoodleModule = {}

MF.createMoodle("FierceMoodle");

fierceMoodleModule.BecomeFierce = function()
    MF.getMoodle("FierceMoodle"):setValue(1.0);
end

fierceMoodleModule.NotFierceAnymore = function()
    MF.getMoodle("FierceMoodle"):setValue(0.5);
end

fierceMoodleModule.SetFierceDescription = function(desc)
    MF.getMoodle("FierceMoodle", 0):setDescription(1, 4, desc)
end

return fierceMoodleModule
