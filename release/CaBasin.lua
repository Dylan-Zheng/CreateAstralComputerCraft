local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CaBasin"] = function(...) local aca=require("utils.Logger")
local bca=require("programs.common.Communicator")local cca=require("programs.command.CommandLine")
local dca=require("utils.OSUtils")local _da=require("programs.common.Trigger")
local ada=require("wrapper.PeripheralWrapper")local bda=require("utils.TableUtils")
local cda=require("programs.common.BlazeBurnerFeederFactory")local dda=require("programs.recipe.manager.StoreManager")
aca.useDefault()aca.currentLevel=aca.levels.ERROR;local __b={...}local a_b={}local b_b={}local c_b={}
local d_b={}local function _ab()local aac=dca.loadTable("cabasin_groups")
if aac~=nil then a_b=aac end end;local function aab()
dca.saveTable("cabasin_groups",a_b)end
local function bab()
local aac=dca.loadTable("cabasin_recipe_links")if aac~=nil then d_b=aac end end
local function cab()dca.saveTable("cabasin_recipe_links",d_b)end;_ab()bab()local function dab()local aac=dca.loadTable("cabasin_recipes")if aac~=nil then
b_b=aac end end;local function _bb()
dca.saveTable("cabasin_recipes",b_b)end;local function abb()
return dca.loadTable("cabasin_communicator_config")end
local function bbb(aac,bac,cac)
local dac={side=aac,channel=bac,secret=cac}dca.saveTable("cabasin_communicator_config",dac)end
local function cbb(aac)local bac={}
for cac,dac in ipairs(b_b)do if dac.id then bac[dac.id]=cac end end;for cac,dac in ipairs(aac)do
if dac.id then local _bc=bac[dac.id]if _bc then b_b[_bc]=dac end end end;_bb()end
local dbb=function(aac)local bac={}
for cac,dac in pairs(aac)do
for _bc,abc in ipairs(dac.basins)do bac[abc]=true end;for _bc,abc in ipairs(dac.blazeBurners)do bac[abc]=true end;for _bc,abc in ipairs(
dac.redstones or{})do bac[abc]=true end end;return bac end
local _cb=function(aac)local bac=peripheral.getNames()local cac={}local dac={}local _bc={}
for abc,bbc in pairs(bac)do
if not
aac[bbc]then
if bbc:find("basin")then table.insert(cac,bbc)end
if bbc:find("blaze_burner")then table.insert(dac,bbc)end
if bbc:find("redrouter")then table.insert(_bc,bbc)end end end;return{basins=cac,blazeBurners=dac,redstones=_bc}end
local function acb(aac,bac,cac,dac)bac=bac or 1;cac=cac or 5;dac=dac or"local"if#aac==0 then
print("No recipes found.")return end;local _bc=math.ceil(#aac/cac)local abc=
(bac-1)*cac+1;local bbc=math.min(abc+cac-1,#aac)
print(string.format("=== Basin Recipes (Page %d/%d) ===",bac,_bc))
for i=abc,bbc do local cbc=aac[i]local dbc=cbc.name or"Unnamed Recipe"
local _cc=d_b[dbc]
if _cc then
print(string.format("%d. %s -> [%s]",i,dbc,_cc))else print(string.format("%d. %s",i,dbc))end end
if _bc>1 then
print(string.format("Showing %d-%d of %d recipes",abc,bbc,#aac))if bac<_bc then
print(string.format("Use 'list recipe %s %d' for next page",dac,bac+1))end;if bac>1 then
print(string.format("Use 'list recipe %s %d' for previous page",dac,
bac-1))end end end
local function bcb()
if bda.getLength(a_b)==0 then print("No groups found.")return end;print("=== Basin Groups ===")local aac=0;for bac,cac in pairs(a_b)do aac=aac+1
print(string.format("%d. %s - Basins: %d, Burners: %d",aac,bac,
#cac.basins,#cac.blazeBurners))end end
local function ccb()local aac=0;for bac,cac in pairs(d_b)do aac=aac+1 end;if aac==0 then
print("No recipe-group links found.")return end
print("=== Recipe-Group Links ===")for bac,cac in pairs(d_b)do
print(string.format("%s -> %s",bac,cac))end end
local function dcb()local aac=cca:new("cabasin> ")
aac:addCommand("group","Manage basin groups",function(bac)local cac={}for abc in
bac:gmatch("%S+")do table.insert(cac,abc)end;if#cac<2 then
print("Usage: group [name]")
print("Creates a new group with the given name using current basins and blaze burners")return end
local dac=cac[2]local _bc=_cb(dbb(a_b))a_b[dac]=_bc;aab()print("Group '"..
dac.."' created successfully:")print(
"  Name: "..dac)
print("  Basins: "..#_bc.basins.." found")for abc,bbc in ipairs(_bc.basins)do
print("    "..abc..". "..bbc)end
print("  Blaze Burners: "..
#_bc.blazeBurners.." found")for abc,bbc in ipairs(_bc.blazeBurners)do
print("    "..abc..". "..bbc)end
print("  Redstone Routers: "..
#_bc.redstones.." found")for abc,bbc in ipairs(_bc.redstones)do
print("    "..abc..". "..bbc)end end,function(bac)return
{}end)
aac:addCommand("list","List recipes or groups",function(bac)local cac={}for _bc in bac:gmatch("%S+")do
table.insert(cac,_bc)end
if#cac<2 then
print("Usage: list [recipe|group|link] [remote|local] [page]")print("Examples:")
print("  list group              - List all groups")
print("  list link               - List recipe-group links")
print("  list recipe remote      - List remote recipes")
print("  list recipe local       - List local recipes")
print("  list recipe local 2     - List local recipes page 2")return end;local dac=cac[2]
if dac=="group"then bcb()elseif dac=="link"then ccb()elseif dac=="recipe"then if#cac<3 then
print("Usage: list recipe [remote|local] [page]")return end;local _bc=cac[3]
local abc=tonumber(cac[4])or 1
if _bc=="local"then acb(b_b,abc,nil,"local")elseif _bc=="remote"then if#c_b==0 then
print("No remote recipes available.")return end;acb(c_b,abc,nil,"remote")else
print("Usage: list recipe [remote|local] [page]")end elseif dac=="link"then ccb()else
print("Usage: list [recipe|group] [remote|local] [page]")print("Available list types: recipe, group")end end,function(bac)
local cac={}
for _bc in bac:gmatch("%S+")do table.insert(cac,_bc)end;local dac=#cac
if(dac==0 or dac==1)and bac:sub(-1)~=" "then local _bc=
bac:match("%S+$")or""local abc={}
local bbc={"recipe","group","link"}
for cbc,dbc in ipairs(bbc)do if dbc:find(_bc,1,true)==1 then
table.insert(abc,dbc:sub(#_bc+1))end end;return abc elseif(dac==1 and bac:sub(-1)==" ")or dac==2 then
if
cac[1]=="recipe"then local _bc=bac:match("%S+$")or""local abc={}
local bbc={"remote","local"}
for cbc,dbc in ipairs(bbc)do if dbc:find(_bc,1,true)==1 then
table.insert(abc,dbc:sub(#_bc+1))end end;return abc end end;return{}end)
aac:addCommand("add","Add recipe from remote by name",function(bac)local cac={}for bbc in bac:gmatch("%S+")do
table.insert(cac,bbc)end
if#cac<2 then
print("Usage: add [recipe_name]")print("Examples:")
print("  add SteelRecipe            - Add recipe by name")
print("Use 'list recipe remote' to see available recipes")return end;local dac=cac[2]if#c_b==0 then
print("No remote recipes available. Use network mode to connect first.")return end;local _bc=nil;for bbc,cbc in ipairs(c_b)do if cbc.name==
dac then _bc=cbc;break end end;if
not _bc then
print("Remote recipe '"..dac.."' not found")
print("Use 'list recipe remote' to see available recipes")return end
for bbc,cbc in
ipairs(b_b)do if cbc.name==dac then
print("Recipe '"..dac.."' already exists locally")return end end;local abc={}
for bbc,cbc in pairs(_bc)do
if type(cbc)=="table"then abc[bbc]={}
for dbc,_cc in pairs(cbc)do
if
type(_cc)=="table"then abc[bbc][dbc]={}
for acc,bcc in ipairs(_cc)do abc[bbc][dbc][acc]=bcc end else abc[bbc][dbc]=_cc end end else abc[bbc]=cbc end end;table.insert(b_b,abc)_bb()
print("Recipe '"..dac.."' added successfully")end,function(bac)
local cac={}local dac=bac:match("%S+$")or""for _bc,abc in ipairs(c_b)do
if abc.name and
abc.name:find(dac,1,true)==1 then
local bbc=abc.name:sub(#dac+1)table.insert(cac,bbc)end end;return cac end)
aac:addCommand("link","Link recipe to group",function(bac)local cac={}for bbc in bac:gmatch("%S+")do
table.insert(cac,bbc)end
if#cac<3 then
print("Usage: link [recipe_name] [group_name]")print("Examples:")
print("  link SteelRecipe production      - Link recipe to group")return end;local dac=cac[2]local _bc=cac[3]local abc=false;for bbc,cbc in ipairs(b_b)do
if cbc.name==dac then abc=true;break end end;if not abc then
print("Recipe '"..
dac.."' not found in local recipes")
print("Use 'list recipe local' to see available recipes")return end;if not
a_b[_bc]then
print("Group '".._bc.."' not found")print("Use 'list group' to see available groups")
return end;d_b[dac]=_bc
cab()
print("Recipe '"..
dac.."' linked to group '".._bc.."' successfully")end,function(bac)
local cac={}
for dac in bac:gmatch("%S+")do table.insert(cac,dac)end
if#cac==1 then local dac={}local _bc=bac:match("%S+$")or""for abc,bbc in ipairs(b_b)do
if bbc.name and
bbc.name:find(_bc,1,true)==1 then
local cbc=bbc.name:sub(#_bc+1)table.insert(dac,cbc)end end;return dac elseif#
cac==2 then local dac={}local _bc=bac:match("%S+$")or""for abc,bbc in pairs(a_b)do
if
abc:find(_bc,1,true)==1 then table.insert(dac,abc:sub(#_bc+1))end end;return dac end;return{}end)
aac:addCommand("unlink","Unlink recipe from group",function(bac)local cac={}for abc in bac:gmatch("%S+")do
table.insert(cac,abc)end;if#cac<2 then
print("Usage: unlink [recipe_name]")print("Examples:")
print("  unlink SteelRecipe     - Unlink recipe from group")return end
local dac=cac[2]if not d_b[dac]then
print("Recipe '"..dac.."' is not linked to any group")return end;local _bc=d_b[dac]
d_b[dac]=nil;cab()
print("Recipe '"..
dac.."' unlinked from group '".._bc.."' successfully")end,function(bac)
local cac={}local dac=bac:match("%S+$")or""for _bc,abc in pairs(d_b)do
if
_bc:find(dac,1,true)==1 then local bbc=_bc:sub(#dac+1)table.insert(cac,bbc)end end;return cac end)
aac:addCommand("delete","Delete group or recipe",function(bac)local cac={}for abc in bac:gmatch("%S+")do
table.insert(cac,abc)end
if#cac<3 then
print("Usage: delete [group|recipe] [name]")print("Examples:")
print("  delete group production     - Delete group by name")
print("  delete recipe SteelRecipe   - Delete recipe by name")return end;local dac=cac[2]local _bc=cac[3]
if dac=="group"then if not a_b[_bc]then
print("Group '".._bc.."' not found")print("Use 'list group' to see available groups")
return end;local abc={}
for bbc,cbc in pairs(d_b)do if
cbc==_bc then table.insert(abc,bbc)end end
if#abc>0 then
print("Cannot delete group '".._bc.."' - it has linked recipes:")
for bbc,cbc in ipairs(abc)do print("  "..bbc..". "..cbc)end
print("Use 'unlink [recipe_name]' to unlink recipes first")return end;a_b[_bc]=nil;aab()
print("Group '".._bc.."' deleted successfully")elseif dac=="recipe"then local abc=nil
for bbc,cbc in ipairs(b_b)do if cbc.name==_bc then abc=bbc;break end end;if not abc then
print("Recipe '".._bc.."' not found in local recipes")
print("Use 'list recipe local' to see available recipes")return end
if
d_b[_bc]then
print("Cannot delete recipe '"..
_bc.."' - it is linked to group '"..d_b[_bc].."'")
print("Use 'unlink ".._bc.."' to unlink the recipe first")return end;table.remove(b_b,abc)_bb()
print("Recipe '".._bc.."' deleted successfully")else print("Usage: delete [group|recipe] [name]")
print("Available delete types: group, recipe")end end,function(bac)
local cac={}
for _bc in bac:gmatch("%S+")do table.insert(cac,_bc)end;local dac=#cac
if(dac==0 or dac==1)and bac:sub(-1)~=" "then
local _bc={}local abc=bac:match("%S+$")or""local bbc={"group","recipe"}
for cbc,dbc in
ipairs(bbc)do if dbc:find(abc,1,true)==1 then
table.insert(_bc,dbc:sub(#abc+1))end end;return _bc elseif(dac==1 and bac:sub(-1)==" ")or dac==2 then
local _bc=cac[1]local abc=bac:match("%S+$")or""local bbc={}
if _bc=="group"then for cbc,dbc in pairs(a_b)do
if
cbc:find(abc,1,true)==1 then table.insert(bbc,cbc:sub(#abc+1))end end elseif _bc=="recipe"then for cbc,dbc in ipairs(b_b)do
if
dbc.name and dbc.name:find(abc,1,true)==1 then local _cc=dbc.name:sub(
#abc+1)table.insert(bbc,_cc)end end end;return bbc end;return{}end)
aac:addCommand("reboot","Reboot the program",function(bac)print("Rebooting...")os.reboot()end)return aac end;dab()
local _db=function()local aac=dcb()while true do
local bac,cac=pcall(function()aac:run()end)
if not bac then print("Error: "..tostring(cac))end end end
if __b~=nil and#__b>0 then local aac=__b[1]local bac=tonumber(__b[2])
local cac=__b[3]
if aac and bac and cac then bbb(aac,bac,cac)
bca.open(aac,bac,"recipe",cac)
local dac=bca.communicationChannels[aac][bac]["recipe"]
dac.addMessageHandler("getRecipesRes",function(_bc,abc,bbc)c_b=abc or{}end)
parallel.waitForAll(bca.listen,function()while next(c_b)==nil do
dac.send("getRecipesReq","basin")os.sleep(1)end end,_db)end end;ada.reloadAll()
local adb=ada.getAllPeripheralsNameContains("crafting_storage")local bdb=next(adb)local cdb=adb[bdb]local ddb={}
local __c=function()local aac={}for bac,cac in pairs(b_b)do
aac[cac.name]=cac end
for bac,cac in pairs(d_b)do ddb[bac]={recipe=aac[bac]}
local dac={name=cac,basins={},blazeBurnerFeeders={},redstones={}}
for _bc,abc in ipairs(a_b[cac].basins)do
print("Wrapping basin: "..abc)table.insert(dac.basins,ada.wrap(abc))end
for _bc,abc in ipairs(a_b[cac].blazeBurners)do
print("Wrapping blaze burner: "..abc)local bbc=ada.wrap(abc)local cbc=nil
if
aac[bac].blazeBurner==dda.BLAZE_BURN_TYPE.LAVA then cbc=cda.Types.LAVA elseif
aac[bac].blazeBurner==dda.BLAZE_BURN_TYPE.HELLFIRE then cbc=cda.Types.HELLFIRE end;local dbc=cda.getFeeder(cdb,bbc,cbc)
table.insert(dac.blazeBurnerFeeders,dbc)end
for _bc,abc in ipairs(a_b[cac].redstones)do
print("Wrapping redstone: "..abc)table.insert(dac.redstones,ada.wrap(abc))end;ddb[bac].group=dac end end
local a_c=function(aac,bac)if aac=="item"then return cdb.getItem(bac)elseif aac=="fluid"then
return cdb.getFluid(bac)end;return nil end
local b_c=function(aac)local bac=aac.recipe;local cac=aac.group
for dac,_bc in ipairs(cac.basins)do local abc=bac.input
if
abc.items~=nil then
for cbc,dbc in ipairs(abc.items)do local _cc=_bc.getItem(dbc)
local acc=_cc and _cc.count or 0
if acc<16 then cdb.transferItemTo(_bc,dbc,16 -acc)end end end
if abc.fluids~=nil then
for cbc,dbc in ipairs(abc.fluids)do local _cc=_bc.getFluid(dbc)local acc=
_cc and _cc.amount or 0;if acc<1000 then
cdb.transferFluidTo(_bc,dbc,1000 -acc)end end end;local bbc=bac.output
if bbc.items~=nil then
for cbc,dbc in ipairs(bbc.items)do
local _cc=bac.output.keepItemsAmount or 0;local acc=_bc.getItem(dbc)
if acc~=nil and acc.count>_cc then cdb.transferItemFrom(_bc,dbc,
acc.count-_cc)end end end
if bbc.fluids~=nil then
for cbc,dbc in ipairs(bbc.fluids)do
local _cc=bac.output.keepFluidsAmount or 0;local acc=_bc.getFluid(dbc)
if acc~=nil and acc.amount>_cc then cdb.transferFluidFrom(_bc,dbc,
acc.amount-_cc)end end end end end
local c_c=function(aac)for bac,cac in ipairs(aac)do cac:feed()end end
local d_c=function()
while true do
for aac,bac in pairs(ddb)do local cac=_da.eval(bac.recipe.trigger,a_c)
local dac=bac.group.redstones;if dac~=nil then
for _bc,abc in ipairs(dac)do abc.setOutputSignals(not cac)end end;if(cac)then b_c(bac)
c_c(bac.group.blazeBurnerFeeders)end end;os.sleep(1)end end;__c()
local _ac=function()local aac=abb()
if
aac and aac.side and aac.channel and aac.secret then
print("Found saved communicator config, attempting to connect...")
bca.open(aac.side,aac.channel,"recipe",aac.secret)
local bac=bca.communicationChannels[aac.side][aac.channel]["recipe"]
bac.addMessageHandler("getRecipesRes",function(cac,dac,_bc)c_b=dac or{}end)
bac.addMessageHandler("update",function(cac,dac,_bc)if dac and type(dac)=="table"then cbb(dac)__c()
bac.send("getRecipesReq","basin")end end)bca.listen()end end;parallel.waitForAny(_ac,d_c,_db) end
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
function ba.filterSuggestions(cb,db)local _c={}db=db or""
local ac=string.lower(db)for bc,cc in ipairs(cb)do local dc=string.lower(cc)
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
modules["programs.common.Trigger"] = function(...) local c=require("utils.Logger")local d={}
d.TYPES={FLUID_COUNT="fluid_count",ITEM_COUNT="item_count",REDSTONE_SIGNAL="redstone_signal"}
d.CONDITION_TYPES={COUNT_GREATER="count_greater",COUNT_LESS="count_less",COUNT_EQUAL="count_equal"}
d.eval=function(_a,aa)if not _a or not _a.children then return true end
for ba,ca in
ipairs(_a.children)do if d.evalTriggerNode(ca,aa)then return true end end;return false end
d.evalTriggerNode=function(_a,aa)if not _a or not _a.data then return true end
local ba=_a.data;local ca=false
if ba.triggerType==d.TYPES.ITEM_COUNT then
ca=d.evalItemCountTrigger(ba,aa)elseif ba.triggerType==d.TYPES.FLUID_COUNT then
ca=d.evalFluidCountTrigger(ba,aa)elseif ba.triggerType==d.TYPES.REDSTONE_SIGNAL then
ca=d.evalRedstoneSignalTrigger(ba,aa)else return true end;local da=true;if _a.children and#_a.children>0 then da=false
for _b,ab in
ipairs(_a.children)do if d.evalTriggerNode(ab,aa)then da=true;break end end end;return
ca and da end
d.evalItemCountTrigger=function(_a,aa)
if not _a.itemName or not aa then return false end;local ba=0;local ca=aa("item",_a.itemName)
if ca then ba=ca.count or 0 end
return d.evalCondition(ba,_a.amount,_a.triggerConditionType)end
d.evalFluidCountTrigger=function(_a,aa)
if not _a.itemName or not aa then return false end;local ba=0;local ca=aa("fluid",_a.itemName)
if ca then ba=ca.amount or 0 end
return d.evalCondition(ba,_a.amount,_a.triggerConditionType)end;d.evalRedstoneSignalTrigger=function(_a,aa)return true end
d.evalCondition=function(_a,aa,ba)
if ba==
d.CONDITION_TYPES.COUNT_GREATER then return _a>aa elseif ba==d.CONDITION_TYPES.COUNT_LESS then
return _a<aa elseif ba==d.CONDITION_TYPES.COUNT_EQUAL then return _a==aa else return false end end;return d end
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
string.find(ba.getName(),"crafting_storage")or ba.getPatternsFor~=nil then
ba.getItems=function()
local ca=ba.items()
for da,_b in ipairs(ca)do _b.displayName=_b.name;_b.name=_b.technicalName end;return ca end
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
_a.reloadAll=function()_a.loadedPeripherals={}
for ba,ca in ipairs(peripheral.getNames())do
d.debug("Loading peripheral: {}",ca)_a.addPeripherals(ca)end end
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
error("Part of name input cannot be nil or empty")end;local ca={}for da,_b in pairs(_a.getAll())do if
string.find(da,ba)then ca[da]=_b end end;return ca end;return _a end
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
