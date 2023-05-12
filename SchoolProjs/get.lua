local dirs = {}
local funcs = {}

for i,v in listfiles"Progen" do
    table.insert(dirs, v:sub(8))
end

function funcs:Get(directory)
    local getfuncs = {}
    local files = listfiles `"Progen"/{directory}`
    if not dirs[directory] then return error `{directory} is not a valid directory` end

    function getfuncs:Load(file, ...)
        return loadfile(files[`Progen/{directory}/{file}`])(...)
    end

    function getfuncs:Read(file)
        return readfile(files[`Progen/{directory}/{file}`])
    end

    function getfuncs:Write(file, contents)
        local err, suc = pcall(writefile, files[`Progen/{directory}/{file}`], contents)

        if not suc then return error(err) end
    end

    return getfuncs
end

return funcs