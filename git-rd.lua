local internet = require('internet')
local json = require('json')

local function requests(url){
    local handle = internet.request(url)
    local result = ""
    for chunk in handle do result = result..chunk end

    return result
}

local function get_files_paths(owner, repo){
    r = requests("https://api.github.com/repos/"..owner.."/"..repo.."/contents")
    local data = json.decode(r)
    local paths = {}

    for k, v in pairs(data){
        paths[#paths+1] = v.path
    }

    return paths
}


local function get_file_commit(owner, repo, path){
    
}
    

local function get_raw_file(owner, repo, commit, path){

}
    

local function download_repo(owner, repo, download_path){

}
    
    