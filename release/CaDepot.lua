local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CaDepot"] = function(...) local _aa=require("utils.Logger")
local aaa=require("programs.common.Communicator")local baa=require("programs.command.CommandLine")
local caa=require("utils.OSUtils")local daa=require("programs.common.Trigger")
local _ba=require("wrapper.PeripheralWrapper")local aba=require("utils.TableUtils")_aa.useDefault()
_aa.currentLevel=_aa.levels.ERROR;local bba={...}local cba={}local dba={}local function _ca()
local dab=caa.loadTable("cadepot_recipes")if dab~=nil then cba=dab end end;local function aca()
caa.saveTable("cadepot_recipes",cba)end;local function bca()
return caa.loadTable("cadepot_communicator_config")end
local function cca(dab,_bb,abb)
local bbb={side=dab,channel=_bb,secret=abb}caa.saveTable("cadepot_communicator_config",bbb)end
local function dca(dab)local _bb={}
for abb,bbb in ipairs(cba)do if bbb.id then _bb[bbb.id]=abb end end;for abb,bbb in ipairs(dab)do
if bbb.id then local cbb=_bb[bbb.id]if cbb then cba[cbb]=bbb end end end;aca()end;local function _da(dab)
for _bb,abb in ipairs(cba)do if abb.input==dab then return abb end end;return nil end
local function ada(dab)for _bb,abb in ipairs(cba)do
if
abb.input==dab then table.remove(cba,_bb)return true end end;return false end
local function bda(dab,_bb,abb)_bb=_bb or 1;abb=abb or 5;if#dab==0 then print("No recipes found.")
return end;local bbb=math.ceil(#dab/abb)local cbb=
(_bb-1)*abb+1;local dbb=math.min(cbb+abb-1,#dab)
print(string.format("=== Recipes (Page %d/%d) ===",_bb,bbb))
for i=cbb,dbb do local _cb=dab[i]
local acb=
({"none","fire","soul_fire","lava","water"})[_cb.depotType+1]or"unknown"local bcb=table.concat(_cb.output,", ")
print(string.format("%d. [%s] %s -> %s",i,acb,_cb.input,bcb))end
if bbb>1 then
print(string.format("Showing %d-%d of %d recipes",cbb,dbb,#dab))if _bb<bbb then
print(string.format("Use 'list recipe local %d' for next page",_bb+1))end;if _bb>1 then
print(string.format("Use 'list recipe local %d' for previous page",
_bb-1))end end end;_ca()
local function cda()local dab=baa:new("cadepot> ")
dab:addCommand("list","List recipes",function(_bb)local abb={}for _cb in
_bb:gmatch("%S+")do table.insert(abb,_cb)end;if#abb<3 then
print("Usage: list recipe [remote|local] [page]")return end;local bbb=abb[2]local cbb=abb[3]local dbb=
tonumber(abb[4])or 1;if bbb~="recipe"then
print("Usage: list recipe [remote|local] [page]")return end
if cbb=="local"then bda(cba,dbb)elseif cbb==
"remote"then
if#dba==0 then print("No remote recipes available.")return end;bda(dba,dbb)else
print("Usage: list recipe [remote|local] [page]")end end,function(_bb)
local abb={}
for bbb in _bb:gmatch("%S+")do table.insert(abb,bbb)end
if#abb==1 then local bbb=_bb:match("%S+$")or""local cbb={}if
("recipe"):find(bbb,1,true)==1 then
table.insert(cbb,("recipe"):sub(#bbb+1))end;return cbb elseif#abb==2 then
local bbb=_bb:match("%S+$")or""local cbb={}local dbb={"remote","local"}for _cb,acb in ipairs(dbb)do
if
acb:find(bbb,1,true)==1 then table.insert(cbb,acb:sub(#bbb+1))end end;return cbb end;return{}end)
dab:addCommand("add","Add recipe(s) from remote by depotType",function(_bb)local abb={}for _cb in _bb:gmatch("%S+")do
table.insert(abb,_cb)end
if#abb<2 then
print("Usage: add [depotType] [input_name]")
print("DepotTypes: none(0), fire(1), soul_fire(2), lava(3), water(4)")print("Examples:")
print("  add fire minecraft:iron_ore    - Add specific recipe")
print("  add fire                       - Add all fire-type recipes")
print("Use 'list recipe remote' to see available recipes")return end;local bbb=abb[2]local cbb=abb[3]local dbb=nil
if bbb=="none"or bbb=="0"then dbb=0 elseif
bbb=="fire"or bbb=="1"then dbb=1 elseif bbb=="soul_fire"or bbb=="2"then dbb=2 elseif bbb=="lava"or bbb==
"3"then dbb=3 elseif bbb=="water"or bbb=="4"then dbb=4 elseif tonumber(bbb)and
tonumber(bbb)>=0 and tonumber(bbb)<=4 then
dbb=tonumber(bbb)else print("Invalid depotType: "..bbb)
print("Valid depotTypes: none(0), fire(1), soul_fire(2), lava(3), water(4)")return end
if cbb then local _cb=nil
for ccb,dcb in ipairs(dba)do if dcb.input==cbb and dcb.depotType==dbb then
_cb=dcb;break end end
if not _cb then
print("Remote recipe '"..
cbb.."' with depotType "..dbb.." not found")
print("Use 'list recipe remote' to see available remote recipes")return end;if _da(cbb)then
print("Recipe with input '"..cbb.."' already exists locally")return end
local acb={id=_cb.id,input=_cb.input,output=_cb.output,depotType=_cb.depotType,trigger=_cb.trigger,maxMachine=
_cb.maxMachine or-1}table.insert(cba,acb)aca()
print("Recipe added from remote successfully:")print("  Input: "..acb.input)print("  Output: "..
table.concat(acb.output,", "))
local bcb=({"none","fire","soul_fire","lava","water"})[
acb.depotType+1]or"unknown"
print("  DepotType: "..acb.depotType.." ("..bcb..")")else local _cb={}for dcb,_db in ipairs(dba)do
if _db.depotType==dbb then table.insert(_cb,_db)end end
if#_cb==0 then
local dcb=({"none","fire","soul_fire","lava","water"})[
dbb+1]or"unknown"
print("No remote recipes found with depotType "..dbb.." ("..dcb..")")
print("Use 'list recipe remote' to see available remote recipes")return end;local acb=0;local bcb=0
for dcb,_db in ipairs(_cb)do
if not _da(_db.input)then
local adb={id=_db.id,input=_db.input,output=_db.output,depotType=_db.depotType,trigger=_db.trigger,maxMachine=
_db.maxMachine or-1}table.insert(cba,adb)acb=acb+1 else bcb=bcb+1 end end;aca()local ccb=
({"none","fire","soul_fire","lava","water"})[dbb+1]or"unknown"
print(
"Batch add completed for depotType "..dbb.." ("..ccb.."):")print("  Added: "..acb.." recipes")if
bcb>0 then
print("  Skipped: "..bcb.." recipes (already exist)")end end end,function(_bb)
local abb={}
for bbb in _bb:gmatch("%S+")do table.insert(abb,bbb)end
if#abb==1 and _bb:sub(-1)~=" "then
local bbb=_bb:match("%S+$")or""local cbb={}
local dbb={"none","fire","soul_fire","lava","water","0","1","2","3","4"}
for _cb,acb in ipairs(dbb)do if acb:find(bbb,1,true)==1 then
table.insert(cbb,acb:sub(#bbb+1))end end;return cbb elseif#abb==2 then local bbb=abb[2]local cbb=nil
if bbb=="none"or bbb=="0"then cbb=0 elseif
bbb=="fire"or bbb=="1"then cbb=1 elseif bbb=="soul_fire"or bbb=="2"then cbb=2 elseif bbb=="lava"or bbb==
"3"then cbb=3 elseif bbb=="water"or bbb=="4"then cbb=4 elseif tonumber(bbb)and
tonumber(bbb)>=0 and tonumber(bbb)<=4 then
cbb=tonumber(bbb)end
if cbb~=nil then local dbb={}local _cb=_bb:match("%S+$")or""
for acb,bcb in ipairs(dba)do if

bcb.depotType==cbb and bcb.input:find(_cb,1,true)==1 then
table.insert(dbb,bcb.input:sub(#_cb+1))end end;return dbb end end;return{}end)
dab:addCommand("rm","Remove recipe",function(_bb)local abb={}
for _cb in _bb:gmatch("%S+")do table.insert(abb,_cb)end;if#abb<2 then print("Usage: rm [input]")return end
local bbb=abb[2]local cbb=false;local dbb=nil
for _cb,acb in ipairs(cba)do if acb.input==bbb then dbb=acb
table.remove(cba,_cb)cbb=true;break end end
if cbb then aca()
local _cb=
({"none","fire","soul_fire","lava","water"})[dbb.depotType+1]or"unknown"
print("Recipe removed: [".._cb.."] "..dbb.input)else
print("Recipe '"..bbb.."' not found")end end,function(_bb)
local abb={}local bbb=_bb:match("%S+$")or""
for cbb,dbb in ipairs(cba)do if
dbb.input:find(bbb,1,true)==1 then
table.insert(abb,dbb.input:sub(#bbb+1))end end;return abb end)
dab:addCommand("reboot","Exit the program",function(_bb)print("Goodbye!")os.reboot()end)return dab end
if bba~=nil and#bba>0 then local dab=bba[1]local _bb=tonumber(bba[2])
local abb=bba[3]
if dab and _bb and abb then cca(dab,_bb,abb)
aaa.open(dab,_bb,"recipe",abb)
local bbb=aaa.communicationChannels[dab][_bb]["recipe"]
bbb.addMessageHandler("getRecipesRes",function(cbb,dbb,_cb)dba=dbb or{}end)
bbb.addMessageHandler("update",function(cbb,dbb,_cb)
if dbb and type(dbb)=="table"then dca(dbb)end end)
parallel.waitForAll(aaa.listen,function()while next(dba)==nil do
bbb.send("getRecipesReq","depot")sleep(1)end end,function()
local cbb=cda()while true do local dbb,_cb=pcall(function()cbb:run()end)
if not dbb then print(
"Error: "..tostring(_cb))end end end)end end;_ba.reloadAll()
local dda=_ba.getAllPeripheralsNameContains("depot")
local __b=_ba.getAllPeripheralsNameContains("crafting_storage")local a_b=next(__b)local b_b=__b[a_b]local c_b=aba.getLength(dda)
local d_b={recipeOnDepot={},depotOnUse={},lostTrackDepots={},init=function(dab)
for _bb,abb in
ipairs(cba)do dab.recipeOnDepot[abb.id]={recipe=abb,depots={}}end;for _bb,abb in pairs(dda)do
dab.depotOnUse[abb.getId()]={onUse=false,depot=abb,recipe=nil}end end,set=function(dab,_bb,abb)
local bbb=dab.depotOnUse[abb.getId()]bbb.onUse=true;bbb.recipe=_bb;local cbb=dab.recipeOnDepot[_bb.id]
cbb.depots[abb.getId()]=abb;cbb.count=(cbb.count or 0)+1 end,remove=function(dab,_bb)if
_bb==nil then return end
local abb=dab.depotOnUse[_bb.getId()].recipe;dab.depotOnUse[_bb.getId()].onUse=false;dab.depotOnUse[_bb.getId()].recipe=
nil;dab.recipeOnDepot[abb.id].depots[_bb.getId()]=
nil
dab.recipeOnDepot[abb.id].count=math.max(0,(
dab.recipeOnDepot[abb.id].count or 1)-1)end,isUsing=function(dab,_bb)return
dab.depotOnUse[_bb.getId()].onUse end,isCompleted=function(dab,_bb)if
not dab:isUsing(_bb)then return false end
local abb=dab.depotOnUse[_bb.getId()].recipe;local bbb=_bb.getItem(abb.input)if bbb==nil or bbb.count==0 then
return true end end,isLoseTrack=function(dab,_bb)if

not dab:isUsing(_bb)and#_bb.getItems()>0 then return true end;return false end,getOnUseDepotCountForRecipe=function(dab,_bb)return
dab.recipeOnDepot[_bb.id].count or 0 end}d_b:init()
local _ab=function(dab)local _bb=b_b.getItem(dab.input)
if not _bb then return false end;return true end
local aab=function()
while true do local dab={}
for cbb,dbb in ipairs(cba)do
if _ab(dbb)and dbb.trigger then
local _cb=daa.eval(dbb.trigger,function(acb,bcb)
if acb=="item"then return
b_b.getItem(bcb)elseif acb=="fluid"then return b_b.getFluid(bcb)end;return nil end)if _cb then table.insert(dab,dbb)end end end;local _bb=c_b;local abb=#dab
local bbb=math.max(1,math.floor(_bb/math.max(1,abb)))
for cbb,dbb in ipairs(dab)do local _cb=d_b:getOnUseDepotCountForRecipe(dbb)local acb;if
dbb.maxMachine and dbb.maxMachine>0 then
acb=math.min(bbb,dbb.maxMachine)else acb=bbb end
print("recipe "..
(dbb.input or"Unnamed")..
" usedDepotsCount: ".._cb..", maxMachineForRecipe: "..acb)
if _cb>acb then
print("Releasing depots for recipe: ".. (dbb.input or"Unnamed"))local bcb=_cb-acb
for ccb,dcb in
pairs(d_b.recipeOnDepot[dbb.id].depots)do if bcb<=0 then break end;d_b:remove(dcb)bcb=bcb-1 end;_cb=d_b:getOnUseDepotCountForRecipe(dbb)end
if _cb<acb then local bcb=acb-_cb
_aa.info("Need {} depots for recipe {} (max: {})",bcb,dbb.input,acb)
for ccb,dcb in pairs(dda)do if bcb<=0 then break end
if not d_b:isUsing(dcb)then
local _db=b_b.transferItemTo(dcb,dbb.input,64)
_aa.info("Transferred {} items to depot {}",_db,dcb.getId())
if _db<=0 then
if d_b:isLoseTrack(dcb)then
_aa.info("Lost track of depot {}",dcb.getId())table.insert(d_b.lostTrackDepots,dcb)end else d_b:set(dbb,dcb)bcb=bcb-1 end else
_aa.info("Depot {} is already in use for recipe {}",dcb.getId(),dbb.input)end end end;_bb=_bb-acb
print("currentTotalDepots: "..
_bb.." (allocated "..acb.." to "..
(dbb.input or"Unnamed")..")")abb=abb-1
bbb=math.max(1,math.floor(_bb/math.max(1,abb)))end;os.sleep(1)end end
local bab=function()
while true do
for dab,_bb in pairs(d_b.depotOnUse)do local abb=_bb.depot
if d_b:isUsing(abb)then
if
d_b:isCompleted(abb)then local bbb=_bb.recipe;local cbb=abb.getItems(bbb.input)
for dbb,_cb in ipairs(cbb)do
local acb=b_b.transferItemFrom(abb,_cb.name,_cb.count)
if acb==_cb.count then
_aa.debug("Transferred completed recipe "..
bbb.input.." from depot "..abb.getId())else
_aa.error("Failed to transfer completed recipe {} from depot {}",bbb.input,abb.getId())end end;d_b:remove(abb)end end end
for dab,_bb in ipairs(d_b.lostTrackDepots)do
for abb,bbb in ipairs(_bb.getItems())do
local cbb=b_b.transferItemFrom(_bb,bbb.name,bbb.count)
if cbb>0 then
_aa.debug("Transferred lost item {} from depot {}",bbb.name,_bb.getId())else
_aa.error("Failed to transfer lost item {} from depot {}",bbb.name,_bb.getId())end end end;os.sleep(1)end end
local cab=function()local dab=bca()
if
dab and dab.side and dab.channel and dab.secret then
print("Found saved communicator config, attempting to connect...")
aaa.open(dab.side,dab.channel,"recipe",dab.secret)
local _bb=aaa.communicationChannels[dab.side][dab.channel]["recipe"]
_bb.addMessageHandler("getRecipesRes",function(abb,bbb,cbb)dba=bbb or{}end)
_bb.addMessageHandler("update",function(abb,bbb,cbb)
if bbb and type(bbb)=="table"then dca(bbb)end end)aaa.listen()end end;parallel.waitForAll(cab,aab,bab) end
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
return modules["programs.CaDepot"](...)
