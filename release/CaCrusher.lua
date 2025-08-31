local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CaCrusher"] = function(...) local c_a=require("utils.Logger")
local d_a=require("programs.common.Communicator")local _aa=require("programs.command.CommandLine")
local aaa=require("utils.OSUtils")local baa=require("programs.common.Trigger")
local caa=require("wrapper.PeripheralWrapper")local daa=require("utils.TableUtils")c_a.useDefault()
c_a.currentLevel=c_a.levels.ERROR;local _ba={...}local aba={}local bba={}
local function cba()
local _ab=aaa.loadTable("cacrusher_recipes")if _ab~=nil then aba=_ab end end
local function dba()aaa.saveTable("cacrusher_recipes",aba)end
local function _ca()return aaa.loadTable("cacrusher_communicator_config")end;local function aca(_ab,aab,bab)local cab={side=_ab,channel=aab,secret=bab}
aaa.saveTable("cacrusher_communicator_config",cab)end
local function bca(_ab)for aab,bab in ipairs(aba)do if
bab.name==_ab then return bab end end;return nil end
local function cca(_ab)for aab,bab in ipairs(aba)do
if bab.name==_ab then table.remove(aba,aab)return true end end;return false end
local function dca(_ab,aab,bab)aab=aab or 1;bab=bab or 5;if#_ab==0 then print("No recipes found.")
return end;local cab=math.ceil(#_ab/bab)local dab=
(aab-1)*bab+1;local _bb=math.min(dab+bab-1,#_ab)
print(string.format("=== Crusher Recipes (Page %d/%d) ===",aab,cab))for i=dab,_bb do local abb=_ab[i]
print(string.format("%d. %s",i,abb.name or"Unnamed"))end
if cab>1 then
print(string.format("Showing %d-%d of %d recipes",dab,_bb,
#_ab))if aab<cab then
print(string.format("Use 'list recipe local %d' for next page",aab+1))end;if aab>1 then
print(string.format("Use 'list recipe local %d' for previous page",
aab-1))end end end;cba()
local function _da()local _ab=_aa:new("cacrusher> ")
_ab:addCommand("list","List recipes",function(aab)local bab={}for abb in
aab:gmatch("%S+")do table.insert(bab,abb)end;if#bab<3 then
print("Usage: list recipe [remote|local] [page]")return end;local cab=bab[2]local dab=bab[3]local _bb=
tonumber(bab[4])or 1;if cab~="recipe"then
print("Usage: list recipe [remote|local] [page]")return end
if dab=="local"then dca(aba,_bb)elseif dab==
"remote"then
if#bba==0 then print("No remote recipes available.")return end;dca(bba,_bb)else
print("Usage: list recipe [remote|local] [page]")end end,function(aab)
local bab={}
for cab in aab:gmatch("%S+")do table.insert(bab,cab)end
if#bab==1 then local cab=aab:match("%S+$")or""local dab={}if
("recipe"):find(cab,1,true)==1 then
table.insert(dab,("recipe"):sub(#cab+1))end;return dab elseif#bab==2 then
local cab=aab:match("%S+$")or""local dab={}local _bb={"remote","local"}for abb,bbb in ipairs(_bb)do
if
bbb:find(cab,1,true)==1 then table.insert(dab,bbb:sub(#cab+1))end end;return dab end;return{}end)
_ab:addCommand("add","Add recipe(s) from remote",function(aab)local bab={}for dab in aab:gmatch("%S+")do
table.insert(bab,dab)end
if#bab<2 then
print("Usage: add [recipe_name] or add all")print("Examples:")
print("  add 'Iron Ore Crushing'    - Add specific recipe")
print("  add all                     - Add all remote recipes")
print("Use 'list recipe remote' to see available recipes")return end;local cab=table.concat(bab," ",2)
if cab=="all"then if#bba==0 then
print("No remote recipes available.")
print("Use 'list recipe remote' to see available remote recipes")return end;local dab=0
local _bb=0
for abb,bbb in ipairs(bba)do
if not bca(bbb.name)then
local cbb={id=bbb.id,name=bbb.name,input=bbb.input,output=bbb.output,trigger=bbb.trigger,maxMachine=bbb.maxMachine or-1,inputItemRate=
bbb.inputItemRate or 1,inputFluidRate=bbb.inputFluidRate or 1}table.insert(aba,cbb)dab=dab+1 else _bb=_bb+1 end end;dba()print("Batch add completed:")
print("  Added: "..dab.." recipes")if _bb>0 then
print("  Skipped: ".._bb.." recipes (already exist)")end else local dab=nil;for cbb,dbb in ipairs(bba)do if dbb.name==cab then dab=dbb
break end end;if not dab then print("Remote recipe '"..cab..
"' not found")
print("Use 'list recipe remote' to see available remote recipes")return end;if
bca(cab)then
print("Recipe '"..cab.."' already exists locally")return end
local _bb={id=dab.id,name=dab.name,input=dab.input,output=dab.output,trigger=dab.trigger,maxMachine=
dab.maxMachine or-1,inputItemRate=dab.inputItemRate or 1,inputFluidRate=dab.inputFluidRate or 1}table.insert(aba,_bb)dba()
print("Recipe added from remote successfully:")print("  Name: ".._bb.name)
local abb=

_bb.input and _bb.input.items and table.concat(_bb.input.items,", ")or"No input"
local bbb=_bb.output and _bb.output.items and
table.concat(_bb.output.items,", ")or"No output"print("  Input: "..abb)
print("  Output: "..bbb)end end,function(aab)
local bab={}
for cab in aab:gmatch("%S+")do table.insert(bab,cab)end
if#bab>=1 then local cab=aab:match("%S+$")or""local dab={}if
("all"):find(cab,1,true)==1 then
table.insert(dab,("all"):sub(#cab+1))end;for _bb,abb in ipairs(bba)do
if abb.name and
abb.name:lower():find(cab:lower(),1,true)==1 then table.insert(dab,abb.name:sub(
#cab+1))end end
return dab end;return{}end)
_ab:addCommand("rm","Remove recipe",function(aab)local bab={}
for abb in aab:gmatch("%S+")do table.insert(bab,abb)end
if#bab<2 then print("Usage: rm [recipe_name]")return end;local cab=table.concat(bab," ",2)local dab=false;local _bb=nil;for abb,bbb in ipairs(aba)do
if
bbb.name==cab then _bb=bbb;table.remove(aba,abb)dab=true;break end end;if dab and _bb then dba()
print(
"Recipe removed: ".. (_bb.name or"Unknown"))else
print("Recipe '"..cab.."' not found")end end,function(aab)
local bab={}local cab=aab:match("%S+$")or""for dab,_bb in ipairs(aba)do
if _bb.name and
_bb.name:lower():find(cab:lower(),1,true)==1 then table.insert(bab,_bb.name:sub(
#cab+1))end end
return bab end)
_ab:addCommand("reboot","Exit the program",function(aab)print("Goodbye!")os.reboot()end)return _ab end
if _ba~=nil and#_ba>0 then local _ab=_ba[1]local aab=tonumber(_ba[2])
local bab=_ba[3]
if _ab and aab and bab then aca(_ab,aab,bab)
d_a.open(_ab,aab,"recipe",bab)
local cab=d_a.communicationChannels[_ab][aab]["recipe"]
cab.addMessageHandler("getRecipesRes",function(dab,_bb,abb)local bbb=_bb or{}bba={}for cbb,dbb in ipairs(bbb)do
if dbb.name and
dbb.name:lower():find("^crush")then table.insert(bba,dbb)end end end)
parallel.waitForAll(d_a.listen,function()while next(bba)==nil do
cab.send("getRecipesReq","common")sleep(1)end end,function()
local dab=_da()while true do local _bb,abb=pcall(function()dab:run()end)
if not _bb then print(
"Error: "..tostring(abb))end end end)end end;caa.reloadAll()
local ada=caa.getAllPeripheralsNameContains("create:crushing_wheel")
local bda=caa.getAllPeripheralsNameContains("crafting_storage")local cda=next(bda)local dda=bda[cda]local __b=daa.getLength(ada)
local a_b={recipeOnCrusher={},crusherOnUse={},lostTrackCrushers={},init=function(_ab)
for aab,bab in
ipairs(aba)do if _ab.recipeOnCrusher[bab.id]==nil then
_ab.recipeOnCrusher[bab.id]={recipe=bab,crushers={}}end end;for aab,bab in pairs(ada)do
if _ab.crusherOnUse[bab.getId()]==nil then _ab.crusherOnUse[bab.getId()]={onUse=false,crusher=bab,recipe=
nil}end end end,set=function(_ab,aab,bab)
local cab=_ab.crusherOnUse[bab.getId()]cab.onUse=true;cab.recipe=aab
local dab=_ab.recipeOnCrusher[aab.id]dab.crushers[bab.getId()]=bab
dab.count=(dab.count or 0)+1 end,remove=function(_ab,aab)
local bab=_ab.crusherOnUse[aab.getId()].recipe
_ab.crusherOnUse[aab.getId()].onUse=false;_ab.crusherOnUse[aab.getId()].recipe=nil;_ab.recipeOnCrusher[bab.id].crushers[aab.getId()]=
nil
_ab.recipeOnCrusher[bab.id].count=math.max(0,(
_ab.recipeOnCrusher[bab.id].count or 0)-1)end,isUsing=function(_ab,aab)return
_ab.crusherOnUse[aab.getId()].onUse end,getOnUseCrusherCountForRecipe=function(_ab,aab)return
_ab.recipeOnCrusher[aab.id].count or 0 end}
local function b_b(_ab)local aab={}
for bab,cab in ipairs(aba)do if cab.id then aab[cab.id]=bab end end;for bab,cab in ipairs(_ab)do
if cab.id then local dab=aab[cab.id]if dab then aba[dab]=cab end end end;dba()a_b:init()end;a_b:init()
local c_b=function()
while true do local _ab={}
for dab,_bb in ipairs(aba)do
if _bb.trigger then
local abb=baa.eval(_bb.trigger,function(bbb,cbb)
if bbb=="item"then return
dda.getItem(cbb)elseif bbb=="fluid"then return dda.getFluid(cbb)end;return nil end)
if abb then table.insert(_ab,_bb)else
local bbb=a_b:getOnUseCrusherCountForRecipe(_bb)
if bbb>0 then for cbb,dbb in
pairs(a_b.recipeOnCrusher[_bb.id].crushers)do a_b:remove(dbb)end end end end end;local aab=__b;local bab=#_ab
local cab=math.max(1,math.floor(aab/math.max(1,bab)))
for dab,_bb in ipairs(_ab)do local abb=a_b:getOnUseCrusherCountForRecipe(_bb)
local bbb;if _bb.maxMachine and _bb.maxMachine>0 then
bbb=math.min(cab,_bb.maxMachine)else bbb=cab end
if abb>bbb then local cbb=abb-bbb
for dbb,_cb in
pairs(a_b.recipeOnCrusher[_bb.id].crushers)do if cbb<=0 then break end;a_b:remove(_cb)cbb=cbb-1 end;abb=a_b:getOnUseCrusherCountForRecipe(_bb)end
if abb<bbb then local cbb=bbb-abb
for dbb,_cb in pairs(ada)do if cbb<=0 then break end;if
not a_b:isUsing(_cb)then a_b:set(_bb,_cb)cbb=cbb-1 end end end
if
_bb.input and _bb.input.items and#_bb.input.items>0 then
for cbb,dbb in pairs(a_b.recipeOnCrusher[_bb.id].crushers)do for _cb,acb in
ipairs(_bb.input.items)do local bcb=math.min(64,_bb.inputItemRate or 64)
dda.transferItemTo(dbb,acb,bcb)end end end;aab=aab-bbb;bab=bab-1
cab=math.max(1,math.floor(aab/math.max(1,bab)))end;sleep(1)end end
local d_b=function()local _ab=_ca()
if
_ab and _ab.side and _ab.channel and _ab.secret then
print("Found saved communicator config, attempting to connect...")
d_a.open(_ab.side,_ab.channel,"recipe",_ab.secret)
local aab=d_a.communicationChannels[_ab.side][_ab.channel]["recipe"]
aab.addMessageHandler("getRecipesRes",function(bab,cab,dab)local _bb=cab or{}bba={}for abb,bbb in ipairs(_bb)do
if bbb.name and
bbb.name:lower():find("^crush")then table.insert(bba,bbb)end end end)
aab.addMessageHandler("update",function(bab,cab,dab)
if cab and type(cab)=="table"then local _bb={}for abb,bbb in ipairs(cab)do
if bbb.name and
bbb.name:lower():find("^crush")then table.insert(_bb,bbb)end end
if#_bb>0 then b_b(_bb)end end end)d_a.listen()end end;parallel.waitForAll(d_b,c_b) end
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
