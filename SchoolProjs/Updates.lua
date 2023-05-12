local directories = {
    "libs",
    "games",
    "base"
}

for _, dir in directories do
    for __, file in Get:Get(dir):List() do
        local filehash = syn.crypt.custom.hash("md5", readfile(file))
        local gottenhash = syn.request {}.Body
    end
end