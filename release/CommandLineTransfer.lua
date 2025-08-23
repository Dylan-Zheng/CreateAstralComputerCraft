local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CommandLineTransfer"] = function(...) local _b=require("wrapper.PeripheralWrapper")
local ab=require("programs.command.CommandLine")
local bb=require("programs.command.transfer.ListCommand")local cb=require("programs.command.transfer.JobCommand")
local db=require("programs.command.transfer.JobDataManager")
local _c=require("programs.command.transfer.JobExecutor")local ac=require("utils.Logger")
local bc=require("programs.common.SnapShot")ac.currentLevel=ac.levels.ERROR
ac.addPrintFunction(function(dc,_d,ad,bd)
bd=string.format("[%s:%d] %s",_d,ad,bd)
if dc==ac.levels.DEBUG then print("DEBUG: "..bd)elseif
dc==ac.levels.INFO then print("INFO: "..bd)elseif dc==ac.levels.WARN then
print("WARN: "..bd)elseif dc==ac.levels.ERROR then print("ERROR: "..bd)end end)_b.reloadAll()bc.takeSnapShot()db:load()
local cc=ab:new()
cc:addCommand("list","List system components. Usage: list <inventory|tank|item|fluid|reload> [page]",bb.execute,bb.complete)
cc:addCommand("job","Manage transfer jobs. Usage: job <list|create|edit|save|delete> [name]",cb.execute,cb.complete)
cc:addCommand("log","Manage logging level. Usage: log set <debug|info|warn|error>",function(dc)local _d={}for bd in string.gmatch(dc,"%S+")do
table.insert(_d,bd)end
if#_d<2 then local bd="unknown"
for cd,dd in pairs(ac.levels)do if
dd==ac.currentLevel then bd=string.lower(cd)break end end;print("Current log level: "..bd)
print("Usage: log set <debug|info|warn|error>")return end;local ad=string.lower(_d[2])
if ad=="set"then if#_d<3 then
print("Usage: log set <debug|info|warn|error>")return end;local bd=string.upper(_d[3])
if
ac.levels[bd]then ac.currentLevel=ac.levels[bd]
print("Log level set to: "..string.lower(bd))else
print("Invalid log level. Use: debug, info, warn, or error")end else print("Usage: log set <debug|info|warn|error>")end end,function(dc)
local _d={}
for ad in string.gmatch("log "..dc,"%S+")do table.insert(_d,ad)end
if#_d==2 then return ab.filterSuggestions({"set"},_d[2])elseif#_d==3 and
_d[2]=="set"then return
ab.filterSuggestions({"debug","info","warn","error"},_d[3])end;return{}end)
parallel.waitForAll(function()while true do cc:run()end end,function()while true do _c.run()
os.sleep(0.2)end end) end
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
modules["programs.command.transfer.ListCommand"] = function(...) local ba=require("programs.common.SnapShot")
local ca=require("programs.command.CommandLine")local da={}local function _b(cb)local db={}
for _c in string.gmatch(cb,"%S+")do table.insert(db,_c)end;return db end
local function ab(cb,db,_c)_c=_c or 10
db=db or 1;local ac=(db-1)*_c+1;local bc=math.min(ac+_c-1,#cb)local cc=math.ceil(#
cb/_c)local dc={}
for i=ac,bc do table.insert(dc,cb[i])end;return dc,db,cc,#cb end;local function bb(cb)local db={}for _c,ac in pairs(cb)do table.insert(db,_c)end
table.sort(db)return db end
function da.execute(cb)
local db=_b(cb)if#db<2 then
print("Usage: list <inventory|tank|item|fluid|reload> [page]")return end
local _c=string.lower(db[2])
if _c=="reload"then
print("Reloading peripherals and taking snapshot...")ba.takeSnapShot()print("Reload completed.")return end;local ac=tonumber(db[3])or 1
if _c=="inventory"then
local bc=bb(ba.inventories)local cc,dc,_d,ad=ab(bc,ac)
print(string.format("=== Inventories (Page %d of %d, Total: %d) ===",dc,_d,ad))
for bd,cd in ipairs(cc)do print(string.format("- %s",cd))end elseif _c=="tank"then local bc=bb(ba.tanks)local cc,dc,_d,ad=ab(bc,ac)
print(string.format("=== Tanks (Page %d of %d, Total: %d) ===",dc,_d,ad))
for bd,cd in ipairs(cc)do print(string.format("- %s",cd))end elseif _c=="item"then local bc=bb(ba.items)local cc,dc,_d,ad=ab(bc,ac)
print(string.format("=== Items (Page %d of %d, Total: %d) ===",dc,_d,ad))
for bd,cd in ipairs(cc)do print(string.format("- %s",cd))end elseif _c=="fluid"then local bc=bb(ba.fluids)local cc,dc,_d,ad=ab(bc,ac)
print(string.format("=== Fluids (Page %d of %d, Total: %d) ===",dc,_d,ad))
for bd,cd in ipairs(cc)do print(string.format("- %s",cd))end else
print("Invalid list type. Use: inventory, tank, item, fluid, or reload")
print("Usage: list <inventory|tank|item|fluid|reload> [page]")end end
function da.complete(cb)local db=_b("list "..cb)local _c={}
if#db==2 then
local ac={"inventory","tank","item","fluid","reload"}return ca.filterSuggestions(ac,db[2])elseif#db==3 and
string.lower(db[2])~="reload"then
local ac={"1","2","3","4","5","6","7","8","9","10"}return ca.filterSuggestions(ac,db[3])end;return _c end;return da end
modules["programs.command.transfer.JobCommand"] = function(...) local ab=require("programs.common.SnapShot")
local bb=require("programs.command.transfer.JobDataManager")local cb=require("programs.command.CommandLine")local db={}
local function _c(ad)local bd={}for cd in
string.gmatch(ad,"%S+")do table.insert(bd,cd)end;return bd end
local function ac()local ad={}
for bd,cd in pairs(bb.jobs)do table.insert(ad,bd)end;table.sort(ad)return ad end;local bc=nil;local cc=nil
local function dc()
if bc then bc:changeSuffix(cc..">")return bc end;bc=cb:new()bc:changeSuffix(cc..">")
local function ad(bd,cd)
if bd=="input"and
cd=="inventory"then return bb.JOB_COMPONENT_TYPES.INPUT_INVENTORY elseif
bd=="output"and cd=="inventory"then
return bb.JOB_COMPONENT_TYPES.OUTPUT_INVENTORY elseif bd=="input"and cd=="tank"then
return bb.JOB_COMPONENT_TYPES.INPUT_TANK elseif bd=="output"and cd=="tank"then
return bb.JOB_COMPONENT_TYPES.OUTPUT_TANK elseif bd=="filter"then return bb.JOB_COMPONENT_TYPES.FILTER end;return nil end
bc:addCommand("list","List job components. Usage: list <input|output|filter|blacklist> [inventory|tank]",function(bd)local cd=_c(bd)if#cd<2 then
print("Usage: list <input|output|filter|blacklist> [inventory|tank]")return end
local dd=string.lower(cd[2])local __a=cd[3]and string.lower(cd[3])
if dd=="filter"then local a_a=
bb:getJobDetail(cc,bb.JOB_COMPONENT_TYPES.FILTER)or{}
print("=== Filters ===")for b_a,c_a in ipairs(a_a)do print("- "..c_a)end elseif dd=="blacklist"then
local a_a=bb:getJob(cc)local b_a=a_a and a_a.isFilterBlacklist or false
print("=== Blacklist Setting ===")print("Enabled: "..tostring(b_a))elseif(
dd=="input"or dd=="output")and __a then local a_a=ad(dd,__a)
if a_a then local b_a=
bb:getJobDetail(cc,a_a)or{}
print(string.format("=== %s %s ===",dd:gsub("^%l",string.upper),__a:gsub("^%l",string.upper)))for c_a,d_a in ipairs(b_a)do print("- "..d_a)end else
print("Invalid component type")end else
print("Usage: list <input|output|filter|blacklist> [inventory|tank]")end end,function(bd)local cd=_c(
"list "..bd)local dd={}
if#cd==2 then
local __a={"input","output","filter","blacklist"}return cb.filterSuggestions(__a,cd[2])elseif#cd==3 and(cd[2]=="input"or
cd[2]=="output")then
local __a={"inventory","tank"}return cb.filterSuggestions(__a,cd[3])end;return dd end)
bc:addCommand("describe","Show detailed component information. Usage: describe <input|output|filter|blacklist|status> [inventory|tank]",function(bd)
local cd=_c(bd)if#cd<2 then
print("Usage: describe <input|output|filter|blacklist|status> [inventory|tank]")return end
local dd=string.lower(cd[2])local __a=cd[3]and string.lower(cd[3])
if dd=="filter"then local a_a=
bb:getJobDetail(cc,bb.JOB_COMPONENT_TYPES.FILTER)or{}
print(string.format("=== Filters for job '%s' ===",cc))print("Total filters: "..#a_a)for b_a,c_a in ipairs(a_a)do
print(string.format("%d. %s",b_a,c_a))end elseif dd=="blacklist"then local a_a=bb:getJob(cc)local b_a=a_a and
a_a.isFilterBlacklist or false
print(string.format("=== Blacklist setting for job '%s' ===",cc))
print("Blacklist enabled: "..tostring(b_a))
if b_a then
print("Filters are treated as blacklist (items matching filters are excluded)")else
print("Filters are treated as whitelist (only items matching filters are included)")end elseif dd=="status"then local a_a=bb:getJob(cc)
local b_a=a_a and a_a.enabled~=false
print(string.format("=== Status for job '%s' ===",cc))print("Job enabled: "..tostring(b_a))if
b_a then
print("This job will be executed when the system runs")else
print("This job is disabled and will be skipped during execution")end elseif(
dd=="input"or dd=="output")and __a then local a_a=ad(dd,__a)
if a_a then local b_a=
bb:getJobDetail(cc,a_a)or{}
print(string.format("=== %s %s for job '%s' ===",dd:gsub("^%l",string.upper),__a:gsub("^%l",string.upper),cc))print("Total components: "..#b_a)for c_a,d_a in ipairs(b_a)do
print(string.format("%d. %s",c_a,d_a))end else
print("Invalid component type")end else
print("Usage: describe <input|output|filter|blacklist|status> [inventory|tank]")end end,function(bd)local cd=_c(
"describe "..bd)local dd={}
if#cd==2 then
local __a={"input","output","filter","blacklist","status"}return cb.filterSuggestions(__a,cd[2])elseif#cd==3 and(cd[2]=="input"or
cd[2]=="output")then
local __a={"inventory","tank"}return cb.filterSuggestions(__a,cd[3])end;return dd end)
bc:addCommand("add","Add components to job. Usage: add <input|output> <inventory|tank> <name1> [name2]... OR add filter <name1> [name2]...",function(bd)
local cd=_c(bd)if#cd<3 then
print("Usage: add <input|output|filter> [inventory|tank] <name1> [name2] ...")return end
local dd=string.lower(cd[2])
if dd=="filter"then local __a={}
for i=3,#cd do table.insert(__a,cd[i])end
bb:addComponentToJob(cc,bb.JOB_COMPONENT_TYPES.FILTER,table.unpack(__a))print("Added "..#__a.." filter(s)")elseif dd==
"input"or dd=="output"then if#cd<4 then
print("Usage: add <input|output> <inventory|tank> <name1> [name2] ...")return end
local __a=string.lower(cd[3])local a_a=ad(dd,__a)
if a_a then local b_a={}
for i=4,#cd do table.insert(b_a,cd[i])end
bb:addComponentToJob(cc,a_a,table.unpack(b_a))
print("Added "..#b_a.." "..__a.."(s)")else print("Invalid component type")end else
print("Usage: add <input|output|filter> [inventory|tank] <name1> [name2] ...")end end,function(bd)local cd=_c(
"add "..bd)local dd={}
if#cd==2 then
local __a={"input","output","filter"}return cb.filterSuggestions(__a,cd[2])elseif#cd==3 and(cd[2]=="input"or
cd[2]=="output")then
local __a={"inventory","tank"}return cb.filterSuggestions(__a,cd[3])elseif
#cd>=2 and cd[2]=="filter"then print(cd[2],cd[3])local __a={}for a_a,b_a in pairs(ab.items)do
table.insert(__a,a_a)end;for a_a,b_a in pairs(ab.fluids)do
table.insert(__a,a_a)end
return cb.filterSuggestions(__a,lastArg)elseif#cd>=4 and(cd[2]=="input"or cd[2]=="output")then
if
cd[3]=="inventory"then local __a={}for a_a,b_a in pairs(ab.inventories)do
table.insert(__a,a_a)end
return cb.filterSuggestions(__a,lastArg)elseif cd[3]=="tank"then local __a={}
for a_a,b_a in pairs(ab.tanks)do table.insert(__a,a_a)end;return cb.filterSuggestions(__a,lastArg)end end;return dd end)
bc:addCommand("remove","Remove components from job. Usage: remove <input|output> <inventory|tank> <name1> [name2]... OR remove filter <name1> [name2]...",function(bd)
local cd=_c(bd)if#cd<3 then
print("Usage: remove <input|output|filter> [inventory|tank] <name1> [name2] ...")return end
local dd=string.lower(cd[2])
if dd=="filter"then local __a={}
for i=3,#cd do table.insert(__a,cd[i])end
local a_a=bb:removeComponentFromJob(cc,bb.JOB_COMPONENT_TYPES.FILTER,table.unpack(__a))print("Removed "..a_a.." filter(s)")elseif dd==
"input"or dd=="output"then if#cd<4 then
print("Usage: remove <input|output> <inventory|tank> <name1> [name2] ...")return end
local __a=string.lower(cd[3])local a_a=ad(dd,__a)
if a_a then local b_a={}
for i=4,#cd do table.insert(b_a,cd[i])end
local c_a=bb:removeComponentFromJob(cc,a_a,table.unpack(b_a))
print("Removed "..c_a.." "..__a.."(s)")else print("Invalid component type")end else
print("Usage: remove <input|output|filter> [inventory|tank] <name1> [name2] ...")end end,function(bd)local cd=_c(
"remove "..bd)local dd={}
if#cd==2 then
local __a={"input","output","filter"}return cb.filterSuggestions(__a,cd[2])elseif#cd==3 and(cd[2]=="input"or
cd[2]=="output")then
local __a={"inventory","tank"}return cb.filterSuggestions(__a,cd[3])elseif#cd>=4 then local __a=cd[#cd]
if
cd[2]=="filter"then
local a_a=bb:getJobDetail(cc,bb.JOB_COMPONENT_TYPES.FILTER)or{}return cb.filterSuggestions(a_a,__a)elseif cd[2]=="input"or
cd[2]=="output"then local a_a=ad(cd[2],cd[3])
if a_a then
local b_a=bb:getJobDetail(cc,a_a)or{}return cb.filterSuggestions(b_a,__a)end end end;return dd end)
bc:addCommand("delete","Delete this job permanently. Usage: delete",function(bd)
print("Are you sure you want to delete job '"..cc.."'? (y/N)")local cd=io.read()
if string.lower(cd)=="y"or
string.lower(cd)=="yes"then bb:removeJob(cc)
print("Job '"..cc.."' deleted.")return"exit"else print("Job deletion cancelled.")end end)
bc:addCommand("blacklist","Manage blacklist setting. Usage: blacklist set <true|false>",function(bd)local cd=_c(bd)
if#cd<3 then
print("Usage: blacklist set <true|false>")local __a=bb:getJob(cc)
local a_a=__a and __a.isFilterBlacklist or false
print("Current blacklist setting: "..tostring(a_a))return end;local dd=string.lower(cd[2])
if dd=="set"then
local __a=string.lower(cd[3])
if __a=="true"then bb:setBlacklist(cc,true)
print("Blacklist enabled for job '"..cc.."'")elseif __a=="false"then bb:setBlacklist(cc,false)
print("Blacklist disabled for job '"..cc.."'")else print("Invalid value. Use 'true' or 'false'")end else print("Usage: blacklist set <true|false>")end end,function(bd)local cd=_c(
"blacklist "..bd)local dd={}
if#cd==2 then local __a={"set"}return
cb.filterSuggestions(__a,cd[2])elseif#cd==3 and cd[2]=="set"then
local __a={"true","false"}return cb.filterSuggestions(__a,cd[3])end;return dd end)
bc:addCommand("exit","Exit job editing mode. Usage: exit",function(bd)bc:changeSuffix(">")return"exit"end)return bc end;local function _d(ad)cc=ad end
function db.execute(ad)local bd=_c(ad)if#bd<2 then
print("Usage: job <list|create|edit|save|enable|disable|delete> [name]")return end
local cd=string.lower(bd[2])
if cd=="list"then print("=== Jobs ===")local dd=ac()
if#dd==0 then
print("No jobs found.")else
for __a,a_a in ipairs(dd)do local b_a=bb:getJob(a_a)local c_a=(b_a and b_a.enabled)and"enabled"or
"disabled"
print(string.format("- %s (%s)",a_a,c_a))end end elseif cd=="create"then
if#bd<3 then print("Usage: job create <name>")return end;local dd=bd[3]if bb:getJob(dd)then
print("Job '"..dd.."' already exists.")return end;bb:addJob(dd,{})print("Created job '"..
dd.."'")
print("Entering job editing mode...")_d(dd)local __a=dc()while true do local a_a=__a:run()
if a_a=="exit"then bb:save()break end end elseif cd=="edit"then if#bd<3 then
print("Usage: job edit <name>")return end;local dd=bd[3]
if not bb:getJob(dd)then print("Job '"..dd..
"' not found.")return end;print("Editing job '"..dd.."'...")_d(dd)
local __a=dc()
while true do local a_a=__a:run()if a_a=="exit"then break end end elseif cd=="save"then bb:save()print("All jobs saved.")elseif cd=="enable"then if#bd<3 then
print("Usage: job enable <name>")return end;local dd=bd[3]local __a=bb:getJob(dd)
if not __a then print(
"Job '"..dd.."' not found.")return end;__a.enabled=true;bb:save()
print("Job '"..dd.."' enabled.")elseif cd=="disable"then
if#bd<3 then print("Usage: job disable <name>")return end;local dd=bd[3]local __a=bb:getJob(dd)if not __a then
print("Job '"..dd.."' not found.")return end;__a.enabled=false;bb:save()print("Job '"..dd..
"' disabled.")elseif cd=="delete"then if#bd<3 then
print("Usage: job delete <name>")return end;local dd=bd[3]
if not bb:getJob(dd)then print("Job '"..dd..
"' not found.")return end
print("Are you sure you want to delete job '"..dd.."'? (y/N)")local __a=io.read()
if string.lower(__a)=="y"or
string.lower(__a)=="yes"then bb:removeJob(dd)
print("Job '"..dd.."' deleted.")else print("Job deletion cancelled.")end else
print("Invalid action. Use: list, create, edit, save, enable, disable, or delete")
print("Usage: job <list|create|edit|save|enable|disable|delete> [name]")end end
function db.complete(ad)local bd=_c("job "..ad)local cd={}
if#bd==2 then
local dd={"list","create","edit","save","enable","disable","delete"}return cb.filterSuggestions(dd,bd[2])elseif
#bd==3 and(bd[2]=="edit"or bd[2]==
"delete"or bd[2]=="enable"or
bd[2]=="disable")then local dd=ac()return cb.filterSuggestions(dd,bd[3])end;return cd end;return db end
modules["programs.command.transfer.JobDataManager"] = function(...) local ba=require("utils.OSUtils")
local ca=require("programs.command.transfer.JobExecutor")local da=require("utils.Logger")
local _b={INPUT_INVENTORY="inputInventory",OUTPUT_INVENTORY="outputInventory",INPUT_TANK="inputTank",OUTPUT_TANK="outputTank",FILTER="filter"}
local ab={[_b.INPUT_INVENTORY]="inputInventories",[_b.OUTPUT_INVENTORY]="outputInventories",[_b.INPUT_TANK]="inputTanks",[_b.OUTPUT_TANK]="outputTanks",[_b.FILTER]="filters"}local bb={jobs={},JOB_COMPONENT_TYPES=_b}
function bb:addJob(cb,db)self.jobs[cb]=db end;function bb:getJob(cb)return self.jobs[cb]end;function bb:removeJob(cb)
self.jobs[cb]=nil end;function bb:save()
ba.saveTable("jobs.data",self.jobs)ca.load(self.jobs)end
function bb:load()
local cb=ba.loadTable("jobs.data")if cb then self.jobs=cb;ca.load(self.jobs)end end
function bb:addComponentToJob(cb,db,...)local _c=self:getJob(cb)if not _c then return end;local ac=ab[db]if not ac then
error(
"Invalid component type: "..tostring(db))end;_c[ac]=_c[ac]or{}for bc,cc in ipairs({...})do
table.insert(_c[ac],cc)end end
function bb:removeComponentFromJob(cb,db,...)local _c=self:getJob(cb)if not _c then return 0 end
local ac=ab[db]if not ac then
error("Invalid component type: "..tostring(db))end;if not _c[ac]then return 0 end;local bc=0
for cc,dc in
ipairs({...})do for i=#_c[ac],1,-1 do
if _c[ac][i]==dc then table.remove(_c[ac],i)bc=bc+1;break end end end;return bc end
function bb:getJobDetail(cb,db)local _c=self:getJob(cb)if not _c then return nil end;local ac=ab[db]if
not ac then
error("Invalid component type: "..tostring(db))end;return _c[ac]or{}end;function bb:setBlacklist(cb,db)local _c=self:getJob(cb)if not _c then return end
_c.isFilterBlacklist=db end
function bb:disableJob(cb)
local db=self:getJob(cb)if not db then return end;db.enabled=false;self:save()end;function bb:enableJob(cb)local db=self:getJob(cb)if not db then return end;db.enabled=true
self:save()end;return bb end
modules["programs.command.transfer.JobExecutor"] = function(...) local da=require("wrapper.PeripheralWrapper")
local _b=require("utils.Logger")local ab={}ab.executableJobs={}local function bb(bc,cc)
if not bc:find("*")then return bc==cc end;local dc=bc:gsub("%*",".*")dc="^"..dc.."$"
return cc:match(dc)~=nil end;local function cb(bc,cc)
local dc={}for _d,ad in pairs(cc)do if bb(bc,_d)then dc[_d]=ad end end
return dc end
local function db(bc,cc,dc)if bc=="minecraft:empty"then return
false end;if not cc or#cc==0 then return true end
local _d=false;for ad,bd in ipairs(cc)do if bb(bd,bc)then _d=true;break end end
_b.debug("Item {} is {} {}",bc,
dc and"blacklist "or"whitelist ",_d and"included"or"excluded")return(dc and not _d)or(not dc and _d)end
local _c=function(bc,cc,dc,_d)
for ad,bd in pairs(bc)do local cd=bd.getItems()
_b.debug("Checking input inventory: {}",ad)
for dd,__a in ipairs(cd)do
_b.debug("Found item: {} x{}",__a.name,__a.count)
if db(__a.name,dc,_d)then local a_a=__a.count
for b_a,c_a in pairs(cc)do
_b.debug("Transferring item: {} x{}",__a.name,__a.count)while true do local d_a=bd.transferItemTo(c_a,__a.name,a_a)a_a=a_a-d_a;if d_a==
0 then break end end;if a_a<=0 then
break end end end end end end
local ac=function(bc,cc,dc,_d)
for ad,bd in pairs(bc)do local cd=bd.getFluids()
for dd,__a in ipairs(cd)do
if db(__a.name,dc,_d)then
for a_a,b_a in pairs(cc)do while true do
local c_a=bd.transferFluidTo(b_a,__a.name,__a.amount)if c_a==0 then break end end end end end end end
function ab.load(bc)if not bc then return end;da.reloadAll()local cc=da.getAll()
for dc,_d in pairs(bc)do
if
_d.enabled then local ad={}local bd={}local cd={}local dd={}if _d.inputInventories then
for __a,a_a in ipairs(_d.inputInventories)do
local b_a=cb(a_a,cc)for c_a,d_a in pairs(b_a)do ad[c_a]=d_a end end end
if
_d.outputInventories then for __a,a_a in ipairs(_d.outputInventories)do local b_a=cb(a_a,cc)
for c_a,d_a in pairs(b_a)do bd[c_a]=d_a end end end
if _d.inputTanks then for __a,a_a in ipairs(_d.inputTanks)do local b_a=cb(a_a,cc)
for c_a,d_a in pairs(b_a)do cd[c_a]=d_a end end end
if _d.outputTanks then for __a,a_a in ipairs(_d.outputTanks)do local b_a=cb(a_a,cc)
for c_a,d_a in pairs(b_a)do dd[c_a]=d_a end end end
ab.executableJobs[dc]={enable=true,exec=function()local __a=_d.filters or{}
local a_a=_d.isFilterBlacklist or false;if next(ad)and next(bd)then
_b.debug("Executing job: {} for item",dc)_c(ad,bd,__a,a_a)end;if next(cd)and
next(dd)then _b.debug("Executing job: {} for fluid",dc)
ac(cd,dd,__a,a_a)end end}else ab.executableJobs[dc]=nil end end end
function ab.run()
for bc,cc in pairs(ab.executableJobs)do
if cc.enable then local dc,_d=pcall(cc.exec)if not dc then
cc.enable=false
print(string.format("Job '%s' encountered an error and has been disabled: %s",bc,_d))end end end end;return ab end
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
modules["programs.common.SnapShot"] = function(...) local ba=require("wrapper.PeripheralWrapper")
local ca=require("utils.Logger")local da={inventories={},tanks={},items={},fluids={}}
local function _b(cb,db)
if not cb.getItems then return end;local _c=cb.getItems()if not _c then return end;for ac,bc in ipairs(_c)do if bc.name then
db[bc.name]=true end end end
local function ab(cb,db)if not cb.getFluids then return end;local _c=cb.getFluids()
if not _c then return end
for ac,bc in ipairs(_c)do if bc.name then db[bc.name]=true end end end
local function bb(cb,db)if not fs.exists(cb)then return false end
local _c=fs.open(cb,"r")if not _c then return false end;local ac=0;while true do local bc=_c.readLine()
if not bc then break end;bc=bc:match("^%s*(.-)%s*$")
if bc~=""then db[bc]=true;ac=ac+1 end end
_c.close()return true,ac end
function da.takeSnapShot()ba.reloadAll()local cb=ba.getAll()
for db,_c in pairs(cb)do if _c.isInventory()then
da.inventories[db]=true;_b(_c,da.items)end;if _c.isTank()then
da.tanks[db]=true;ab(_c,da.fluids)end end;da.loadFromFiles()end;function da.loadFromFiles()bb("item_names",da.items)
bb("fluid_names",da.fluids)end;function da.loadFromFilesOnly()da.items={}
da.fluids={}da.loadFromFiles()end;function da.reset()
da.inventories={}da.tanks={}da.items={}da.fluids={}end
function da.getItemCount()
local cb=0;for db in pairs(da.items)do cb=cb+1 end;return cb end
function da.getFluidCount()local cb=0;for db in pairs(da.fluids)do cb=cb+1 end;return cb end;return da end
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
return modules["programs.CommandLineTransfer"](...)
