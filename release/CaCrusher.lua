local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CaCrusher"] = function(...) local aaa=require("utils.Logger")
local baa=require("programs.common.Communicator")local caa=require("programs.command.CommandLine")
local daa=require("utils.OSUtils")local _ba=require("programs.common.Trigger")
local aba=require("wrapper.PeripheralWrapper")local bba=require("utils.TableUtils")aaa.useDefault()
aaa.currentLevel=aaa.levels.ERROR;local cba={...}local dba={}local _ca={}
local function aca()
local abb=daa.loadTable("cacrusher_recipes")if abb~=nil then dba=abb end end
local function bca()daa.saveTable("cacrusher_recipes",dba)end
local function cca()return daa.loadTable("cacrusher_communicator_config")end;local function dca(abb,bbb,cbb)local dbb={side=abb,channel=bbb,secret=cbb}
daa.saveTable("cacrusher_communicator_config",dbb)end
local function _da(abb)for bbb,cbb in ipairs(dba)do if
cbb.name==abb then return cbb end end;return nil end
local function ada(abb)for bbb,cbb in ipairs(dba)do
if cbb.name==abb then table.remove(dba,bbb)return true end end;return false end
local function bda(abb,bbb,cbb)bbb=bbb or 1;cbb=cbb or 5;if#abb==0 then print("No recipes found.")
return end;local dbb=math.ceil(#abb/cbb)local _cb=
(bbb-1)*cbb+1;local acb=math.min(_cb+cbb-1,#abb)
print(string.format("=== Crusher Recipes (Page %d/%d) ===",bbb,dbb))for i=_cb,acb do local bcb=abb[i]
print(string.format("%d. %s",i,bcb.name or"Unnamed"))end
if dbb>1 then
print(string.format("Showing %d-%d of %d recipes",_cb,acb,
#abb))if bbb<dbb then
print(string.format("Use 'list recipe local %d' for next page",bbb+1))end;if bbb>1 then
print(string.format("Use 'list recipe local %d' for previous page",
bbb-1))end end end;aca()
local function cda()local abb=caa:new("cacrusher> ")
abb:addCommand("list","List recipes",function(bbb)local cbb={}for bcb in
bbb:gmatch("%S+")do table.insert(cbb,bcb)end;if#cbb<3 then
print("Usage: list recipe [remote|local] [page]")return end;local dbb=cbb[2]local _cb=cbb[3]local acb=
tonumber(cbb[4])or 1;if dbb~="recipe"then
print("Usage: list recipe [remote|local] [page]")return end
if _cb=="local"then bda(dba,acb)elseif _cb==
"remote"then
if#_ca==0 then print("No remote recipes available.")return end;bda(_ca,acb)else
print("Usage: list recipe [remote|local] [page]")end end,function(bbb)
local cbb={}
for dbb in bbb:gmatch("%S+")do table.insert(cbb,dbb)end
if#cbb==1 then local dbb=bbb:match("%S+$")or""local _cb={}if
("recipe"):find(dbb,1,true)==1 then
table.insert(_cb,("recipe"):sub(#dbb+1))end;return _cb elseif#cbb==2 then
local dbb=bbb:match("%S+$")or""local _cb={}local acb={"remote","local"}for bcb,ccb in ipairs(acb)do
if
ccb:find(dbb,1,true)==1 then table.insert(_cb,ccb:sub(#dbb+1))end end;return _cb end;return{}end)
abb:addCommand("add","Add recipe(s) from remote",function(bbb)local cbb={}for _cb in bbb:gmatch("%S+")do
table.insert(cbb,_cb)end
if#cbb<2 then
print("Usage: add [recipe_name] or add all")print("Examples:")
print("  add 'Iron Ore Crushing'    - Add specific recipe")
print("  add all                     - Add all remote recipes")
print("Use 'list recipe remote' to see available recipes")return end;local dbb=table.concat(cbb," ",2)
if dbb=="all"then if#_ca==0 then
print("No remote recipes available.")
print("Use 'list recipe remote' to see available remote recipes")return end;local _cb=0
local acb=0
for bcb,ccb in ipairs(_ca)do
if not _da(ccb.name)then
local dcb={id=ccb.id,name=ccb.name,input=ccb.input,output=ccb.output,trigger=ccb.trigger,maxMachine=ccb.maxMachine or-1,inputItemRate=
ccb.inputItemRate or 1,inputFluidRate=ccb.inputFluidRate or 1}table.insert(dba,dcb)_cb=_cb+1 else acb=acb+1 end end;bca()print("Batch add completed:")
print("  Added: ".._cb.." recipes")if acb>0 then
print("  Skipped: "..acb.." recipes (already exist)")end else local _cb=nil;for dcb,_db in ipairs(_ca)do if _db.name==dbb then _cb=_db
break end end;if not _cb then print("Remote recipe '"..dbb..
"' not found")
print("Use 'list recipe remote' to see available remote recipes")return end;if
_da(dbb)then
print("Recipe '"..dbb.."' already exists locally")return end
local acb={id=_cb.id,name=_cb.name,input=_cb.input,output=_cb.output,trigger=_cb.trigger,maxMachine=
_cb.maxMachine or-1,inputItemRate=_cb.inputItemRate or 1,inputFluidRate=_cb.inputFluidRate or 1}table.insert(dba,acb)bca()
print("Recipe added from remote successfully:")print("  Name: "..acb.name)
local bcb=

acb.input and acb.input.items and table.concat(acb.input.items,", ")or"No input"
local ccb=acb.output and acb.output.items and
table.concat(acb.output.items,", ")or"No output"print("  Input: "..bcb)
print("  Output: "..ccb)end end,function(bbb)
local cbb={}
for dbb in bbb:gmatch("%S+")do table.insert(cbb,dbb)end
if#cbb>=1 then local dbb=bbb:match("%S+$")or""local _cb={}if
("all"):find(dbb,1,true)==1 then
table.insert(_cb,("all"):sub(#dbb+1))end;for acb,bcb in ipairs(_ca)do
if bcb.name and
bcb.name:lower():find(dbb:lower(),1,true)==1 then table.insert(_cb,bcb.name:sub(
#dbb+1))end end
return _cb end;return{}end)
abb:addCommand("rm","Remove recipe",function(bbb)local cbb={}
for bcb in bbb:gmatch("%S+")do table.insert(cbb,bcb)end
if#cbb<2 then print("Usage: rm [recipe_name]")return end;local dbb=table.concat(cbb," ",2)local _cb=false;local acb=nil;for bcb,ccb in ipairs(dba)do
if
ccb.name==dbb then acb=ccb;table.remove(dba,bcb)_cb=true;break end end;if _cb and acb then bca()
print(
"Recipe removed: ".. (acb.name or"Unknown"))else
print("Recipe '"..dbb.."' not found")end end,function(bbb)
local cbb={}local dbb=bbb:match("%S+$")or""for _cb,acb in ipairs(dba)do
if acb.name and
acb.name:lower():find(dbb:lower(),1,true)==1 then table.insert(cbb,acb.name:sub(
#dbb+1))end end
return cbb end)
abb:addCommand("reboot","Exit the program",function(bbb)print("Goodbye!")os.reboot()end)return abb end
local dda=function()local abb=cda()while true do
local bbb,cbb=pcall(function()abb:run()end)
if not bbb then print("Error: "..tostring(cbb))end end end
if cba~=nil and#cba>0 then local abb=cba[1]local bbb=tonumber(cba[2])
local cbb=cba[3]
if abb and bbb and cbb then dca(abb,bbb,cbb)
baa.open(abb,bbb,"recipe",cbb)
local dbb=baa.communicationChannels[abb][bbb]["recipe"]
dbb.addMessageHandler("getRecipesRes",function(_cb,acb,bcb)local ccb=acb or{}_ca={}for dcb,_db in ipairs(ccb)do
if _db.name and
_db.name:lower():find("^crush")then table.insert(_ca,_db)end end end)
parallel.waitForAll(baa.listen,function()while next(_ca)==nil do
dbb.send("getRecipesReq","common")sleep(1)end end,dda)end end;aba.reloadAll()
local __b=aba.getAllPeripheralsNameContains("create:crushing_wheel")
local a_b=aba.getAllPeripheralsNameContains("crafting_storage")local b_b=a_b[next(a_b)]
local c_b=aba.getAllPeripheralsNameContains("redrouter")local d_b=c_b[next(c_b)]local _ab=bba.getLength(__b)
local aab={recipeOnCrusher={},crusherOnUse={},lostTrackCrushers={},init=function(abb)
for bbb,cbb in ipairs(dba)do if
abb.recipeOnCrusher[cbb.id]==nil then
abb.recipeOnCrusher[cbb.id]={recipe=cbb,crushers={}}end end;for bbb,cbb in pairs(__b)do
if abb.crusherOnUse[cbb.getId()]==nil then abb.crusherOnUse[cbb.getId()]={onUse=false,crusher=cbb,recipe=
nil}end end end,set=function(abb,bbb,cbb)
local dbb=abb.crusherOnUse[cbb.getId()]dbb.onUse=true;dbb.recipe=bbb;if
abb.recipeOnCrusher[bbb.id]==nil then
abb.recipeOnCrusher[bbb.id]={recipe=bbb,crushers={},count=0}end
local _cb=abb.recipeOnCrusher[bbb.id]_cb.crushers[cbb.getId()]=cbb
_cb.count=(_cb.count or 0)+1 end,remove=function(abb,bbb)
local cbb=abb.crusherOnUse[bbb.getId()].recipe
abb.crusherOnUse[bbb.getId()].onUse=false;abb.crusherOnUse[bbb.getId()].recipe=nil;if
abb.recipeOnCrusher[cbb.id]==nil then
abb.recipeOnCrusher[cbb.id]={recipe=cbb,crushers={},count=0}end;abb.recipeOnCrusher[cbb.id].crushers[bbb.getId()]=
nil
abb.recipeOnCrusher[cbb.id].count=math.max(0,(
abb.recipeOnCrusher[cbb.id].count or 0)-1)end,isUsing=function(abb,bbb)return
abb.crusherOnUse[bbb.getId()].onUse end,getOnUseCrusherCountForRecipe=function(abb,bbb)if not
abb.recipeOnCrusher[bbb.id]then
abb.recipeOnCrusher[bbb.id]={recipe=bbb,crushers={},count=0}end;return
abb.recipeOnCrusher[bbb.id].count or 0 end}
local function bab(abb)local bbb={}
for cbb,dbb in ipairs(dba)do if dbb.id then bbb[dbb.id]=cbb end end;for cbb,dbb in ipairs(abb)do
if dbb.id then local _cb=bbb[dbb.id]if _cb then dba[_cb]=dbb end end end;bca()aab:init()end
local cab=function(abb)local bbb=b_b.getItem(abb.input.items[1])if not bbb then
return false end;return true end;aab:init()
local dab=function()
while true do local abb={}
for dbb,_cb in ipairs(dba)do
if cab(_cb)and _cb.trigger then
local acb=_ba.eval(_cb.trigger,function(bcb,ccb)
if bcb==
"item"then return b_b.getItem(ccb)elseif bcb=="fluid"then return b_b.getFluid(ccb)end;return nil end)
if acb then table.insert(abb,_cb)else
local bcb=aab:getOnUseCrusherCountForRecipe(_cb)
if bcb>0 then for ccb,dcb in
pairs(aab.recipeOnCrusher[_cb.id].crushers)do aab:remove(dcb)end end end end end;local bbb=1;local cbb=#abb
if cbb>0 then bbb=0.2;d_b.setOutputSignals(true)local dbb=_ab
local _cb=math.max(1,math.floor(
dbb/math.max(1,cbb)))
for acb,bcb in ipairs(abb)do local ccb=aab:getOnUseCrusherCountForRecipe(bcb)
local dcb;if bcb.maxMachine and bcb.maxMachine>0 then
dcb=math.min(_cb,bcb.maxMachine)else dcb=_cb end
if ccb>dcb then local _db=ccb-dcb
for adb,bdb in
pairs(aab.recipeOnCrusher[bcb.id].crushers)do if _db<=0 then break end;aab:remove(bdb)_db=_db-1 end;ccb=aab:getOnUseCrusherCountForRecipe(bcb)end
if ccb<dcb then local _db=dcb-ccb
for adb,bdb in pairs(__b)do if _db<=0 then break end;if
not aab:isUsing(bdb)then aab:set(bcb,bdb)_db=_db-1 end end end
if
bcb.input and bcb.input.items and#bcb.input.items>0 then
for _db,adb in pairs(aab.recipeOnCrusher[bcb.id].crushers)do for bdb,cdb in
ipairs(bcb.input.items)do local ddb=math.min(64,bcb.inputItemRate or 64)
b_b.transferItemTo(adb,cdb,ddb)end end end;dbb=dbb-dcb;cbb=cbb-1
_cb=math.max(1,math.floor(dbb/math.max(1,cbb)))end else d_b.setOutputSignals(false)end;sleep(bbb)end end
local _bb=function()local abb=cca()
if
abb and abb.side and abb.channel and abb.secret then
baa.open(abb.side,abb.channel,"recipe",abb.secret)
local bbb=baa.communicationChannels[abb.side][abb.channel]["recipe"]
bbb.addMessageHandler("getRecipesRes",function(cbb,dbb,_cb)local acb=dbb or{}_ca={}for bcb,ccb in ipairs(acb)do
if ccb.name and
ccb.name:lower():find("^crush")then table.insert(_ca,ccb)end end end)
bbb.addMessageHandler("update",function(cbb,dbb,_cb)
if dbb and type(dbb)=="table"then local acb={}for bcb,ccb in ipairs(dbb)do
if ccb.name and
ccb.name:lower():find("^crush")then table.insert(acb,ccb)end end
if#acb>0 then bab(acb)end;bbb.send("getRecipesReq","common")end end)baa.listen()end end;parallel.waitForAll(_bb,dab,dda) end
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
return modules["programs.CaCrusher"](...)
