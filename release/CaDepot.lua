local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CaDepot"] = function(...) local __a=require("utils.Logger")
local a_a=require("programs.common.Communicator")local b_a=require("programs.command.CommandLine")
local c_a=require("utils.OSUtils")local d_a=require("programs.recipe.manager.Trigger")
local _aa=require("wrapper.PeripheralWrapper")local aaa=require("utils.TableUtils")__a.useDefault()
__a.currentLevel=__a.levels.ERROR;local baa={...}local caa={}local daa={}local function _ba()
local dda=c_a.loadTable("cadepot_recipes")if dda~=nil then caa=dda end end;local function aba()
c_a.saveTable("cadepot_recipes",caa)end
local function bba(dda)for __b,a_b in ipairs(caa)do
if a_b.input==dda then return a_b end end;return nil end
local function cba(dda)for __b,a_b in ipairs(caa)do
if a_b.input==dda then table.remove(caa,__b)return true end end;return false end
local function dba(dda,__b,a_b)__b=__b or 1;a_b=a_b or 5;if#dda==0 then print("No recipes found.")
return end;local b_b=math.ceil(#dda/a_b)local c_b=
(__b-1)*a_b+1;local d_b=math.min(c_b+a_b-1,#dda)
print(string.format("=== Recipes (Page %d/%d) ===",__b,b_b))
for i=c_b,d_b do local _ab=dda[i]
local aab=
({"none","fire","soul_fire","lava","water"})[_ab.depotType+1]or"unknown"local bab=table.concat(_ab.output,", ")
print(string.format("%d. [%s] %s -> %s",i,aab,_ab.input,bab))end
if b_b>1 then
print(string.format("Showing %d-%d of %d recipes",c_b,d_b,#dda))if __b<b_b then
print(string.format("Use 'list recipe local %d' for next page",__b+1))end;if __b>1 then
print(string.format("Use 'list recipe local %d' for previous page",
__b-1))end end end;_ba()
local function _ca()local dda=b_a:new("cadepot> ")
dda:addCommand("list","List recipes",function(__b)local a_b={}for _ab in
__b:gmatch("%S+")do table.insert(a_b,_ab)end;if#a_b<3 then
print("Usage: list recipe [remote|local] [page]")return end;local b_b=a_b[2]local c_b=a_b[3]local d_b=
tonumber(a_b[4])or 1;if b_b~="recipe"then
print("Usage: list recipe [remote|local] [page]")return end
if c_b=="local"then dba(caa,d_b)elseif c_b==
"remote"then
if#daa==0 then print("No remote recipes available.")return end;dba(daa,d_b)else
print("Usage: list recipe [remote|local] [page]")end end,function(__b)
local a_b={}
for b_b in __b:gmatch("%S+")do table.insert(a_b,b_b)end
if#a_b==1 then local b_b=__b:match("%S+$")or""local c_b={}if
("recipe"):find(b_b,1,true)==1 then
table.insert(c_b,("recipe"):sub(#b_b+1))end;return c_b elseif#a_b==2 then
local b_b=__b:match("%S+$")or""local c_b={}local d_b={"remote","local"}for _ab,aab in ipairs(d_b)do
if
aab:find(b_b,1,true)==1 then table.insert(c_b,aab:sub(#b_b+1))end end;return c_b end;return{}end)
dda:addCommand("add","Add recipe(s) from remote by depotType",function(__b)local a_b={}for _ab in __b:gmatch("%S+")do
table.insert(a_b,_ab)end
if#a_b<2 then
print("Usage: add [depotType] [input_name]")
print("DepotTypes: none(0), fire(1), soul_fire(2), lava(3), water(4)")print("Examples:")
print("  add fire minecraft:iron_ore    - Add specific recipe")
print("  add fire                       - Add all fire-type recipes")
print("Use 'list recipe remote' to see available recipes")return end;local b_b=a_b[2]local c_b=a_b[3]local d_b=nil
if b_b=="none"or b_b=="0"then d_b=0 elseif
b_b=="fire"or b_b=="1"then d_b=1 elseif b_b=="soul_fire"or b_b=="2"then d_b=2 elseif b_b=="lava"or b_b==
"3"then d_b=3 elseif b_b=="water"or b_b=="4"then d_b=4 elseif tonumber(b_b)and
tonumber(b_b)>=0 and tonumber(b_b)<=4 then
d_b=tonumber(b_b)else print("Invalid depotType: "..b_b)
print("Valid depotTypes: none(0), fire(1), soul_fire(2), lava(3), water(4)")return end
if c_b then local _ab=nil
for cab,dab in ipairs(daa)do if dab.input==c_b and dab.depotType==d_b then
_ab=dab;break end end
if not _ab then
print("Remote recipe '"..
c_b.."' with depotType "..d_b.." not found")
print("Use 'list recipe remote' to see available remote recipes")return end;if bba(c_b)then
print("Recipe with input '"..c_b.."' already exists locally")return end
local aab={id=_ab.id,input=_ab.input,output=_ab.output,depotType=_ab.depotType,trigger=_ab.trigger}table.insert(caa,aab)aba()
print("Recipe added from remote successfully:")print("  Input: "..aab.input)print("  Output: "..
table.concat(aab.output,", "))
local bab=({"none","fire","soul_fire","lava","water"})[
aab.depotType+1]or"unknown"
print("  DepotType: "..aab.depotType.." ("..bab..")")else local _ab={}for dab,_bb in ipairs(daa)do
if _bb.depotType==d_b then table.insert(_ab,_bb)end end
if#_ab==0 then
local dab=({"none","fire","soul_fire","lava","water"})[
d_b+1]or"unknown"
print("No remote recipes found with depotType "..d_b.." ("..dab..")")
print("Use 'list recipe remote' to see available remote recipes")return end;local aab=0;local bab=0
for dab,_bb in ipairs(_ab)do
if not bba(_bb.input)then
local abb={id=_bb.id,input=_bb.input,output=_bb.output,depotType=_bb.depotType,trigger=_bb.trigger}table.insert(caa,abb)aab=aab+1 else bab=bab+1 end end;aba()local cab=
({"none","fire","soul_fire","lava","water"})[d_b+1]or"unknown"
print(
"Batch add completed for depotType "..d_b.." ("..cab.."):")print("  Added: "..aab.." recipes")if
bab>0 then
print("  Skipped: "..bab.." recipes (already exist)")end end end,function(__b)
local a_b={}
for b_b in __b:gmatch("%S+")do table.insert(a_b,b_b)end
if#a_b==1 and __b:sub(-1)~=" "then
local b_b=__b:match("%S+$")or""local c_b={}
local d_b={"none","fire","soul_fire","lava","water","0","1","2","3","4"}
for _ab,aab in ipairs(d_b)do if aab:find(b_b,1,true)==1 then
table.insert(c_b,aab:sub(#b_b+1))end end;return c_b elseif#a_b==2 then local b_b=a_b[2]local c_b=nil
if b_b=="none"or b_b=="0"then c_b=0 elseif
b_b=="fire"or b_b=="1"then c_b=1 elseif b_b=="soul_fire"or b_b=="2"then c_b=2 elseif b_b=="lava"or b_b==
"3"then c_b=3 elseif b_b=="water"or b_b=="4"then c_b=4 elseif tonumber(b_b)and
tonumber(b_b)>=0 and tonumber(b_b)<=4 then
c_b=tonumber(b_b)end
if c_b~=nil then local d_b={}local _ab=__b:match("%S+$")or""
for aab,bab in ipairs(daa)do if

bab.depotType==c_b and bab.input:find(_ab,1,true)==1 then
table.insert(d_b,bab.input:sub(#_ab+1))end end;return d_b end end;return{}end)
dda:addCommand("rm","Remove recipe",function(__b)local a_b={}
for _ab in __b:gmatch("%S+")do table.insert(a_b,_ab)end;if#a_b<2 then print("Usage: rm [input]")return end
local b_b=a_b[2]local c_b=false;local d_b=nil
for _ab,aab in ipairs(caa)do if aab.input==b_b then d_b=aab
table.remove(caa,_ab)c_b=true;break end end
if c_b then aba()
local _ab=
({"none","fire","soul_fire","lava","water"})[d_b.depotType+1]or"unknown"
print("Recipe removed: [".._ab.."] "..d_b.input)else
print("Recipe '"..b_b.."' not found")end end,function(__b)
local a_b={}local b_b=__b:match("%S+$")or""
for c_b,d_b in ipairs(caa)do if
d_b.input:find(b_b,1,true)==1 then
table.insert(a_b,d_b.input:sub(#b_b+1))end end;return a_b end)
dda:addCommand("reboot","Exit the program",function(__b)print("Goodbye!")os.reboot()end)return dda end
if baa~=nil and#baa>0 then local dda=baa[1]local __b=tonumber(baa[2])
local a_b=baa[3]
if dda and __b and a_b then a_a.open(dda,__b,"recipe",a_b)
local b_b=a_a.communicationChannels[dda][__b]["recipe"]
b_b.addMessageHandler("getRecipesRes",function(c_b,d_b,_ab)daa=d_b or{}end)
parallel.waitForAll(a_a.listen,function()while next(daa)==nil do
b_b.send("getRecipesReq","depot")sleep(1)end end,function()
local c_b=_ca()while true do local d_b,_ab=pcall(function()c_b:run()end)
if not d_b then print(
"Error: "..tostring(_ab))end end end)end end;_aa.reloadAll()
local aca=_aa.getAllPeripheralsNameContains("depot")
local bca=_aa.getAllPeripheralsNameContains("crafting_storage")local cca=next(bca)local dca=bca[cca]local _da=aaa.getLength(aca)
local ada={recipeOnDepot={},depotOnUse={},lostTrackDepots={},init=function(dda)
for __b,a_b in
ipairs(caa)do dda.recipeOnDepot[a_b.id]={recipe=a_b,depots={}}end;for __b,a_b in pairs(aca)do
dda.depotOnUse[a_b.getId()]={onUse=false,depot=a_b,recipe=nil}end end,set=function(dda,__b,a_b)
local b_b=dda.depotOnUse[a_b.getId()]b_b.onUse=true;b_b.recipe=__b;local c_b=dda.recipeOnDepot[__b.id]
c_b.depots[a_b.getId()]=a_b;c_b.count=(c_b.count or 0)+1 end,remove=function(dda,__b)
local a_b=dda.depotOnUse[__b.getId()].recipe;dda.depotOnUse[__b.getId()].onUse=false;dda.depotOnUse[__b.getId()].recipe=
nil;dda.recipeOnDepot[a_b.id].depots[__b.getId()]=
nil
dda.recipeOnDepot[a_b.id].count=math.max(0,(
dda.recipeOnDepot[a_b.id].count or 1)-1)end,isUsing=function(dda,__b)return
dda.depotOnUse[__b.getId()].onUse end,isCompleted=function(dda,__b)if
not dda:isUsing(__b)then return false end
local a_b=dda.depotOnUse[__b.getId()].recipe;local b_b=__b.getItem(a_b.input)if b_b==nil or b_b.count==0 then
return true end end,isLoseTrack=function(dda,__b)if

not dda:isUsing(__b)and#__b.getItems()>0 then return true end;return false end,getOnUseDepotCountForRecipe=function(dda,__b)return
dda.recipeOnDepot[__b.id].count or 0 end}ada:init()
local bda=function()
while true do local dda={}
for a_b,b_b in ipairs(caa)do
if b_b.trigger then
local c_b=d_a.eval(b_b.trigger,function(d_b,_ab)
if d_b=="item"then return
dca.getItem(_ab)elseif d_b=="fluid"then return dca.getFluid(_ab)end;return nil end)if c_b then table.insert(dda,b_b)end end end;local __b=_da/math.max(1,#dda)
for a_b,b_b in ipairs(dda)do
local c_b=ada:getOnUseDepotCountForRecipe(b_b)
if c_b<__b then local d_b=__b-c_b
__a.info("Need {} depots for recipe {}",d_b,b_b.input)
for _ab,aab in pairs(aca)do if d_b<=0 then break end
if not ada:isUsing(aab)then
local bab=dca.transferItemTo(aab,b_b.input,64)
__a.info("Transferred {} items to depot {}",bab,aab.getId())
if bab<=0 then
if ada:isLoseTrack(aab)then
__a.info("Lost track of depot {}",aab.getId())table.insert(ada.lostTrackDepots,aab)end else ada:set(b_b,aab)d_b=d_b-1 end else
__a.info("Depot {} is already in use for recipe {}",aab.getId(),b_b.input)end end end end;os.sleep(1)end end
local cda=function()
while true do
for dda,__b in pairs(ada.depotOnUse)do local a_b=__b.depot
if ada:isUsing(a_b)then
if
ada:isCompleted(a_b)then local b_b=__b.recipe;local c_b=a_b.getItems(b_b.input)local d_b=0
for _ab,aab in ipairs(c_b)do
local bab=dca.transferItemFrom(a_b,aab.name,aab.count)
if bab==aab.count then
__a.error("Transferred completed recipe "..
b_b.input.." from depot "..a_b.getId())ada:remove(a_b)else
__a.error("Failed to transfer completed recipe {} from depot {}",b_b.input,a_b.getId())end end end end end
for dda,__b in ipairs(ada.lostTrackDepots)do
for a_b,b_b in ipairs(__b.getItems())do
local c_b=dca.transferItemFrom(__b,b_b.name,b_b.count)
if c_b>0 then
__a.debug("Transferred lost item {} from depot {}",b_b.name,__b.getId())else
__a.error("Failed to transfer lost item {} from depot {}",b_b.name,__b.getId())end end end;os.sleep(1)end end;parallel.waitForAll(bda,cda) end
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
return modules["programs.CaDepot"](...)
