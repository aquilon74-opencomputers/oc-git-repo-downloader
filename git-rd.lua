local internet = require('internet')
local json = require('json')

local function requests(url)
    local handle = internet.request(url)
    local result = ""
    for chunk in handle do result = result..chunk end

    return result
end

local function get_files_paths(owner, repo)
    r = requests("https://api.github.com/repos/"..owner.."/"..repo.."/contents")
    
    local data = json:decode(r)
    local paths = {}

    for k, v in pairs(data) do
        paths[#paths+1] = v.path
    end

    return paths
end


local function get_file_commit(owner, repo, path)
    r = requests("https://api.github.com/repos/"..owner.."/"..repo.."/commits?path="..path)

    local commits = json:decode(r)
    
    return commits[1].sha 
end
    

local function get_raw_file(owner, repo, commit, path)
    r = requests("https://raw.githubusercontent.com/"..owner.."/"..repo.."/"..commit.."/"..path)
    return r
end
    

local function download_repo(owner, repo, download_path)
    local files_paths = get_files_paths(owner, repo)

    local files_info = {}

    for k, path in pairs(files_paths) do
        local commit = get_file_commit(owner, repo, path)

        info = {
            ["path"] = path,
            ["commit"] = commit
        }

        files_info[#files_info + 1] = info
    end

    for k, info in pairs(files_info) do
        local raw = get_raw_file(owner, repo, info.commit, info.path)
        if raw == nil then
            error("can't get the raw file:"..info.path )
        end

        local path = download_path.."/"..repo.."/"..info.path
        print("saving "..info.path.." to "..path)

        if not filesystem.exists(filesystem.path(path)) then
            print(..filesystem.path(path).." does not exist, creating it..")
            filesystem.makeDirectory(filesystem.path(path))
            print(..filesystem.path(path).." created.")
        end

        local file = io.open(path, 'w')
        file:write(raw)
        file:close()

        print("saved "..info.path.." to "..path)
    end

    print("file downloaded")
end
    
--- git-rd [owner] [repo] [optional_path]
local args = {...}

-- owner missing --> error
if #args < 1 then error("error: owner parameter is missing") end

-- repo missing --> error
if #args < 2 then error("error: repo parameter is missing") end

-- path missing --> use working directory
if #args < 3 then args[3] = '.' end

download_repo(args[1], args[2], args[3])
