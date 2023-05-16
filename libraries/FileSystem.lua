local file = {}
file.__index = file
function file.Read(self)
    return readfileasync(self.__dir)
end

function file.Write(self, data: string)
    return writefileasync(self.__dir, data)
end

function file.Load(self, ...)
    return loadfileasync(self.__dir)(...)
end

function file.Function(self)
    return loadfileasync(self.__dir)
end

function file.Directory(self)
    return self.__dir
end

function file.Parent(self)
    return self.__parent
end

function file.Destroy(self)
    return delfile(self.__dir)
end

function file:new(filedir, parent)
    return setmetatable({__dir = filedir, __parent = parent, Name = filedir:split"/"[3]}, file)
end

-- // direcoterieus

local directory = {}
directory.__index = directory

function directory.List(self)
    return self.__files
end

function directory.Get(self, name: string)
    return self.__files[`{name}.{name:find"." and "."..string:split"."[2] or "lua"}`]
end

function directory.File(self, name: string, data: string?)
    writefileasync(self, `{self.__dir}/{name}`, data or "")
    self.__files[name] = file:new(`{self.__dir}/{name}`, self.__dir)
end

function directory.Delete(self)
    return delfolder(self.__dir)
end

function directory:new(dir)
    local dirt = {__dir = dir, __files = {}}

    for i,v in listfiles(dir) do
        dirt.__files[v:split"/"[3]] = file:new(v, dir)
    end

    return setmetatable(dirt, directory)
end

-- // get

local get = {} do
    local directories = {}

    if not isfolder "Progen" then
        makefolder "Progen"
        
        for i,v in {"libraries", "data", "games"} do
            makefolder(`Progen/{v}`)
        end
    end

    function get:List()
        return directories
    end

    function get:Get(dir)
        return directories[dir]
    end

    for i,v in listfiles "Progen" do
        directories[v:split"/"[2]] = directory:new(v)
    end
end

return get, file, directory
