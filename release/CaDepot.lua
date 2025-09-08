local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CaDepot"] = function(...) local baa=require("utils.Logger")
local caa=require("programs.common.Communicator")local daa=require("programs.command.CommandLine")
local _ba=require("utils.OSUtils")local aba=require("programs.common.Trigger")
local bba=require("wrapper.PeripheralWrapper")local cba=require("utils.TableUtils")baa.useDefault()
baa.currentLevel=baa.levels.ERROR;local dba={...}local _ca={}local aca={}local function bca()
local cbb=_ba.loadTable("cadepot_recipes")if cbb~=nil then _ca=cbb end end;local function cca()
_ba.saveTable("cadepot_recipes",_ca)end;local function dca()
return _ba.loadTable("cadepot_communicator_config")end
local function _da(cbb,dbb,_cb)
local acb={side=cbb,channel=dbb,secret=_cb}_ba.saveTable("cadepot_communicator_config",acb)end
local function ada(cbb)local dbb={}
for _cb,acb in ipairs(_ca)do if acb.id then dbb[acb.id]=_cb end end;for _cb,acb in ipairs(cbb)do
if acb.id then local bcb=dbb[acb.id]if bcb then _ca[bcb]=acb end end end;cca()end;local function bda(cbb)
for dbb,_cb in ipairs(_ca)do if _cb.input==cbb then return _cb end end;return nil end
local function cda(cbb)for dbb,_cb in ipairs(_ca)do
if
_cb.input==cbb then table.remove(_ca,dbb)return true end end;return false end
local function dda(cbb,dbb,_cb)dbb=dbb or 1;_cb=_cb or 5;if#cbb==0 then print("No recipes found.")
return end;local acb=math.ceil(#cbb/_cb)local bcb=
(dbb-1)*_cb+1;local ccb=math.min(bcb+_cb-1,#cbb)
print(string.format("=== Recipes (Page %d/%d) ===",dbb,acb))
for i=bcb,ccb do local dcb=cbb[i]
local _db=({"none","fire","soul_fire","lava","water","press","sand_paper"})[
dcb.depotType+1]or"unknown"local adb=table.concat(dcb.output,", ")
print(string.format("%d. [%s] %s -> %s",i,_db,dcb.input,adb))end
if acb>1 then
print(string.format("Showing %d-%d of %d recipes",bcb,ccb,#cbb))if dbb<acb then
print(string.format("Use 'list recipe local %d' for next page",dbb+1))end;if dbb>1 then
print(string.format("Use 'list recipe local %d' for previous page",
dbb-1))end end end;bca()
local function __b()local cbb=daa:new("cadepot> ")
cbb:addCommand("list","List recipes",function(dbb)local _cb={}for dcb in
dbb:gmatch("%S+")do table.insert(_cb,dcb)end;if#_cb<3 then
print("Usage: list recipe [remote|local] [page]")return end;local acb=_cb[2]local bcb=_cb[3]local ccb=
tonumber(_cb[4])or 1;if acb~="recipe"then
print("Usage: list recipe [remote|local] [page]")return end
if bcb=="local"then dda(_ca,ccb)elseif bcb==
"remote"then
if#aca==0 then print("No remote recipes available.")return end;dda(aca,ccb)else
print("Usage: list recipe [remote|local] [page]")end end,function(dbb)
local _cb={}
for acb in dbb:gmatch("%S+")do table.insert(_cb,acb)end
if#_cb==1 then local acb=dbb:match("%S+$")or""local bcb={}if
("recipe"):find(acb,1,true)==1 then
table.insert(bcb,("recipe"):sub(#acb+1))end;return bcb elseif#_cb==2 then
local acb=dbb:match("%S+$")or""local bcb={}local ccb={"remote","local"}for dcb,_db in ipairs(ccb)do
if
_db:find(acb,1,true)==1 then table.insert(bcb,_db:sub(#acb+1))end end;return bcb end;return{}end)
cbb:addCommand("add","Add recipe(s) from remote by depotType",function(dbb)local _cb={}for dcb in dbb:gmatch("%S+")do
table.insert(_cb,dcb)end
if#_cb<2 then
print("Usage: add [depotType] [input_name]")
print("DepotTypes: none(0), fire(1), soul_fire(2), lava(3), water(4), press(5), sand_paper(6)")print("Examples:")
print("  add fire minecraft:iron_ore    - Add specific recipe")
print("  add fire                       - Add all fire-type recipes")
print("Use 'list recipe remote' to see available recipes")return end;local acb=_cb[2]local bcb=_cb[3]local ccb=nil
if acb=="none"or acb=="0"then ccb=0 elseif
acb=="fire"or acb=="1"then ccb=1 elseif acb=="soul_fire"or acb=="2"then ccb=2 elseif acb=="lava"or acb==
"3"then ccb=3 elseif acb=="water"or acb=="4"then ccb=4 elseif
acb=="press"or acb=="5"then ccb=5 elseif acb=="sand_paper"or acb=="6"then ccb=6 elseif tonumber(acb)and
tonumber(acb)>=0 and tonumber(acb)<=6 then
ccb=tonumber(acb)else print("Invalid depotType: "..acb)
print("Valid depotTypes: none(0), fire(1), soul_fire(2), lava(3), water(4), press(5), sand_paper(6)")return end
if bcb then local dcb=nil
for bdb,cdb in ipairs(aca)do if cdb.input==bcb and cdb.depotType==ccb then
dcb=cdb;break end end
if not dcb then
print("Remote recipe '"..
bcb.."' with depotType "..ccb.." not found")
print("Use 'list recipe remote' to see available remote recipes")return end;if bda(bcb)then
print("Recipe with input '"..bcb.."' already exists locally")return end
local _db={id=dcb.id,input=dcb.input,output=dcb.output,depotType=dcb.depotType,trigger=dcb.trigger,maxMachine=
dcb.maxMachine or-1}table.insert(_ca,_db)cca()
print("Recipe added from remote successfully:")print("  Input: ".._db.input)print("  Output: "..
table.concat(_db.output,", "))
local adb=({"none","fire","soul_fire","lava","water"})[
_db.depotType+1]or"unknown"
print("  DepotType: ".._db.depotType.." ("..adb..")")else local dcb={}for cdb,ddb in ipairs(aca)do
if ddb.depotType==ccb then table.insert(dcb,ddb)end end
if#dcb==0 then
local cdb=({"none","fire","soul_fire","lava","water"})[
ccb+1]or"unknown"
print("No remote recipes found with depotType "..ccb.." ("..cdb..")")
print("Use 'list recipe remote' to see available remote recipes")return end;local _db=0;local adb=0
for cdb,ddb in ipairs(dcb)do
if not bda(ddb.input)then
local __c={id=ddb.id,input=ddb.input,output=ddb.output,depotType=ddb.depotType,trigger=ddb.trigger,maxMachine=
ddb.maxMachine or-1}table.insert(_ca,__c)_db=_db+1 else adb=adb+1 end end;cca()local bdb=
({"none","fire","soul_fire","lava","water"})[ccb+1]or"unknown"
print(
"Batch add completed for depotType "..ccb.." ("..bdb.."):")print("  Added: ".._db.." recipes")if
adb>0 then
print("  Skipped: "..adb.." recipes (already exist)")end end end,function(dbb)
local _cb={}
for acb in dbb:gmatch("%S+")do table.insert(_cb,acb)end
if#_cb==1 and dbb:sub(-1)~=" "then
local acb=dbb:match("%S+$")or""local bcb={}
local ccb={"none","fire","soul_fire","lava","water","0","1","2","3","4"}
for dcb,_db in ipairs(ccb)do if _db:find(acb,1,true)==1 then
table.insert(bcb,_db:sub(#acb+1))end end;return bcb elseif#_cb==2 then local acb=_cb[2]local bcb=nil
if acb=="none"or acb=="0"then bcb=0 elseif
acb=="fire"or acb=="1"then bcb=1 elseif acb=="soul_fire"or acb=="2"then bcb=2 elseif acb=="lava"or acb==
"3"then bcb=3 elseif acb=="water"or acb=="4"then bcb=4 elseif tonumber(acb)and
tonumber(acb)>=0 and tonumber(acb)<=4 then
bcb=tonumber(acb)end
if bcb~=nil then local ccb={}local dcb=dbb:match("%S+$")or""
for _db,adb in ipairs(aca)do if

adb.depotType==bcb and adb.input:find(dcb,1,true)==1 then
table.insert(ccb,adb.input:sub(#dcb+1))end end;return ccb end end;return{}end)
cbb:addCommand("rm","Remove recipe",function(dbb)local _cb={}
for dcb in dbb:gmatch("%S+")do table.insert(_cb,dcb)end;if#_cb<2 then print("Usage: rm [input]")return end
local acb=_cb[2]local bcb=false;local ccb=nil
for dcb,_db in ipairs(_ca)do if _db.input==acb then ccb=_db
table.remove(_ca,dcb)bcb=true;break end end
if bcb then cca()
local dcb=({"none","fire","soul_fire","lava","water","press","sand_paper"})[
ccb.depotType+1]or"unknown"
print("Recipe removed: ["..dcb.."] "..ccb.input)else
print("Recipe '"..acb.."' not found")end end,function(dbb)
local _cb={}local acb=dbb:match("%S+$")or""
for bcb,ccb in ipairs(_ca)do if
ccb.input:find(acb,1,true)==1 then
table.insert(_cb,ccb.input:sub(#acb+1))end end;return _cb end)
cbb:addCommand("reboot","Exit the program",function(dbb)print("Goodbye!")os.reboot()end)return cbb end
local a_b=function(cbb)
cbb.addMessageHandler("getRecipesRes",function(dbb,_cb,acb)aca=_cb or{}end)
cbb.addMessageHandler("update",function(dbb,_cb,acb)if _cb and type(_cb)=="table"then ada(_cb)
cbb.send("getRecipesReq","depot")end end)end
local b_b=function()local cbb=__b()while true do
local dbb,_cb=pcall(function()cbb:run()end)
if not dbb then print("Error: "..tostring(_cb))end end end
if dba~=nil and#dba>0 then local cbb=dba[1]local dbb=tonumber(dba[2])
local _cb=dba[3]
if cbb and dbb and _cb then _da(cbb,dbb,_cb)
caa.open(cbb,dbb,"recipe",_cb)
local acb=caa.communicationChannels[cbb][dbb]["recipe"]a_b(acb)
parallel.waitForAll(caa.listen,function()while next(aca)==nil do
acb.send("getRecipesReq","depot")sleep(1)end end,b_b)end end;bba.reloadAll()
local c_b=bba.getAllPeripheralsNameContains("depot")
local d_b=bba.getAllPeripheralsNameContains("crafting_storage")local _ab=next(d_b)local aab=d_b[_ab]local bab=cba.getLength(c_b)
local cab={recipeOnDepot={},depotOnUse={},init=function(cbb)
for dbb,_cb in
ipairs(_ca)do cbb.recipeOnDepot[_cb.id]={recipe=_cb,depots={}}end;for dbb,_cb in pairs(c_b)do
cbb.depotOnUse[_cb.getId()]={onUse=false,depot=_cb,recipe=nil}end end,set=function(cbb,dbb,_cb)
local acb=cbb.depotOnUse[_cb.getId()]acb.onUse=true;acb.recipe=dbb;if cbb.recipeOnDepot[dbb.id]==nil then
cbb.recipeOnDepot[dbb.id]={recipe=dbb,depots={},count=0}end
local bcb=cbb.recipeOnDepot[dbb.id]bcb.depots[_cb.getId()]=_cb
bcb.count=(bcb.count or 0)+1 end,remove=function(cbb,dbb)if
dbb==nil then return end
local _cb=cbb.depotOnUse[dbb.getId()].recipe;cbb.depotOnUse[dbb.getId()].onUse=false;cbb.depotOnUse[dbb.getId()].recipe=
nil;if cbb.recipeOnDepot[_cb.id]==nil then
cbb.recipeOnDepot[_cb.id]={recipe=_cb,depots={},count=0}end;cbb.recipeOnDepot[_cb.id].depots[dbb.getId()]=
nil
cbb.recipeOnDepot[_cb.id].count=math.max(0,(
cbb.recipeOnDepot[_cb.id].count or 1)-1)end,isUsing=function(cbb,dbb)return
cbb.depotOnUse[dbb.getId()].onUse end,isCompleted=function(cbb,dbb)if
not cbb:isUsing(dbb)then return false end
local _cb=cbb.depotOnUse[dbb.getId()].recipe;local acb=dbb.getItem(_cb.input)if acb==nil or acb.count==0 then
return true end end,isLoseTrack=function(cbb,dbb)if

not cbb:isUsing(dbb)and#dbb.getItems()>0 then return true end;return false end,getOnUseDepotCountForRecipe=function(cbb,dbb)if
cbb.recipeOnDepot[dbb.id]==nil then
cbb.recipeOnDepot[dbb.id]={recipe=dbb,depots={},count=0}end;return
cbb.recipeOnDepot[dbb.id].count or 0 end}cab:init()
local dab=function(cbb)local dbb=aab.getItem(cbb.input)
if not dbb then return false end;return true end
local _bb=function()
while true do local cbb={}
for bcb,ccb in ipairs(_ca)do
if dab(ccb)and ccb.trigger then
local dcb=aba.eval(ccb.trigger,function(_db,adb)
if _db=="item"then return
aab.getItem(adb)elseif _db=="fluid"then return aab.getFluid(adb)end;return nil end)if dcb then table.insert(cbb,ccb)end end end;local dbb=bab;local _cb=#cbb
local acb=math.max(1,math.floor(dbb/math.max(1,_cb)))
for bcb,ccb in ipairs(cbb)do local dcb=cab:getOnUseDepotCountForRecipe(ccb)local _db;if
ccb.maxMachine and ccb.maxMachine>0 then
_db=math.min(acb,ccb.maxMachine)else _db=acb end
baa.debug("recipe "..
(ccb.input or"Unnamed")..
" usedDepotsCount: "..dcb..", maxMachineForRecipe: ".._db)
if dcb>_db then
baa.info("Releasing depots for recipe: ".. (ccb.input or"Unnamed"))local adb=dcb-_db
for bdb,cdb in
pairs(cab.recipeOnDepot[ccb.id].depots)do if adb<=0 then break end;cab:remove(cdb)adb=adb-1 end;dcb=cab:getOnUseDepotCountForRecipe(ccb)end
if dcb<_db then local adb=_db-dcb
baa.info("Need {} depots for recipe {} (max: {})",adb,ccb.input,_db)
for bdb,cdb in pairs(c_b)do if adb<=0 then break end
if not cab:isUsing(cdb)then
local ddb=aab.transferItemTo(cdb,ccb.input,64)
baa.info("Transferred {} items to depot {}",ddb,cdb.getId())
if ddb<=0 then
baa.error("Failed to transfer items to depot {}",cdb.getId())else cab:set(ccb,cdb)adb=adb-1 end else
baa.info("Depot {} is already in use for recipe {}",cdb.getId(),ccb.input)end end end;dbb=dbb-_db;_cb=_cb-1
acb=math.max(1,math.floor(dbb/math.max(1,_cb)))end;os.sleep(1)end end
local abb=function()
while true do
for cbb,dbb in pairs(c_b)do
if cab:isUsing(dbb)then
if cab:isCompleted(dbb)then
local _cb=onUseDepotInfo.recipe;local acb=dbb.getItems(_cb.input)
for bcb,ccb in ipairs(acb)do
local dcb=aab.transferItemFrom(dbb,ccb.name,ccb.count)
if dcb==ccb.count then
baa.debug("Transferred completed recipe "..
_cb.input.." from depot "..dbb.getId())else
baa.error("Failed to transfer completed recipe {} from depot {}",_cb.input,dbb.getId())end end;cab:remove(dbb)end elseif cab:isLoseTrack(dbb)then
baa.info("Lost track of depot {}",dbb.getId())
for _cb,acb in ipairs(dbb.getItems())do
local bcb=aab.transferItemFrom(dbb,acb.name,acb.count)
if bcb>0 then
baa.debug("Transferred lost item {} from depot {}",acb.name,dbb.getId())else
baa.error("Failed to transfer lost item {} from depot {}",acb.name,dbb.getId())end end end end;os.sleep(1)end end
local bbb=function()local cbb=dca()
if
cbb and cbb.side and cbb.channel and cbb.secret then
baa.info("Found saved communicator config, attempting to connect...")
caa.open(cbb.side,cbb.channel,"recipe",cbb.secret)
local dbb=caa.communicationChannels[cbb.side][cbb.channel]["recipe"]a_b(dbb)caa.listen()end end;parallel.waitForAll(bbb,_bb,abb,b_b) end
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
ba.isUnlimitedPeripheralSpecialInventory=true
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
ba.transferItemTo=function(ca,da,_b)
if ca.isUnlimitedPeripheralSpecialInventory then
return ca.transferItemFrom(ba,da,_b)else local ab=0
while ab<_b do local bb=ba.pushItem(ca.getName(),da,_b-ab)if
bb==0 then return ab end;ab=ab+bb end;return ab end end
ba.transferItemFrom=function(ca,da,_b)
if ca.isUnlimitedPeripheralSpecialInventory then return ca.transferItemTo(ba,da,_b)else
local ab=0;while ab<_b do local bb=ba.pullItem(ca.getName(),da,_b-ab)if bb==0 then
return ab end;ab=ab+bb end
return ab end end else
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
ba.transferFluidTo=function(ca,da,_b,ab)if ca.isUnlimitedPeripheralSpecialInventory then
return ca.transferFluidFrom(ba,da,_b)end;if ca.isTank()==false then
error(string.format("Peripheral '%s' is not a tank",ca.getName()))end;local bb=0
while bb<_b do local cb=ab~=nil and ab or
(_b-bb)
local db=ba.pushFluid(ca.getName(),cb,da)if db==0 then return bb end;bb=bb+db end;return bb end
ba.transferFluidFrom=function(ca,da,_b)if ca.isUnlimitedPeripheralSpecialInventory then
return ca.transferFluidTo(ba,da,_b)end;if ca.isTank()==false then
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
