local Get = loadfile("Progen/libraries/Get.lua")()
local Services = Get:Get"libraries":Load "Services"

local directories = {
    "libraries",
    "games",
    "base"
}

for _, dir in directories do
    for __, file in Get:Get(dir):List() do
        local filehash = syn.crypt.custom.hash("md5", readfile(file))
        local filename = file:split("/")[3]
        local gitresponse = Services.Http:JSONDecode(syn.request{Url = `https://api.github.com/repos/GFXTI/ProfessionalGeneration/branches/main/{dir}/{filename}`}.Body)
        local hash = gitresponse.commit.sha

        if hash ~= filehash then
            local writedata = syn.request{`https://raw.githubusercontent.com/GFXTI/ProfessionalGeneration/main/{dir}/{filename}.lua`}.Body

            writefile(file, writedata)
        end
    end
end
