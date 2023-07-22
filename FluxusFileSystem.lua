local loaded = {}

local file = {}
file.__index = file
function file.Read(self)
    return readfile(self.__dir)
end

function file.Write(self, data: string)
    return writefile(self.__dir, data)
end

function file.Load(self, ...) -- i dont need 1838123812 scripts running (lol im gonna have to replace the filesystem in each library :cryingsunglasses:)
    if not loaded[self] then
        loaded[self] = loadfile(self.__dir)(...)
    end

    return loaded[self]
end

function file.Function(self) -- dont know whenever the fuck im using this
    return loadfile(self.__dir)
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
    return setmetatable({__dir = filedir, __parent = parent, Name = filedir:split"\\"[3]}, file)
end

-- // direcoterieus

local directory = {}
directory.__index = directory

function directory.List(self)
    return self.__files
end

function directory.Get(self, name: string)
    return self.__files[`{name}.{name:find"%p" and name:split"."[2] or "lua"}`]
end

function directory.File(self, name: string, data: string?)
    writefile(`{self.__dir}/{name}`, data or "")
    self.__files[name] = file:new(`{self.__dir}\\{name}`, self.__dir)
end

function directory.Delete(self)
    return delfolder(self.__dir)
end

function directory:new(dir: string)
    local dirt = {__dir = dir, __files = {}}

    for i,v in listfiles(dir) do
        if isfolder(v) then
            dirt.__files[v:split"\\"[3]] = directory:new(v)
            continue
        end

        dirt.__files[v:split"\\"[3]] = file:new(v, dir)
    end

    return setmetatable(dirt, directory)
end

-- // get

local get = {} do
    local directories = {}

    function get:List()
        return directories
    end

    function get:Get(dir)
        return directories[dir]
    end

    for i,v in listfiles "Progen" do
        directories[v:split"\\"[2]] = directory:new(v)
    end
end

return get, file, directory
