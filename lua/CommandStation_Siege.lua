--derp

function CommandStation:GetCanBeWeldedOverride()
return not GetSandCastle():GetSDBoolean()
end
function CommandStation:GetAddConstructHealth()
return not GetSandCastle():GetSDBoolean()
end