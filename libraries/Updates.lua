local Get = loadfile("Progen/libraries/Get.lua")()
local Services = Get:Get"libraries":Get"Services":Load()

local directories = {
    "libraries",
    "games",
    "base"
}

for _, dir in directories do
    local directory = Get:Get(dir)

    for _, file in Services.Http:JSONDecode(syn.request{Url = `https://api.github.com/repos/GFXTI/ProfessionalGeneration/git/trees/{dir}/recursive=1`}.Body).tree do
        if not direcotry:Get(file.path) then
            directory:File(file.path, syn.request{`https://raw.githubusercontent.com/GFXTI/ProfessionalGeneration/main/{dir}/{file.path}`}.Body)
        end
    end
end

for _, dir in directories do
    for __, file in Get:Get(dir):List() do
        local filehash = syn.crypt.custom.hash("md5", readfile(file))
        local filename = file:split("/")[3]
        local gitresponse = Services.Http:JSONDecode(syn.request{Url = `https://api.github.com/repos/GFXTI/ProfessionalGeneration/branches/main/{dir}/{filename}`}.Body)
        local hash = gitresponse.commit.sha

        if hash ~= filehash then
            writefile(file, syn.request{`https://raw.githubusercontent.com/GFXTI/ProfessionalGeneration/main/{dir}/{filename}.lua`}.Body)
        end
    end
end

return true
