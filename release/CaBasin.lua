local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CaBasin"] = function(...) local aba=require("utils.Logger")
local bba=require("programs.common.Communicator")local cba=require("programs.command.CommandLine")
local dba=require("utils.OSUtils")local _ca=require("programs.recipe.manager.Trigger")
local aca=require("wrapper.PeripheralWrapper")local bca=require("utils.TableUtils")
local cca=require("programs.common.BlazeBurnerFeederFactory")local dca=require("programs.recipe.manager.StoreManager")
aba.useDefault()aba.currentLevel=aba.levels.ERROR;local _da={...}local ada={}local bda={}local cda={}
local dda={}local function __b()local adb=dba.loadTable("cabasin_groups")
if adb~=nil then ada=adb end end;local function a_b()
dba.saveTable("cabasin_groups",ada)end
local function b_b()
local adb=dba.loadTable("cabasin_recipe_links")if adb~=nil then dda=adb end end
local function c_b()dba.saveTable("cabasin_recipe_links",dda)end;__b()b_b()local function d_b()local adb=dba.loadTable("cabasin_recipes")if adb~=nil then
bda=adb end end;local function _ab()
dba.saveTable("cabasin_recipes",bda)end
local aab=function(adb)local bdb={}
for cdb,ddb in pairs(adb)do for __c,a_c in ipairs(ddb.basins)do
bdb[a_c]=true end
for __c,a_c in ipairs(ddb.blazeBurners)do bdb[a_c]=true end
for __c,a_c in ipairs(ddb.redstones or{})do bdb[a_c]=true end end;return bdb end
local bab=function(adb)local bdb=peripheral.getNames()local cdb={}local ddb={}local __c={}
for a_c,b_c in pairs(bdb)do
if not
adb[b_c]then
if b_c:find("basin")then table.insert(cdb,b_c)end
if b_c:find("blaze_burner")then table.insert(ddb,b_c)end
if b_c:find("redrouter")then table.insert(__c,b_c)end end end;return{basins=cdb,blazeBurners=ddb,redstones=__c}end
local function cab(adb,bdb,cdb,ddb)bdb=bdb or 1;cdb=cdb or 5;ddb=ddb or"local"if#adb==0 then
print("No recipes found.")return end;local __c=math.ceil(#adb/cdb)local a_c=
(bdb-1)*cdb+1;local b_c=math.min(a_c+cdb-1,#adb)
print(string.format("=== Basin Recipes (Page %d/%d) ===",bdb,__c))
for i=a_c,b_c do local c_c=adb[i]local d_c=c_c.name or"Unnamed Recipe"
local _ac=dda[d_c]
if _ac then
print(string.format("%d. %s -> [%s]",i,d_c,_ac))else print(string.format("%d. %s",i,d_c))end end
if __c>1 then
print(string.format("Showing %d-%d of %d recipes",a_c,b_c,#adb))if bdb<__c then
print(string.format("Use 'list recipe %s %d' for next page",ddb,bdb+1))end;if bdb>1 then
print(string.format("Use 'list recipe %s %d' for previous page",ddb,
bdb-1))end end end
local function dab()
if bca.getLength(ada)==0 then print("No groups found.")return end;print("=== Basin Groups ===")local adb=0;for bdb,cdb in pairs(ada)do adb=adb+1
print(string.format("%d. %s - Basins: %d, Burners: %d",adb,bdb,
#cdb.basins,#cdb.blazeBurners))end end
local function _bb()local adb=0;for bdb,cdb in pairs(dda)do adb=adb+1 end;if adb==0 then
print("No recipe-group links found.")return end
print("=== Recipe-Group Links ===")for bdb,cdb in pairs(dda)do
print(string.format("%s -> %s",bdb,cdb))end end
local function abb()local adb=cba:new("cabasin> ")
adb:addCommand("group","Manage basin groups",function(bdb)local cdb={}for a_c in
bdb:gmatch("%S+")do table.insert(cdb,a_c)end;if#cdb<2 then
print("Usage: group [name]")
print("Creates a new group with the given name using current basins and blaze burners")return end
local ddb=cdb[2]local __c=bab(aab(ada))ada[ddb]=__c;a_b()print("Group '"..
ddb.."' created successfully:")print(
"  Name: "..ddb)
print("  Basins: "..#__c.basins.." found")for a_c,b_c in ipairs(__c.basins)do
print("    "..a_c..". "..b_c)end
print("  Blaze Burners: "..
#__c.blazeBurners.." found")for a_c,b_c in ipairs(__c.blazeBurners)do
print("    "..a_c..". "..b_c)end
print("  Redstone Routers: "..
#__c.redstones.." found")for a_c,b_c in ipairs(__c.redstones)do
print("    "..a_c..". "..b_c)end end,function(bdb)return
{}end)
adb:addCommand("list","List recipes or groups",function(bdb)local cdb={}for __c in bdb:gmatch("%S+")do
table.insert(cdb,__c)end
if#cdb<2 then
print("Usage: list [recipe|group|link] [remote|local] [page]")print("Examples:")
print("  list group              - List all groups")
print("  list link               - List recipe-group links")
print("  list recipe remote      - List remote recipes")
print("  list recipe local       - List local recipes")
print("  list recipe local 2     - List local recipes page 2")return end;local ddb=cdb[2]
if ddb=="group"then dab()elseif ddb=="link"then _bb()elseif ddb=="recipe"then if#cdb<3 then
print("Usage: list recipe [remote|local] [page]")return end;local __c=cdb[3]
local a_c=tonumber(cdb[4])or 1
if __c=="local"then cab(bda,a_c,nil,"local")elseif __c=="remote"then if#cda==0 then
print("No remote recipes available.")return end;cab(cda,a_c,nil,"remote")else
print("Usage: list recipe [remote|local] [page]")end elseif ddb=="link"then _bb()else
print("Usage: list [recipe|group] [remote|local] [page]")print("Available list types: recipe, group")end end,function(bdb)
local cdb={}
for __c in bdb:gmatch("%S+")do table.insert(cdb,__c)end;local ddb=#cdb
if(ddb==0 or ddb==1)and bdb:sub(-1)~=" "then local __c=
bdb:match("%S+$")or""local a_c={}
local b_c={"recipe","group","link"}
for c_c,d_c in ipairs(b_c)do if d_c:find(__c,1,true)==1 then
table.insert(a_c,d_c:sub(#__c+1))end end;return a_c elseif(ddb==1 and bdb:sub(-1)==" ")or ddb==2 then
if
cdb[1]=="recipe"then local __c=bdb:match("%S+$")or""local a_c={}
local b_c={"remote","local"}
for c_c,d_c in ipairs(b_c)do if d_c:find(__c,1,true)==1 then
table.insert(a_c,d_c:sub(#__c+1))end end;return a_c end end;return{}end)
adb:addCommand("add","Add recipe from remote by name",function(bdb)local cdb={}for b_c in bdb:gmatch("%S+")do
table.insert(cdb,b_c)end
if#cdb<2 then
print("Usage: add [recipe_name]")print("Examples:")
print("  add SteelRecipe            - Add recipe by name")
print("Use 'list recipe remote' to see available recipes")return end;local ddb=cdb[2]if#cda==0 then
print("No remote recipes available. Use network mode to connect first.")return end;local __c=nil;for b_c,c_c in ipairs(cda)do if c_c.name==
ddb then __c=c_c;break end end;if
not __c then
print("Remote recipe '"..ddb.."' not found")
print("Use 'list recipe remote' to see available recipes")return end
for b_c,c_c in
ipairs(bda)do if c_c.name==ddb then
print("Recipe '"..ddb.."' already exists locally")return end end;local a_c={}
for b_c,c_c in pairs(__c)do
if type(c_c)=="table"then a_c[b_c]={}
for d_c,_ac in pairs(c_c)do
if
type(_ac)=="table"then a_c[b_c][d_c]={}
for aac,bac in ipairs(_ac)do a_c[b_c][d_c][aac]=bac end else a_c[b_c][d_c]=_ac end end else a_c[b_c]=c_c end end;table.insert(bda,a_c)_ab()
print("Recipe '"..ddb.."' added successfully")end,function(bdb)
local cdb={}local ddb=bdb:match("%S+$")or""for __c,a_c in ipairs(cda)do
if a_c.name and
a_c.name:find(ddb,1,true)==1 then
local b_c=a_c.name:sub(#ddb+1)table.insert(cdb,b_c)end end;return cdb end)
adb:addCommand("link","Link recipe to group",function(bdb)local cdb={}for b_c in bdb:gmatch("%S+")do
table.insert(cdb,b_c)end
if#cdb<3 then
print("Usage: link [recipe_name] [group_name]")print("Examples:")
print("  link SteelRecipe production      - Link recipe to group")return end;local ddb=cdb[2]local __c=cdb[3]local a_c=false;for b_c,c_c in ipairs(bda)do
if c_c.name==ddb then a_c=true;break end end;if not a_c then
print("Recipe '"..
ddb.."' not found in local recipes")
print("Use 'list recipe local' to see available recipes")return end;if not
ada[__c]then
print("Group '"..__c.."' not found")print("Use 'list group' to see available groups")
return end;dda[ddb]=__c
c_b()
print("Recipe '"..
ddb.."' linked to group '"..__c.."' successfully")end,function(bdb)
local cdb={}
for ddb in bdb:gmatch("%S+")do table.insert(cdb,ddb)end
if#cdb==1 then local ddb={}local __c=bdb:match("%S+$")or""for a_c,b_c in ipairs(bda)do
if b_c.name and
b_c.name:find(__c,1,true)==1 then
local c_c=b_c.name:sub(#__c+1)table.insert(ddb,c_c)end end;return ddb elseif#
cdb==2 then local ddb={}local __c=bdb:match("%S+$")or""for a_c,b_c in pairs(ada)do
if
a_c:find(__c,1,true)==1 then table.insert(ddb,a_c:sub(#__c+1))end end;return ddb end;return{}end)
adb:addCommand("unlink","Unlink recipe from group",function(bdb)local cdb={}for a_c in bdb:gmatch("%S+")do
table.insert(cdb,a_c)end;if#cdb<2 then
print("Usage: unlink [recipe_name]")print("Examples:")
print("  unlink SteelRecipe     - Unlink recipe from group")return end
local ddb=cdb[2]if not dda[ddb]then
print("Recipe '"..ddb.."' is not linked to any group")return end;local __c=dda[ddb]
dda[ddb]=nil;c_b()
print("Recipe '"..
ddb.."' unlinked from group '"..__c.."' successfully")end,function(bdb)
local cdb={}local ddb=bdb:match("%S+$")or""for __c,a_c in pairs(dda)do
if
__c:find(ddb,1,true)==1 then local b_c=__c:sub(#ddb+1)table.insert(cdb,b_c)end end;return cdb end)
adb:addCommand("delete","Delete group or recipe",function(bdb)local cdb={}for a_c in bdb:gmatch("%S+")do
table.insert(cdb,a_c)end
if#cdb<3 then
print("Usage: delete [group|recipe] [name]")print("Examples:")
print("  delete group production     - Delete group by name")
print("  delete recipe SteelRecipe   - Delete recipe by name")return end;local ddb=cdb[2]local __c=cdb[3]
if ddb=="group"then if not ada[__c]then
print("Group '"..__c.."' not found")print("Use 'list group' to see available groups")
return end;local a_c={}
for b_c,c_c in pairs(dda)do if
c_c==__c then table.insert(a_c,b_c)end end
if#a_c>0 then
print("Cannot delete group '"..__c.."' - it has linked recipes:")
for b_c,c_c in ipairs(a_c)do print("  "..b_c..". "..c_c)end
print("Use 'unlink [recipe_name]' to unlink recipes first")return end;ada[__c]=nil;a_b()
print("Group '"..__c.."' deleted successfully")elseif ddb=="recipe"then local a_c=nil
for b_c,c_c in ipairs(bda)do if c_c.name==__c then a_c=b_c;break end end;if not a_c then
print("Recipe '"..__c.."' not found in local recipes")
print("Use 'list recipe local' to see available recipes")return end
if
dda[__c]then
print("Cannot delete recipe '"..
__c.."' - it is linked to group '"..dda[__c].."'")
print("Use 'unlink "..__c.."' to unlink the recipe first")return end;table.remove(bda,a_c)_ab()
print("Recipe '"..__c.."' deleted successfully")else print("Usage: delete [group|recipe] [name]")
print("Available delete types: group, recipe")end end,function(bdb)
local cdb={}
for __c in bdb:gmatch("%S+")do table.insert(cdb,__c)end;local ddb=#cdb
if(ddb==0 or ddb==1)and bdb:sub(-1)~=" "then
local __c={}local a_c=bdb:match("%S+$")or""local b_c={"group","recipe"}
for c_c,d_c in
ipairs(b_c)do if d_c:find(a_c,1,true)==1 then
table.insert(__c,d_c:sub(#a_c+1))end end;return __c elseif(ddb==1 and bdb:sub(-1)==" ")or ddb==2 then
local __c=cdb[1]local a_c=bdb:match("%S+$")or""local b_c={}
if __c=="group"then for c_c,d_c in pairs(ada)do
if
c_c:find(a_c,1,true)==1 then table.insert(b_c,c_c:sub(#a_c+1))end end elseif __c=="recipe"then for c_c,d_c in ipairs(bda)do
if
d_c.name and d_c.name:find(a_c,1,true)==1 then local _ac=d_c.name:sub(
#a_c+1)table.insert(b_c,_ac)end end end;return b_c end;return{}end)
adb:addCommand("reboot","Reboot the program",function(bdb)print("Rebooting...")os.reboot()end)return adb end;d_b()
if _da~=nil and#_da>0 then local adb=_da[1]local bdb=tonumber(_da[2])
local cdb=_da[3]
if adb and bdb and cdb then bba.open(adb,bdb,"recipe",cdb)
local ddb=bba.communicationChannels[adb][bdb]["recipe"]
ddb.addMessageHandler("getRecipesRes",function(__c,a_c,b_c)cda=a_c or{}end)
parallel.waitForAll(bba.listen,function()while next(cda)==nil do
ddb.send("getRecipesReq","basin")os.sleep(1)end end,function()
local __c=abb()print("CaBasin Manager - Network Mode")
print("Connected to channel "..bdb..
" on "..adb)
print("Type 'help' for available commands or 'exit' to quit")while true do local a_c,b_c=pcall(function()__c:run()end)
if not a_c then print(
"Error: "..tostring(b_c))end end end)end end;aca.reloadAll()
local bbb=aca.getAllPeripheralsNameContains("crafting_storage")local cbb=next(bbb)local dbb=bbb[cbb]local _cb={}
local acb=function()local adb={}for bdb,cdb in pairs(bda)do
adb[cdb.name]=cdb end
for bdb,cdb in pairs(dda)do _cb[bdb]={recipe=adb[bdb]}
local ddb={name=cdb,basins={},blazeBurnerFeeders={},redstones={}}
for __c,a_c in ipairs(ada[cdb].basins)do
print("Wrapping basin: "..a_c)table.insert(ddb.basins,aca.wrap(a_c))end
for __c,a_c in ipairs(ada[cdb].blazeBurners)do
print("Wrapping blaze burner: "..a_c)local b_c=aca.wrap(a_c)local c_c=nil
if
adb[bdb].blazeBurner==dca.BLAZE_BURN_TYPE.LAVA then c_c=cca.Types.LAVA elseif
adb[bdb].blazeBurner==dca.BLAZE_BURN_TYPE.HELLFIRE then c_c=cca.Types.HELLFIRE end;local d_c=cca.getFeeder(dbb,b_c,c_c)
table.insert(ddb.blazeBurnerFeeders,d_c)end
for __c,a_c in ipairs(ada[cdb].redstones)do
print("Wrapping redstone: "..a_c)table.insert(ddb.redstones,aca.wrap(a_c))end;_cb[bdb].group=ddb end end
local bcb=function(adb,bdb)if adb=="item"then return dbb.getItem(bdb)elseif adb=="fluid"then
return dbb.getFluid(bdb)end;return nil end
local ccb=function(adb)local bdb=adb.recipe;local cdb=adb.group
for ddb,__c in ipairs(cdb.basins)do local a_c=bdb.input
if
a_c.items~=nil then
for c_c,d_c in ipairs(a_c.items)do local _ac=__c.getItem(d_c)
local aac=_ac and _ac.count or 0
if aac<16 then dbb.transferItemTo(__c,d_c,16 -aac)end end end
if a_c.fluids~=nil then
for c_c,d_c in ipairs(a_c.fluids)do local _ac=__c.getFluid(d_c)local aac=
_ac and _ac.amount or 0;if aac<1000 then
dbb.transferFluidTo(__c,d_c,1000 -aac)end end end;local b_c=bdb.output
if b_c.items~=nil then
for c_c,d_c in ipairs(b_c.items)do
local _ac=bdb.output.keepItemsAmount or 0;local aac=__c.getItem(d_c)
if aac~=nil and aac.count>_ac then dbb.transferItemFrom(__c,d_c,
aac.count-_ac)end end end
if b_c.fluids~=nil then
for c_c,d_c in ipairs(b_c.fluids)do
local _ac=bdb.output.keepFluidsAmount or 0;local aac=__c.getFluid(d_c)
if aac~=nil and aac.amount>_ac then dbb.transferFluidFrom(__c,d_c,
aac.amount-_ac)end end end end end
local dcb=function(adb)for bdb,cdb in ipairs(adb)do cdb:feed()end end
local _db=function()
while true do
for adb,bdb in pairs(_cb)do local cdb=_ca.eval(bdb.recipe.trigger,bcb)
local ddb=bdb.group.redstones;if ddb~=nil then
for __c,a_c in ipairs(ddb)do a_c.setOutputSignals(not cdb)end end;if(cdb)then ccb(bdb)
dcb(bdb.group.blazeBurnerFeeders)end end;os.sleep(1)end end;acb()while true do _db()end end
modules["utils.Logger"] = function(...) local b={currentLevel=1,printFunctions={}}
b.useDefault=function()
b.addPrintFunction(function(c,d,_a,aa)
print(string.format("[%s][%s:%d] %s",c,d,_a,aa))end)end;b.levels={DEBUG=1,INFO=2,WARN=3,ERROR=4}b.addPrintFunction=function(c)
table.insert(b.printFunctions,c)end
b.print=function(c,d,_a,aa,...)
if
c>=b.currentLevel then local ba=b.formatBraces(aa,...)for ca,da in ipairs(b.printFunctions)do
da(c,d,_a,ba)end end end
b.custom=function(c,d,...)local _a=debug.getinfo(2,"l").currentline
local aa=debug.getinfo(2,"S").short_src;b.print(c,aa,_a,d,...)end
b.debug=function(c,...)local d=debug.getinfo(2,"l").currentline
local _a=debug.getinfo(2,"S").short_src;b.print(b.levels.DEBUG,_a,d,c,...)end
b.info=function(c,...)local d=debug.getinfo(2,"l").currentline
local _a=debug.getinfo(2,"S").short_src;b.print(b.levels.INFO,_a,d,c,...)end
b.warn=function(c,...)local d=debug.getinfo(2,"l").currentline
local _a=debug.getinfo(2,"S").short_src;b.print(b.levels.WARN,_a,d,c,...)end
b.error=function(c,...)local d=debug.getinfo(2,"l").currentline
local _a=debug.getinfo(2,"S").short_src;b.print(b.levels.ERROR,_a,d,c,...)end
b.formatBraces=function(c,...)local d={...}local _a=1
local aa=tostring(c):gsub("{}",function()local ba=d[_a]_a=_a+1
return tostring(ba)end)return aa end;return b end
modules["programs.common.Communicator"] = function(...) local _b=require("utils.Logger")
local ab=require("utils.OSUtils")
local function bb(dc,_d)local ad=""local bd=_d
for i=1,#dc do local cd=dc:sub(i,i)
local dd=bd:sub((i-1)%#bd+1,(i-1)%#bd+1)ad=ad..
string.char(bit.bxor(string.byte(cd),string.byte(dd)))end;return ad end
local function cb(dc,_d)return textutils.unserialize(bb(dc,_d))end
local function db(dc,_d)return bb(textutils.serialize(dc),_d)end;local _c={}_c.__index=_c
function _c:new(dc,_d,ad,bd)local cd=setmetatable({},_c)
cd.computerId=os.getComputerID()cd.side=dc;cd.secret=bd;cd.channel=_d;cd.protocol=ad
cd.modem=peripheral.wrap(dc)cd.modem.open(_d)cd.eventHandle={}
cd.send=function(dd,__a,a_a)
local b_a={protocol=cd.protocol,senderId=cd.computerId,receiverId=a_a,details=db({eventCode=dd,payload=__a},cd.secret)}
_b.debug("Sending message on side {}, channel {}: {}",cd.side,cd.channel,textutils.serialize(b_a))
cd.modem.transmit(cd.channel,cd.channel,textutils.serialize(b_a))end
cd.addMessageHandler=function(dd,__a)cd.eventHandle[dd]=__a end;return cd end;local ac={communicationChannels={}}
function ac.open(dc,_d,ad,bd)local cd=_c:new(dc,_d,ad,bd)
if not
ac.communicationChannels[dc]then ac.communicationChannels[dc]={}end;if not ac.communicationChannels[dc][_d]then
ac.communicationChannels[dc][_d]={}end
if
ac.communicationChannels[dc][_d][ad]then return false,
string.format("Channel already opened on side %s, channel %d, protocol %s",dc,_d,ad)end
ac.communicationChannels[dc][_d][ad]=cd;return cd end
local bc=function(dc,_d)if
ac.communicationChannels[dc]and ac.communicationChannels[dc][_d]then return true end;return false end
local cc=function(dc,_d,ad)local bd=textutils.unserialize(ad)if
not bd or not bd.protocol then return end
local cd=ac.communicationChannels[dc][_d][bd.protocol]if not cd then return end;if
bd.receiverId~=nil and bd.receiverId~=cd.computerId then return end
local dd=cb(bd.details,cd.secret)local __a=cd.eventHandle[dd.eventCode]if __a then
__a(dd.eventCode,dd.payload,bd.senderId)end end
function ac.listen()
while true do local dc,_d,ad,bd,cd,dd=os.pullEvent("modem_message")
_b.debug("Received message on side {}, channel {}, distance {}: {}",_d,ad,dd,cd)
if bc(_d,ad)then
local __a,a_a=pcall(function()cc(_d,ad,cd)end)if not __a then
_b.error("Error handling serialized message: "..a_a)end end end end
function ac.close(dc,_d,ad)
if ac.communicationChannels[dc]and
ac.communicationChannels[dc][_d]and
ac.communicationChannels[dc][_d][ad]then
local bd=ac.communicationChannels[dc][_d][ad]bd.modem.close(_d)ac.communicationChannels[dc][_d][ad]=
nil;if
next(ac.communicationChannels[dc][_d])==nil then
ac.communicationChannels[dc][_d]=nil end
if
next(ac.communicationChannels[dc])==nil then ac.communicationChannels[dc]=nil end;return true else return false,
string.format("No such channel to close on side %s, channel %d, protocol %s",dc,_d,ad)end end
function ac.closeAllChannels()
for dc,_d in pairs(ac.communicationChannels)do for ad,bd in pairs(_d)do for cd,dd in pairs(bd)do
dd.modem.close(ad)end end end;ac.communicationChannels={}end
function ac.saveSettings()local dc={}
for _d,ad in pairs(ac.communicationChannels)do
for bd,cd in pairs(ad)do for dd,__a in pairs(cd)do
table.insert(dc,{side=_d,channel=bd,protocol=dd,secret=__a.secret})end end end;return ab.saveTable("communicator_settings.dat",dc)end
function ac.loadSettings()local dc=ab.loadTable("communicator_settings.dat")if not
dc or#dc==0 then
_b.warn("No communicator settings found.")return false end
for _d,ad in ipairs(dc)do local bd=ad.side
local cd=ad.channel;local dd=ad.protocol;local __a=ad.secret;local a_a,b_a=ac.open(bd,cd,dd,__a)if not a_a then
_b.error(
"Failed to open communication channel: "..b_a)end end;return true end
function ac.getSettings()local dc={}
for _d,ad in pairs(ac.communicationChannels)do
for bd,cd in pairs(ad)do for dd,__a in pairs(cd)do
table.insert(dc,{side=_d,channel=bd,protocol=dd,secret=__a.secret})end end end;return dc end
function ac.getOpenChannels()local dc={}
for _d,ad in pairs(ac.communicationChannels)do
for bd,cd in pairs(ad)do for dd,__a in pairs(cd)do
table.insert(dc,ac.communicationChannels[_d][bd][dd])end end end;return dc end;return ac end
modules["programs.command.CommandLine"] = function(...) local ba={}ba.__index=ba
function ba.filterSuggestions(cb,db)local _c={}
local ac=string.lower(db or"")for bc,cc in ipairs(cb)do local dc=string.lower(cc)
if dc:find(ac,1,true)==1 then
local _d=cc:sub(#db+1)if _d~=""then table.insert(_c,_d)end end end
return _c end
function ba:new(cb)local db=setmetatable({},ba)db.suffix=cb or"> "
db.commands={help={name="help",description="Display available commands",func=function(_c)
print("Available commands:")for ac,bc in pairs(db.commands)do
print(string.format(" - %s: %s",ac,bc.description))end end}}return db end
local ca=function(cb)local db=string.find(cb," ")if db then
return string.sub(cb,1,db-1),true else return cb,false end end;local da=function(cb,db)return cb.commands[db]end
local _b=function(cb,db)
local _c={}local ac,bc=ca(db)
if bc then local cc=da(cb,ac)
if cc and cc.complete then
local dc=string.sub(db,#ac+2)_c=cc.complete(dc)or{}end else local cc={}for dc,_d in pairs(cb.commands)do
if dc:find(ac)==1 then table.insert(cc,dc)end end
_c=ba.filterSuggestions(cc,ac)end;return _c end
local function ab(cb,db)local _c,ac=#cb,#db;local bc={}for i=0,_c do bc[i]={}bc[i][0]=i end;for j=0,ac do
bc[0][j]=j end
for i=1,_c do for j=1,ac do
local cc=(cb:sub(i,i)==db:sub(j,j))and 0 or 1
bc[i][j]=math.min(bc[i-1][j]+1,bc[i][j-1]+1,bc[i-1][j-1]+cc)end end;return bc[_c][ac]end
local function bb(cb,db)local _c=nil;local ac=math.huge;local bc=3
for cc,dc in pairs(cb.commands)do
local _d=ab(db:lower(),cc:lower())if _d<ac and _d<=bc then ac=_d;_c=cc end end;return _c end;function ba:addCommand(cb,db,_c,ac)
self.commands[cb]={name=cb,description=db,func=_c,complete=ac}return self end
function ba:run()
write(self.suffix)
local cb=read(nil,nil,function(bc)return _b(self,bc)end)local db,_c=ca(cb)local ac=da(self,db)
if ac then return ac.func(cb)else local bc=bb(self,db)
if bc then print(
"Unknown command: "..db)
print("Do you mean \""..bc.."\"?")else print("Unknown command: "..db)end end end;function ba:changeSuffix(cb)self.suffix=cb end;return ba end
modules["utils.OSUtils"] = function(...) local c=require("utils.Logger")local d={}
d.SIDES={TOP="top",BOTTOM="bottom",LEFT="left",RIGHT="right",FRONT="front",BACK="back"}
d.timestampBaseIdGenerate=function()local _a=os.epoch("utc")
local aa=math.random(1000,9999)return tostring(_a).."-"..tostring(aa)end
d.loadTable=function(_a)local aa={}local ba=fs.open(_a,"r")if ba then local ca=ba.readAll()
aa=textutils.unserialize(ca)ba.close()else return nil end;return aa end
d.saveTable=function(_a,aa)local ba
local ca,da=xpcall(function()ba=textutils.serialize(aa)end,function(ab)
return ab end)if not ca then
c.error("Failed to serialize table for {}, error: {}",_a,da)return end;local _b=fs.open(_a,"w")if _b then
_b.write(ba)_b.close()else
c.error("Failed to open file for writing: {}",_a)end end;return d end
modules["programs.recipe.manager.Trigger"] = function(...) local b={}
b.TYPES={FLUID_COUNT="fluid_count",ITEM_COUNT="item_count",REDSTONE_SIGNAL="redstone_signal"}
b.CONDITION_TYPES={COUNT_GREATER="count_greater",COUNT_LESS="count_less",COUNT_EQUAL="count_equal"}
b.eval=function(c,d)if not c or not c.children then return true end
for _a,aa in
ipairs(c.children)do if b.evalTriggerNode(aa,d)then return true end end;return false end
b.evalTriggerNode=function(c,d)if not c or not c.data then return true end;local _a=c.data
local aa=false
if _a.triggerType==b.TYPES.ITEM_COUNT then
aa=b.evalItemCountTrigger(_a,d)elseif _a.triggerType==b.TYPES.FLUID_COUNT then
aa=b.evalFluidCountTrigger(_a,d)elseif _a.triggerType==b.TYPES.REDSTONE_SIGNAL then
aa=b.evalRedstoneSignalTrigger(_a,d)else return true end;local ba=true;if c.children and#c.children>0 then ba=false
for ca,da in ipairs(c.children)do if
b.evalTriggerNode(da,d)then ba=true;break end end end
return aa and ba end
b.evalItemCountTrigger=function(c,d)if not c.itemName or not d then return false end
local _a=0;local aa=d("item",c.itemName)if aa then _a=aa.count or 0 end;return
b.evalCondition(_a,c.amount,c.triggerConditionType)end
b.evalFluidCountTrigger=function(c,d)if not c.itemName or not d then return false end
local _a=0;local aa=d("fluid",c.itemName)if aa then _a=aa.amount or 0 end;return
b.evalCondition(_a,c.amount,c.triggerConditionType)end;b.evalRedstoneSignalTrigger=function(c,d)return true end
b.evalCondition=function(c,d,_a)
if _a==
b.CONDITION_TYPES.COUNT_GREATER then return c>d elseif _a==b.CONDITION_TYPES.COUNT_LESS then return c<d elseif _a==
b.CONDITION_TYPES.COUNT_EQUAL then return c==d else return false end end;return b end
modules["wrapper.PeripheralWrapper"] = function(...) local d=require("utils.Logger")local _a={}
local aa={DEFAULT_INVENTORY=1,UNLIMITED_PERIPHERAL_INVENTORY=2,TANK=3,REDSTONE=4}_a.SIDES={"top","bottom","left","right","front","back"}
_a.loadedPeripherals={}
_a.wrap=function(ba)if ba==nil or ba==""then
error("Peripheral name cannot be nil or empty")end;local ca=peripheral.wrap(ba)
_a.addBaseMethods(ca,ba)if ca==nil then
error("Failed to wrap peripheral '"..ba.."'")end;if ca.isInventory()then
_a.addInventoryMethods(ca)end
if ca.isTank()then _a.addTankMethods(ca)end
if ca.isRedstone()then _a.addRedstoneMethods(ca)end;return ca end
_a.addBaseMethods=function(ba,ca)
if ba==nil then error("Peripheral cannot be nil")end;if ba.getTypes==nil then ba._types=_a.getTypes(ba)
ba.getTypes=function()return ba._types end end
if ba.isTypeOf==nil then ba.isTypeOf=function(da)return
_a.isTypeOf(ba,da)end end;ba._id=ca;ba.getName=function()return ba._id end
ba.getId=function()return ba._id end;ba._isInventory=_a.isInventory(ba)
ba.isInventory=function()return ba._isInventory end;ba._isTank=_a.isTank(ba)
ba.isTank=function()return ba._isTank end;ba._isRedstone=_a.isRedstone(ba)
ba.isRedstone=function()return ba._isRedstone end
ba._isDefaultInventory=_a.isTypeOf(ba,aa.DEFAULT_INVENTORY)
ba.isDefaultInventory=function()return ba._isDefaultInventory end
ba._isUnlimitedPeripheralInventory=_a.isTypeOf(ba,aa.UNLIMITED_PERIPHERAL_INVENTORY)
ba.isUnlimitedPeripheralInventory=function()return ba._isUnlimitedPeripheralInventory end end
_a.addInventoryMethods=function(ba)
if _a.isTypeOf(ba,aa.DEFAULT_INVENTORY)then
ba.getItems=function()local ca={}local da={}
for _b,ab in
pairs(ba.list())do if ca[ab.name]==nil then ca[ab.name]={name=ab.name,count=0}
table.insert(da,ca[ab.name])end;ca[ab.name].count=
ca[ab.name].count+ab.count end;return da,ca end
ba.getItem=function(ca)local da,_b=ba.getItems()if _b[ca]then return _b[ca]end;return nil end
ba.transferItemTo=function(ca,da,_b)
if ca.isDefaultInventory()then local ab=ba.size()local bb=0
for slot=1,ab do
local cb=ba.getItemDetail(slot)
if cb~=nil and cb.name==da then local db=math.min(cb.count,_b)
local _c=ba.pushItems(ca.getName(),slot,db)if _c==0 then return bb end;bb=bb+_c;_b=_b-_c end;if _b<=0 then return bb end end;return bb elseif ca.isUnlimitedPeripheralInventory()then local ab=0
while ab<_b do
local bb=ca.pullItem(ba.getName(),da,_b-ab)if bb==0 then return ab end;ab=ab+bb end;return ab end;return 0 end
ba.transferItemFrom=function(ca,da,_b)
if ca.isDefaultInventory()then local ab=ca.size()local bb=0
for slot=1,ab do
local cb=ca.getItemDetail(slot)
if cb~=nil and cb.name==da then
local db=ba.pullItems(ca.getName(),slot,_b)if db==0 then return bb end;bb=bb+db;_b=_b-db end;if _b<=0 then return bb end end;return bb elseif ca.isUnlimitedPeripheralInventory()then local ab=0
while ab<_b do
local bb=ca.pushItem(ba.getName(),da,_b-ab)if bb==0 then return ab end;ab=ab+bb end;return ab end end elseif ba.isUnlimitedPeripheralInventory()then
if
string.find(ba.getName(),"crafting_storage")then
ba.getItems=function()local ca=ba.items()for da,_b in ipairs(ca)do _b.displayName=_b.name
_b.name=_b.technicalName end;return ca end
ba.getItemFinder=function(ca)local da=nil
return
function()local _b=ba.items()
if not _b or#_b==0 then return nil end
if da~=nil and _b[da]and _b[da].technicalName==ca then
local ab,bb=_b[da],da;ab.displayName=ab.name;ab.name=ab.technicalName;return ab,bb end
for ab,bb in ipairs(_b)do if bb.technicalName==ca then da=ab;bb.displayName=bb.name
bb.name=bb.technicalName;return bb,da end end;return nil end end else ba.getItems=function()return ba.items()end
ba.getItemFinder=function(ca)
local da=nil
return
function()local _b=ba.items()if not _b or#_b==0 then return nil end
if
da~=nil and _b[da]and _b[da].name==ca then local ab,bb=_b[da],da;return ab,bb end
for ab,bb in ipairs(_b)do if bb.name==ca then da=ab;return bb,da end end;return nil end end end;ba._itemFinders={}
ba.getItem=function(ca)if ba._itemFinders[ca]==nil then
ba._itemFinders[ca]=ba.getItemFinder(ca)end
return ba._itemFinders[ca]()end
ba.transferItemTo=function(ca,da,_b)local ab=0
while ab<_b do
local bb=ba.pushItem(ca.getName(),da,_b-ab)if bb==0 then return ab end;ab=ab+bb end;return ab end
ba.transferItemFrom=function(ca,da,_b)local ab=0
while ab<_b do
local bb=ba.pullItem(ca.getName(),da,_b-ab)if bb==0 then return ab end;ab=ab+bb end;return ab end else
error("Peripheral "..
ba.getName().." types "..table.concat(_a.getTypes(ba),", ")..
" is not an inventory")end end
_a.addTankMethods=function(ba)
if ba==nil then error("Peripheral cannot be nil")end
if not _a.isTank(ba)then error("Peripheral is not a tank")end
ba.getFluids=function()local ca={}local da={}
for _b,ab in pairs(ba.tanks())do
if ca[ab.name]==nil then
ca[ab.name]={name=ab.name,amount=0}table.insert(da,ca[ab.name])end
ca[ab.name].amount=ca[ab.name].amount+ab.amount end;return da end
ba.getFluidFinder=function(ca)local da=nil
return
function()local _b=ba.tanks()
if not _b or#_b==0 then return nil end
if da~=nil and _b[da]and _b[da].name==ca then return _b[da],da end
for ab,bb in ipairs(_b)do if bb.name==ca then da=ab;return bb,da end end;return nil end end;ba._fluidFinders={}
ba.getFluid=function(ca)if ba._fluidFinders[ca]==nil then
ba._fluidFinders[ca]=ba.getFluidFinder(ca)end
return ba._fluidFinders[ca]()end
ba.transferFluidTo=function(ca,da,_b)if ca.isTank()==false then
error(string.format("Peripheral '%s' is not a tank",ca.getName()))end;local ab=0;while ab<_b do local bb=ba.pushFluid(ca.getName(),
_b-ab,da)if bb==0 then return ab end
ab=ab+bb end;return ab end
ba.transferFluidFrom=function(ca,da,_b)if ca.isTank()==false then
error(string.format("Peripheral '%s' is not a tank",ca.getName()))end;local ab=0;while ab<_b do local bb=ba.pullFluid(ca.getName(),
_b-ab,da)if bb==0 then return ab end
ab=ab+bb end;return ab end end
_a.addRedstoneMethods=function(ba)
if ba==nil then error("Peripheral cannot be nil")end;if not _a.isRedstone(ba)then
error("Peripheral is not a redstone peripheral")end
ba.setOutputSignals=function(ca,...)local da={...}if
not da or#da==0 then da=_a.SIDES end;for _b,ab in ipairs(da)do if ba.getOutput(ab)~=ca then
ba.setOutput(ab,ca)end end end
ba.getInputSignals=function(...)local ca={...}if not ca or#ca==0 then ca=_a.SIDES end
for da,_b in
ipairs(ca)do if ba.getInput(_b)then return true end end;return false end
ba.getOutputSignals=function(...)local ca={...}if not ca or#ca==0 then ca=_a.SIDES end
local da={}for _b,ab in ipairs(ca)do da[ab]=ba.getOutput(ab)end;return da end end
_a.getTypes=function(ba)if ba._types~=nil then return ba._types end;local ca={}if ba.list~=nil then
table.insert(ca,aa.DEFAULT_INVENTORY)end;if ba.items~=nil then
table.insert(ca,aa.UNLIMITED_PERIPHERAL_INVENTORY)end;if ba.tanks~=nil then
table.insert(ca,aa.TANK)end;if ba.getInput~=nil then
table.insert(ca,aa.REDSTONE)end;ba._types=ca;return ca end
_a.isInventory=function(ba)local ca=_a.getTypes(ba)
if ba._isInventory~=nil then return ba._isInventory end;for da,_b in ipairs(ca)do
if
_b==aa.DEFAULT_INVENTORY or _b==aa.UNLIMITED_PERIPHERAL_INVENTORY then ba._isInventory=true;return true end end
ba._isInventory=false;return false end
_a.isTank=function(ba)local ca=_a.getTypes(ba)
if ba._isTank~=nil then return ba._isTank end
for da,_b in ipairs(ca)do if _b==aa.TANK then ba._isTank=true;return true end end;ba._isTank=false;return false end
_a.isRedstone=function(ba)local ca=_a.getTypes(ba)
if ba._isRedstone~=nil then return ba._isRedstone end;for da,_b in ipairs(ca)do
if _b==aa.REDSTONE then ba._isRedstone=true;return true end end;ba._isRedstone=false;return false end
_a.isTypeOf=function(ba,ca)
if ba==nil then error("Peripheral cannot be nil")end;if ca==nil then error("Type cannot be nil")end
local da=_a.getTypes(ba)for _b,ab in ipairs(da)do if ab==ca then return true end end;return false end
_a.addPeripherals=function(ba)
if ba==nil then error("Peripheral name cannot be nil")end;local ca=_a.wrap(ba)
if ca~=nil then _a.loadedPeripherals[ba]=ca end end
_a.reloadAll=function()_a.loadedPeripherals={}for ba,ca in ipairs(peripheral.getNames())do
_a.addPeripherals(ca)end end
_a.getAll=function()
if _a.loadedPeripherals==nil then _a.reloadAll()end;return _a.loadedPeripherals end
_a.getByName=function(ba)
if ba==nil then error("Peripheral name cannot be nil")end
if _a.loadedPeripherals[ba]==nil then _a.addPeripherals(ba)end;return _a.loadedPeripherals[ba]end
_a.getByTypes=function(ba)if ba==nil or#ba==0 then
error("Types cannot be nil or empty")end;local ca={}
for da,_b in pairs(_a.getAll())do for ab,bb in ipairs(ba)do if
_a.isTypeOf(_b,bb)then ca[da]=_b;break end end end;return ca end
_a.getAllPeripheralsNameContains=function(ba)if ba==nil or ba==""then
error("Part of name input cannot be nil or empty")end;local ca={}
for da,_b in pairs(_a.getAll())do
d.debug("Checking peripheral: {}",da)if string.find(da,ba)then ca[da]=_b end end;return ca end;return _a end
modules["utils.TableUtils"] = function(...) local b={}
b.findInArray=function(c,d)if c==nil or d==nil then return nil end;for _a,aa in ipairs(c)do
if d(aa)then return _a end end;return nil end
b.getLength=function(c)if c==nil then return 0 end;local d=0;for _a in pairs(c)do d=d+1 end;return d end
b.getAllKeyValueAsTreeString=function(c,d,_a)d=d or""_a=_a or{}if _a[c]then
return d.."<circular reference>\n"end;_a[c]=true;local aa=d.."{\n"
for ba,ca in pairs(c)do
aa=aa..d.."  ["..tostring(ba)..
"] = "
if type(ca)=="table"then
aa=aa..b.getAllKeyValueAsTreeString(ca,d.."  ",_a)elseif type(ca)=="function"then aa=aa.."function\n"else
aa=aa..tostring(ca).."\n"end end;aa=aa..d.."}\n"return aa end;return b end
modules["programs.common.BlazeBurnerFeederFactory"] = function(...) local b={}
b.Types={LAVA="minecraft:lava",HELLFIRE="kubejs:hellfire"}
b.getFeeder=function(c,d,_a,aa)if _a==nil then _a=b.Types.LAVA end
if aa==nil then if _a==b.Types.LAVA then
aa=2000000 elseif _a==b.Types.HELLFIRE then aa=1000000 end end
return
{start_timestamp=0,reset=function(ba)ba.start_timestamp=os.epoch()end,feed=function(ba)
local ca=os.epoch()if ca-ba.start_timestamp>=aa then c.transferFluidTo(d,_a,49)
ba:reset()end end}end;return b end
modules["programs.recipe.manager.StoreManager"] = function(...) local aa=require("utils.OSUtils")
local ba=require("utils.Logger")local ca={machines={depot={},basin={},belt={},common={}}}
ca.MACHINE_TYPES={depot="depot",basin="basin",belt="belt",common="common"}ca.DEPOT_TYPES={NONE=0,FIRE=1,SOUL_FIRE=2,LAVA=3,WATER=4}
ca.BLAZE_BURN_TYPE={NONE=0,LAVA=1,HELLFIRE=2}
ca.saveTable=function(ab)aa.saveTable(ab,ca.machines[ab])end
ca.loadTable=function(ab)local bb=aa.loadTable(ab)
if bb~=nil then ca.machines[ab]=bb end end
local da={depot=function(ab)if ab.input==nil or type(ab.input)~="string"then
return false,
"Depot recipe input is invalid string: "..tostring(ab.input)end;if

ab.output==nil or type(ab.output)~="table"or#ab.output==0 then
return false,"Depot recipe output is invalid table: "..tostring(ab.output)end
return true end,basin=function(ab)if
type(ab)~="table"then
return false,"Basin recipe must be a table, got: "..type(ab)end;if ab.name==nil or
type(ab.name)~="string"or ab.name==""then
return false,
"Basin recipe name must be a non-empty string: "..tostring(ab.name)end;if
ab.input==nil or type(ab.input)~="table"then
return false,
"Basin recipe input must be a table: "..tostring(ab.input)end
local bb=ab.input.items and
type(ab.input.items)=="table"and#ab.input.items>0
local cb=
ab.input.fluids and type(ab.input.fluids)=="table"and#ab.input.fluids>0;if not bb and not cb then
return false,"Basin recipe must have at least one input item or fluid"end
if bb then
for ac,bc in
ipairs(ab.input.items)do
if type(bc)~="string"or bc==""then return false,
"Basin recipe input item at index "..ac.." must be a non-empty string: "..
tostring(bc)end end end
if cb then
for ac,bc in ipairs(ab.input.fluids)do
if type(bc)~="string"or bc==""then return false,

"Basin recipe input fluid at index "..ac.." must be a non-empty string: "..tostring(bc)end end end;if ab.output==nil or type(ab.output)~="table"then
return false,
"Basin recipe output must be a table: "..tostring(ab.output)end
local db=
ab.output.items and type(ab.output.items)=="table"and#
ab.output.items>0
local _c=
ab.output.fluids and type(ab.output.fluids)=="table"and#ab.output.fluids>0;if not db and not _c then
return false,"Basin recipe must have at least one output item or fluid"end
if db then
for ac,bc in
ipairs(ab.output.items)do
if type(bc)~="string"or bc==""then return false,
"Basin recipe output item at index "..ac..
" must be a non-empty string: "..tostring(bc)end end end
if _c then
for ac,bc in ipairs(ab.output.fluids)do
if type(bc)~="string"or bc==""then return false,

"Basin recipe output fluid at index "..ac.." must be a non-empty string: "..tostring(bc)end end end
if ab.output.keepItemsAmount~=nil then
if
type(ab.output.keepItemsAmount)~="number"or ab.output.keepItemsAmount<0 then return false,

"Basin recipe keepItemsAmount must be a non-negative number: "..tostring(ab.output.keepItemsAmount)end end
if ab.output.keepFluidsAmount~=nil then
if
type(ab.output.keepFluidsAmount)~=
"number"or ab.output.keepFluidsAmount<0 then return false,
"Basin recipe keepFluidsAmount must be a non-negative number: "..tostring(ab.output.keepFluidsAmount)end end;if ab.trigger~=nil and type(ab.trigger)~="table"then
return false,
"Basin recipe trigger must be a table if present: "..tostring(ab.trigger)end
return true end,belt=function(ab)if
type(ab)~="table"then
return false,"Belt recipe must be a table, got: "..type(ab)end;if ab.input==nil or
type(ab.input)~="string"or ab.input==""then
return false,
"Belt recipe input must be a non-empty string: "..tostring(ab.input)end
if
ab.output==nil or type(ab.output)~="string"or
ab.output==""then
return false,"Belt recipe output must be a non-empty string: "..
tostring(ab.output)end
if ab.incomplete~=nil then
if
type(ab.incomplete)~="string"or ab.incomplete==""then return false,
"Belt recipe incomplete must be a non-empty string if present: "..tostring(ab.incomplete)end end;if ab.trigger~=nil and type(ab.trigger)~="table"then
return false,
"Belt recipe trigger must be a table if present: "..tostring(ab.trigger)end
return true end,common=function(ab)if
type(ab)~="table"then
return false,"Common recipe must be a table, got: "..type(ab)end;if ab.name==nil or
type(ab.name)~="string"or ab.name==""then
return false,
"Common recipe name must be a non-empty string: "..tostring(ab.name)end;if
ab.input==nil or type(ab.input)~="table"then
return false,
"Common recipe input must be a table: "..tostring(ab.input)end
local bb=ab.input.items and
type(ab.input.items)=="table"and#ab.input.items>0
local cb=
ab.input.fluids and type(ab.input.fluids)=="table"and#ab.input.fluids>0;if not bb and not cb then
return false,"Common recipe must have at least one input item or fluid"end
if bb then
for ac,bc in
ipairs(ab.input.items)do
if type(bc)~="string"or bc==""then return false,
"Common recipe input item at index "..ac..
" must be a non-empty string: "..tostring(bc)end end end
if cb then
for ac,bc in ipairs(ab.input.fluids)do
if type(bc)~="string"or bc==""then return false,

"Common recipe input fluid at index "..ac.." must be a non-empty string: "..tostring(bc)end end end;if ab.output==nil or type(ab.output)~="table"then
return false,
"Common recipe output must be a table: "..tostring(ab.output)end
local db=
ab.output.items and type(ab.output.items)=="table"and#
ab.output.items>0
local _c=
ab.output.fluids and type(ab.output.fluids)=="table"and#ab.output.fluids>0;if not db and not _c then
return false,"Common recipe must have at least one output item or fluid"end
if db then
for ac,bc in
ipairs(ab.output.items)do
if type(bc)~="string"or bc==""then return false,
"Common recipe output item at index "..ac..
" must be a non-empty string: "..tostring(bc)end end end
if _c then
for ac,bc in ipairs(ab.output.fluids)do
if type(bc)~="string"or bc==""then return false,

"Common recipe output fluid at index "..ac.." must be a non-empty string: "..tostring(bc)end end end;if ab.trigger~=nil and type(ab.trigger)~="table"then
return false,
"Common recipe trigger must be a table if present: "..tostring(ab.trigger)end
return true end}
local _b=function(ab)if not ca.MACHINE_TYPES[ab]then return false end;return true end
ca.addRecipe=function(ab,bb)if not _b(ab)then
return false,"Invalid machine type: "..tostring(ab)end;local cb,db=da[ab](bb)
if not cb then return false,db end;local _c=aa.timestampBaseIdGenerate()bb.id=_c
table.insert(ca.machines[ab],bb)ca.saveTable(ab)return true,_c end
ca.removeRecipe=function(ab,bb)if not _b(ab)then
return false,"Invalid machine type: "..tostring(ab)end
for cb,db in ipairs(ca.machines[ab])do if db.id==bb then
table.remove(ca.machines[ab],cb)return true end end;return false,"Recipe not found: "..tostring(bb)end
ca.updateRecipe=function(ab,bb)if not _b(ab)then
return false,"Invalid machine type: "..tostring(ab)end;for cb,db in ipairs(ca.machines[ab])do
if
db.id==bb.id then ca.machines[ab][cb]=bb;ca.saveTable(ab)return true end end;return false,"Recipe not found: "..
tostring(bb.id)end
ca.getAllRecipesByType=function(ab)if not _b(ab)then return{}end
local bb=textutils.serialize(ca.machines[ab])return textutils.unserialize(bb)end
ca.getRecipeByTypeAndId=function(ab,bb)if not _b(ab)then return{}end
for cb,db in ipairs(ca.machines[ab])do if db.id==
bb then
return textutils.unserialize(textutils.serialize(db))end end;return nil end
ca.init=function()
for ab,bb in pairs(ca.MACHINE_TYPES)do ca.loadTable(ab)end end;return ca end
return modules["programs.CaBasin"](...)
