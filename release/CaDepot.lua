local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CaDepot"] = function(...) local caa=require("utils.Logger")
local daa=require("programs.common.Communicator")local _ba=require("programs.command.CommandLine")
local aba=require("utils.OSUtils")local bba=require("programs.common.Trigger")
local cba=require("wrapper.PeripheralWrapper")local dba=require("utils.TableUtils")caa.useDefault()
caa.currentLevel=caa.levels.ERROR;local _ca={...}local aca={}local bca={}local function cca()
local _cb=aba.loadTable("cadepot_recipes")if _cb~=nil then aca=_cb end end;local function dca()
aba.saveTable("cadepot_recipes",aca)end;local function _da()
return aba.loadTable("cadepot_communicator_config")end
local function ada(_cb,acb,bcb)
local ccb={side=_cb,channel=acb,secret=bcb}aba.saveTable("cadepot_communicator_config",ccb)end
local function bda(_cb)local acb={}
for bcb,ccb in ipairs(aca)do if ccb.id then acb[ccb.id]=bcb end end;for bcb,ccb in ipairs(_cb)do
if ccb.id then local dcb=acb[ccb.id]if dcb then aca[dcb]=ccb end end end;dca()end;local function cda(_cb)
for acb,bcb in ipairs(aca)do if bcb.input==_cb then return bcb end end;return nil end
local function dda(_cb)for acb,bcb in ipairs(aca)do
if
bcb.input==_cb then table.remove(aca,acb)return true end end;return false end
local function __b(_cb,acb,bcb)acb=acb or 1;bcb=bcb or 5;if#_cb==0 then print("No recipes found.")
return end;local ccb=math.ceil(#_cb/bcb)local dcb=
(acb-1)*bcb+1;local _db=math.min(dcb+bcb-1,#_cb)
print(string.format("=== Recipes (Page %d/%d) ===",acb,ccb))
for i=dcb,_db do local adb=_cb[i]
local bdb=
({"none","fire","soul_fire","lava","water"})[adb.depotType+1]or"unknown"local cdb=table.concat(adb.output,", ")
print(string.format("%d. [%s] %s -> %s",i,bdb,adb.input,cdb))end
if ccb>1 then
print(string.format("Showing %d-%d of %d recipes",dcb,_db,#_cb))if acb<ccb then
print(string.format("Use 'list recipe local %d' for next page",acb+1))end;if acb>1 then
print(string.format("Use 'list recipe local %d' for previous page",
acb-1))end end end;cca()
local a_b=function()local _cb=_da()
if
_cb and _cb.side and _cb.channel and _cb.secret then
caa.info("Found saved communicator config, attempting to connect...")
daa.open(_cb.side,_cb.channel,"recipe",_cb.secret)
local acb=daa.communicationChannels[_cb.side][_cb.channel]["recipe"]
acb.addMessageHandler("getRecipesRes",function(bcb,ccb,dcb)bca=ccb or{}end)
acb.addMessageHandler("update",function(bcb,ccb,dcb)
if ccb and type(ccb)=="table"then bda(ccb)end end)daa.listen()end end
local function b_b()local _cb=_ba:new("cadepot> ")
_cb:addCommand("list","List recipes",function(acb)local bcb={}for adb in
acb:gmatch("%S+")do table.insert(bcb,adb)end;if#bcb<3 then
print("Usage: list recipe [remote|local] [page]")return end;local ccb=bcb[2]local dcb=bcb[3]local _db=
tonumber(bcb[4])or 1;if ccb~="recipe"then
print("Usage: list recipe [remote|local] [page]")return end
if dcb=="local"then __b(aca,_db)elseif dcb==
"remote"then
if#bca==0 then print("No remote recipes available.")return end;__b(bca,_db)else
print("Usage: list recipe [remote|local] [page]")end end,function(acb)
local bcb={}
for ccb in acb:gmatch("%S+")do table.insert(bcb,ccb)end
if#bcb==1 then local ccb=acb:match("%S+$")or""local dcb={}if
("recipe"):find(ccb,1,true)==1 then
table.insert(dcb,("recipe"):sub(#ccb+1))end;return dcb elseif#bcb==2 then
local ccb=acb:match("%S+$")or""local dcb={}local _db={"remote","local"}for adb,bdb in ipairs(_db)do
if
bdb:find(ccb,1,true)==1 then table.insert(dcb,bdb:sub(#ccb+1))end end;return dcb end;return{}end)
_cb:addCommand("add","Add recipe(s) from remote by depotType",function(acb)local bcb={}for adb in acb:gmatch("%S+")do
table.insert(bcb,adb)end
if#bcb<2 then
print("Usage: add [depotType] [input_name]")
print("DepotTypes: none(0), fire(1), soul_fire(2), lava(3), water(4)")print("Examples:")
print("  add fire minecraft:iron_ore    - Add specific recipe")
print("  add fire                       - Add all fire-type recipes")
print("Use 'list recipe remote' to see available recipes")return end;local ccb=bcb[2]local dcb=bcb[3]local _db=nil
if ccb=="none"or ccb=="0"then _db=0 elseif
ccb=="fire"or ccb=="1"then _db=1 elseif ccb=="soul_fire"or ccb=="2"then _db=2 elseif ccb=="lava"or ccb==
"3"then _db=3 elseif ccb=="water"or ccb=="4"then _db=4 elseif tonumber(ccb)and
tonumber(ccb)>=0 and tonumber(ccb)<=4 then
_db=tonumber(ccb)else print("Invalid depotType: "..ccb)
print("Valid depotTypes: none(0), fire(1), soul_fire(2), lava(3), water(4)")return end
if dcb then local adb=nil
for ddb,__c in ipairs(bca)do if __c.input==dcb and __c.depotType==_db then
adb=__c;break end end
if not adb then
print("Remote recipe '"..
dcb.."' with depotType ".._db.." not found")
print("Use 'list recipe remote' to see available remote recipes")return end;if cda(dcb)then
print("Recipe with input '"..dcb.."' already exists locally")return end
local bdb={id=adb.id,input=adb.input,output=adb.output,depotType=adb.depotType,trigger=adb.trigger,maxMachine=
adb.maxMachine or-1}table.insert(aca,bdb)dca()
print("Recipe added from remote successfully:")print("  Input: "..bdb.input)print("  Output: "..
table.concat(bdb.output,", "))
local cdb=({"none","fire","soul_fire","lava","water"})[
bdb.depotType+1]or"unknown"
print("  DepotType: "..bdb.depotType.." ("..cdb..")")else local adb={}for __c,a_c in ipairs(bca)do
if a_c.depotType==_db then table.insert(adb,a_c)end end
if#adb==0 then
local __c=({"none","fire","soul_fire","lava","water"})[
_db+1]or"unknown"
print("No remote recipes found with depotType ".._db.." ("..__c..")")
print("Use 'list recipe remote' to see available remote recipes")return end;local bdb=0;local cdb=0
for __c,a_c in ipairs(adb)do
if not cda(a_c.input)then
local b_c={id=a_c.id,input=a_c.input,output=a_c.output,depotType=a_c.depotType,trigger=a_c.trigger,maxMachine=
a_c.maxMachine or-1}table.insert(aca,b_c)bdb=bdb+1 else cdb=cdb+1 end end;dca()local ddb=
({"none","fire","soul_fire","lava","water"})[_db+1]or"unknown"
print(
"Batch add completed for depotType ".._db.." ("..ddb.."):")print("  Added: "..bdb.." recipes")if
cdb>0 then
print("  Skipped: "..cdb.." recipes (already exist)")end end end,function(acb)
local bcb={}
for ccb in acb:gmatch("%S+")do table.insert(bcb,ccb)end
if#bcb==1 and acb:sub(-1)~=" "then
local ccb=acb:match("%S+$")or""local dcb={}
local _db={"none","fire","soul_fire","lava","water","0","1","2","3","4"}
for adb,bdb in ipairs(_db)do if bdb:find(ccb,1,true)==1 then
table.insert(dcb,bdb:sub(#ccb+1))end end;return dcb elseif#bcb==2 then local ccb=bcb[2]local dcb=nil
if ccb=="none"or ccb=="0"then dcb=0 elseif
ccb=="fire"or ccb=="1"then dcb=1 elseif ccb=="soul_fire"or ccb=="2"then dcb=2 elseif ccb=="lava"or ccb==
"3"then dcb=3 elseif ccb=="water"or ccb=="4"then dcb=4 elseif tonumber(ccb)and
tonumber(ccb)>=0 and tonumber(ccb)<=4 then
dcb=tonumber(ccb)end
if dcb~=nil then local _db={}local adb=acb:match("%S+$")or""
for bdb,cdb in ipairs(bca)do if

cdb.depotType==dcb and cdb.input:find(adb,1,true)==1 then
table.insert(_db,cdb.input:sub(#adb+1))end end;return _db end end;return{}end)
_cb:addCommand("rm","Remove recipe",function(acb)local bcb={}
for adb in acb:gmatch("%S+")do table.insert(bcb,adb)end;if#bcb<2 then print("Usage: rm [input]")return end
local ccb=bcb[2]local dcb=false;local _db=nil
for adb,bdb in ipairs(aca)do if bdb.input==ccb then _db=bdb
table.remove(aca,adb)dcb=true;break end end
if dcb then dca()
local adb=
({"none","fire","soul_fire","lava","water"})[_db.depotType+1]or"unknown"
print("Recipe removed: ["..adb.."] ".._db.input)else
print("Recipe '"..ccb.."' not found")end end,function(acb)
local bcb={}local ccb=acb:match("%S+$")or""
for dcb,_db in ipairs(aca)do if
_db.input:find(ccb,1,true)==1 then
table.insert(bcb,_db.input:sub(#ccb+1))end end;return bcb end)
_cb:addCommand("reboot","Exit the program",function(acb)print("Goodbye!")os.reboot()end)return _cb end
local c_b=function(_cb)
_cb.addMessageHandler("getRecipesRes",function(acb,bcb,ccb)bca=bcb or{}end)
_cb.addMessageHandler("update",function(acb,bcb,ccb)if bcb and type(bcb)=="table"then bda(bcb)
_cb.send("getRecipesReq","depot")end end)end
local d_b=function()local _cb=b_b()while true do
local acb,bcb=pcall(function()_cb:run()end)
if not acb then print("Error: "..tostring(bcb))end end end
if _ca~=nil and#_ca>0 then local _cb=_ca[1]local acb=tonumber(_ca[2])
local bcb=_ca[3]
if _cb and acb and bcb then ada(_cb,acb,bcb)
daa.open(_cb,acb,"recipe",bcb)
local ccb=daa.communicationChannels[_cb][acb]["recipe"]c_b(ccb)
parallel.waitForAll(daa.listen,function()while next(bca)==nil do
ccb.send("getRecipesReq","depot")sleep(1)end end,d_b)end end;cba.reloadAll()
local _ab=cba.getAllPeripheralsNameContains("depot")
local aab=cba.getAllPeripheralsNameContains("crafting_storage")local bab=next(aab)local cab=aab[bab]local dab=dba.getLength(_ab)
local _bb={recipeOnDepot={},depotOnUse={},lostTrackDepots={},init=function(_cb)
for acb,bcb in
ipairs(aca)do _cb.recipeOnDepot[bcb.id]={recipe=bcb,depots={}}end;for acb,bcb in pairs(_ab)do
_cb.depotOnUse[bcb.getId()]={onUse=false,depot=bcb,recipe=nil}end end,set=function(_cb,acb,bcb)
local ccb=_cb.depotOnUse[bcb.getId()]ccb.onUse=true;ccb.recipe=acb;local dcb=_cb.recipeOnDepot[acb.id]
dcb.depots[bcb.getId()]=bcb;dcb.count=(dcb.count or 0)+1 end,remove=function(_cb,acb)if
acb==nil then return end
local bcb=_cb.depotOnUse[acb.getId()].recipe;_cb.depotOnUse[acb.getId()].onUse=false;_cb.depotOnUse[acb.getId()].recipe=
nil;_cb.recipeOnDepot[bcb.id].depots[acb.getId()]=
nil
_cb.recipeOnDepot[bcb.id].count=math.max(0,(
_cb.recipeOnDepot[bcb.id].count or 1)-1)end,isUsing=function(_cb,acb)return
_cb.depotOnUse[acb.getId()].onUse end,isCompleted=function(_cb,acb)if
not _cb:isUsing(acb)then return false end
local bcb=_cb.depotOnUse[acb.getId()].recipe;local ccb=acb.getItem(bcb.input)if ccb==nil or ccb.count==0 then
return true end end,isLoseTrack=function(_cb,acb)if

not _cb:isUsing(acb)and#acb.getItems()>0 then return true end;return false end,getOnUseDepotCountForRecipe=function(_cb,acb)return
_cb.recipeOnDepot[acb.id].count or 0 end}_bb:init()
local abb=function(_cb)local acb=cab.getItem(_cb.input)
if not acb then return false end;return true end
local bbb=function()
while true do local _cb={}
for dcb,_db in ipairs(aca)do
if abb(_db)and _db.trigger then
local adb=bba.eval(_db.trigger,function(bdb,cdb)
if bdb=="item"then return
cab.getItem(cdb)elseif bdb=="fluid"then return cab.getFluid(cdb)end;return nil end)if adb then table.insert(_cb,_db)end end end;local acb=dab;local bcb=#_cb
local ccb=math.max(1,math.floor(acb/math.max(1,bcb)))
for dcb,_db in ipairs(_cb)do local adb=_bb:getOnUseDepotCountForRecipe(_db)local bdb;if
_db.maxMachine and _db.maxMachine>0 then
bdb=math.min(ccb,_db.maxMachine)else bdb=ccb end
caa.debug("recipe "..
(_db.input or"Unnamed")..
" usedDepotsCount: "..adb..", maxMachineForRecipe: "..bdb)
if adb>bdb then
caa.info("Releasing depots for recipe: ".. (_db.input or"Unnamed"))local cdb=adb-bdb
for ddb,__c in
pairs(_bb.recipeOnDepot[_db.id].depots)do if cdb<=0 then break end;_bb:remove(__c)cdb=cdb-1 end;adb=_bb:getOnUseDepotCountForRecipe(_db)end
if adb<bdb then local cdb=bdb-adb
caa.info("Need {} depots for recipe {} (max: {})",cdb,_db.input,bdb)
for ddb,__c in pairs(_ab)do if cdb<=0 then break end
if not _bb:isUsing(__c)then
local a_c=cab.transferItemTo(__c,_db.input,64)
caa.info("Transferred {} items to depot {}",a_c,__c.getId())
if a_c<=0 then
if _bb:isLoseTrack(__c)then
caa.info("Lost track of depot {}",__c.getId())table.insert(_bb.lostTrackDepots,__c)end else _bb:set(_db,__c)cdb=cdb-1 end else
caa.info("Depot {} is already in use for recipe {}",__c.getId(),_db.input)end end end;acb=acb-bdb;bcb=bcb-1
ccb=math.max(1,math.floor(acb/math.max(1,bcb)))end;os.sleep(1)end end
local cbb=function()
while true do
for _cb,acb in pairs(_bb.depotOnUse)do local bcb=acb.depot
if _bb:isUsing(bcb)then
if
_bb:isCompleted(bcb)then local ccb=acb.recipe;local dcb=bcb.getItems(ccb.input)
for _db,adb in ipairs(dcb)do
local bdb=cab.transferItemFrom(bcb,adb.name,adb.count)
if bdb==adb.count then
caa.debug("Transferred completed recipe "..
ccb.input.." from depot "..bcb.getId())else
caa.error("Failed to transfer completed recipe {} from depot {}",ccb.input,bcb.getId())end end;_bb:remove(bcb)end end end
for _cb,acb in ipairs(_bb.lostTrackDepots)do
for bcb,ccb in ipairs(acb.getItems())do
local dcb=cab.transferItemFrom(acb,ccb.name,ccb.count)
if dcb>0 then
caa.debug("Transferred lost item {} from depot {}",ccb.name,acb.getId())else
caa.error("Failed to transfer lost item {} from depot {}",ccb.name,acb.getId())end end end;os.sleep(1)end end
local dbb=function()local _cb=_da()
if
_cb and _cb.side and _cb.channel and _cb.secret then
caa.info("Found saved communicator config, attempting to connect...")
daa.open(_cb.side,_cb.channel,"recipe",_cb.secret)
local acb=daa.communicationChannels[_cb.side][_cb.channel]["recipe"]c_b(acb)daa.listen()end end;parallel.waitForAll(dbb,bbb,cbb,d_b) end
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
