local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.CommandLineTransfer"] = function() local _b=require("wrapper.PeripheralWrapper")
local ab=require("programs.command.CommandLine")
local bb=require("programs.command.transfer.ListCommand")local cb=require("programs.command.transfer.JobCommand")
local db=require("programs.command.transfer.JobDataManager")
local _c=require("programs.command.transfer.JobExecutor")local ac=require("utils.Logger")
local bc=require("programs.command.transfer.SnapShot")ac.currentLevel=ac.levels.ERROR
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
modules["wrapper.PeripheralWrapper"] = function() local c=require("utils.Logger")local d={}
TYPES={DEFAULT_INVENTORY=1,UNLIMITED_PERIPHERAL_INVENTORY=2,TANK=3,REDSTONE=4}d.loadedPeripherals={}
d.wrap=function(_a)if _a==nil or _a==""then
error("Peripheral name cannot be nil or empty")end;local aa=peripheral.wrap(_a)
d.addBaseMethods(aa,_a)if aa==nil then
error("Failed to wrap peripheral '".._a.."'")end;if aa.isInventory()then
d.addInventoryMethods(aa)end
if aa.isTank()then d.addTankMethods(aa)end;return aa end
d.addBaseMethods=function(_a,aa)
if _a==nil then error("Peripheral cannot be nil")end;if _a.getTypes==nil then _a._types=d.getTypes(_a)
_a.getTypes=function()return _a._types end end
if _a.isTypeOf==nil then _a.isTypeOf=function(ba)return
d.isTypeOf(_a,ba)end end;_a._id=aa;_a.getName=function()return _a._id end
_a.getId=function()return _a._id end;_a._isInventory=d.isInventory(_a)
_a.isInventory=function()return _a._isInventory end;_a._isTank=d.isTank(_a)
_a.isTank=function()return _a._isTank end;_a._isRedstone=d.isRedstone(_a)
_a.isRedstone=function()return _a._isRedstone end
_a._isDefaultInventory=d.isTypeOf(_a,TYPES.DEFAULT_INVENTORY)
_a.isDefaultInventory=function()return _a._isDefaultInventory end
_a._isUnlimitedPeripheralInventory=d.isTypeOf(_a,TYPES.UNLIMITED_PERIPHERAL_INVENTORY)
_a.isUnlimitedPeripheralInventory=function()return _a._isUnlimitedPeripheralInventory end end
d.addInventoryMethods=function(_a)
if d.isTypeOf(_a,TYPES.DEFAULT_INVENTORY)then
_a.getItems=function()local aa={}local ba={}
for ca,da in
pairs(_a.list())do if aa[da.name]==nil then aa[da.name]={name=da.name,count=0}
table.insert(ba,aa[da.name])end;aa[da.name].count=
aa[da.name].count+da.count end;return ba,aa end
_a.transferItemTo=function(aa,ba,ca)
if aa.isDefaultInventory()then local da=_a.size()local _b=0
for slot=1,da do
local ab=_a.getItemDetail(slot)
if ab~=nil and ab.name==ba then local bb=math.min(ab.count,ca)
local cb=_a.pushItems(aa.getName(),slot,bb)if cb==0 then return _b end;_b=_b+cb;ca=ca-cb end;if ca<=0 then return _b end end;return _b elseif aa.isUnlimitedPeripheralInventory()then local da=0
while da<ca do
local _b=aa.pullItem(_a.getName(),ba,ca-da)if _b==0 then return da end;da=da+_b end;return da end;return 0 end
_a.transferItemFrom=function(aa,ba,ca)
if aa.isDefaultInventory()then local da=aa.size()local _b=0
for slot=1,da do
local ab=aa.getItemDetail(slot)
if ab~=nil and ab.name==ba then
local bb=_a.pullItems(aa.getName(),slot,ca)if bb==0 then return _b end;_b=_b+bb;ca=ca-bb end;if ca<=0 then return _b end end;return _b elseif aa.isUnlimitedPeripheralInventory()then local da=0
while da<ca do
local _b=aa.pushItem(_a.getName(),ba,ca-da)if _b==0 then return da end;da=da+_b end;return da end end elseif _a.isUnlimitedPeripheralInventory()then
_a.getItems=function()return _a.items()end
_a.transferItemTo=function(aa,ba,ca)local da=0
while da<ca do
local _b=_a.pushItem(aa.getName(),ba,ca-da)if _b==0 then return da end;da=da+_b end;return da end
_a.transferItemFrom=function(aa,ba,ca)local da=0
while da<ca do
local _b=_a.pullItem(aa.getName(),ba,ca-da)if _b==0 then return da end;da=da+_b end;return da end else
error("Peripheral "..
_a.getName().." types "..table.concat(d.getTypes(_a),", ")..
" is not an inventory")end end
d.addTankMethods=function(_a)
if _a==nil then error("Peripheral cannot be nil")end
if not d.isTank(_a)then error("Peripheral is not a tank")end
_a.getFluids=function()local aa={}local ba={}
for ca,da in pairs(_a.tanks())do
if aa[da.name]==nil then
aa[da.name]={name=da.name,amount=0}table.insert(ba,aa[da.name])end
aa[da.name].amount=aa[da.name].amount+da.amount end;return ba end
_a.transferFluidTo=function(aa,ba,ca)if aa.isTank()==false then
error(string.format("Peripheral '%s' is not a tank",aa.getName()))end;local da=0;while da<ca do local _b=_a.pushFluid(aa.getName(),
ca-da,ba)if _b==0 then return da end
da=da+_b end;return da end
_a.transferFluidFrom=function(aa,ba,ca)if aa.isTank()==false then
error(string.format("Peripheral '%s' is not a tank",aa.getName()))end;local da=0;while da<ca do local _b=_a.pullFluid(aa.getName(),
ca-da,ba)if _b==0 then return da end
da=da+_b end;return da end end
d.getTypes=function(_a)if _a._types~=nil then return _a._types end;local aa={}if _a.list~=nil then
table.insert(aa,TYPES.DEFAULT_INVENTORY)end;if _a.items~=nil then
table.insert(aa,TYPES.UNLIMITED_PERIPHERAL_INVENTORY)end;if _a.tanks~=nil then
table.insert(aa,TYPES.TANK)end;if _a.redstone~=nil then
table.insert(aa,TYPES.REDSTONE)end;_a._types=aa;return aa end
d.isInventory=function(_a)local aa=d.getTypes(_a)
if _a._isInventory~=nil then return _a._isInventory end;for ba,ca in ipairs(aa)do
if ca==TYPES.DEFAULT_INVENTORY or
ca==TYPES.UNLIMITED_PERIPHERAL_INVENTORY then _a._isInventory=true;return true end end
_a._isInventory=false;return false end
d.isTank=function(_a)local aa=d.getTypes(_a)
if _a._isTank~=nil then return _a._isTank end
for ba,ca in ipairs(aa)do if ca==TYPES.TANK then _a._isTank=true;return true end end;_a._isTank=false;return false end
d.isRedstone=function(_a)local aa=d.getTypes(_a)
if _a._isRedstone~=nil then return _a._isRedstone end;for ba,ca in ipairs(aa)do
if ca==TYPES.REDSTONE then _a._isRedstone=true;return true end end;_a._isRedstone=false;return false end
d.isTypeOf=function(_a,aa)
if _a==nil then error("Peripheral cannot be nil")end;if aa==nil then error("Type cannot be nil")end
local ba=d.getTypes(_a)for ca,da in ipairs(ba)do if da==aa then return true end end;return false end
d.addPeripherals=function(_a)
if _a==nil then error("Peripheral name cannot be nil")end;local aa=d.wrap(_a)
if aa~=nil then d.loadedPeripherals[_a]=aa end end
d.reloadAll=function()for _a,aa in ipairs(peripheral.getNames())do
d.addPeripherals(aa)end end;d.getAll=function()return d.loadedPeripherals end
d.getByName=function(_a)
if
_a==nil then error("Peripheral name cannot be nil")end
if d.loadedPeripherals[_a]==nil then d.addPeripherals(_a)end;return d.loadedPeripherals[_a]end
d.getByTypes=function(_a)if _a==nil or#_a==0 then
error("Types cannot be nil or empty")end;local aa={}
for ba,ca in pairs(d.getAll())do for da,_b in ipairs(_a)do if
d.isTypeOf(ca,_b)then aa[ba]=ca;break end end end;return aa end;return d end
modules["programs.command.CommandLine"] = function() local ba={}ba.__index=ba
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
modules["programs.command.transfer.ListCommand"] = function() local ba=require("programs.command.transfer.SnapShot")
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
modules["programs.command.transfer.JobCommand"] = function() local ab=require("programs.command.transfer.SnapShot")
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
local __a={"inventory","tank"}return cb.filterSuggestions(__a,cd[3])elseif#cd>=4 then local __a=cd[#cd]
if
cd[2]=="input"or cd[2]=="output"then
if cd[3]=="inventory"then local a_a={}for b_a,c_a in
pairs(ab.inventories)do table.insert(a_a,b_a)end;return
cb.filterSuggestions(a_a,__a)elseif cd[3]=="tank"then local a_a={}for b_a,c_a in pairs(ab.tanks)do
table.insert(a_a,b_a)end;return cb.filterSuggestions(a_a,__a)end elseif cd[2]=="filter"then local a_a={}
for b_a,c_a in pairs(ab.items)do table.insert(a_a,b_a)end;return cb.filterSuggestions(a_a,__a)end end;return dd end)
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
modules["programs.command.transfer.JobDataManager"] = function() local ba=require("utils.OSUtils")
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
modules["programs.command.transfer.JobExecutor"] = function() local da=require("wrapper.PeripheralWrapper")
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
ab.executableJobs[dc]={enable=true,exec=function()_b.info("Executing job: {}",dc)local __a=_d.filters or
{}local a_a=_d.isFilterBlacklist or false;if
next(ad)and next(bd)then _c(ad,bd,__a,a_a)end;if next(cd)and
next(dd)then ac(cd,dd,__a,a_a)end end}else ab.executableJobs[dc]=nil end end end
function ab.run()
for bc,cc in pairs(ab.executableJobs)do
if cc.enable then local dc,_d=pcall(cc.exec)if not dc then
cc.enable=false
print(string.format("Job '%s' encountered an error and has been disabled: %s",bc,_d))end end end end;return ab end
modules["utils.Logger"] = function() local b={currentLevel=1,printFunctions={}}
b.levels={DEBUG=1,INFO=2,WARN=3,ERROR=4}
b.addPrintFunction=function(c)table.insert(b.printFunctions,c)end
b.print=function(c,d,_a,aa,...)
if c>=b.currentLevel then local ba=b.formatBraces(aa,...)for ca,da in
ipairs(b.printFunctions)do da(c,d,_a,ba)end end end
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
modules["programs.command.transfer.SnapShot"] = function() local _a=require("wrapper.PeripheralWrapper")
local aa={inventories={},tanks={},items={},fluids={}}
local function ba(da,_b)if not da.getItems then return end;local ab=da.getItems()for bb,cb in ipairs(ab)do
_b[cb.name]=true end end
local function ca(da,_b)if not da.getFluids then return end;local ab=da.getFluids()for bb,cb in ipairs(ab)do
_b[cb.name]=true end end
function aa.takeSnapShot()_a.reloadAll()local da=_a.getAll()
for _b,ab in pairs(da)do if ab.isInventory()then
aa.inventories[_b]=true;ba(ab,aa.items)end;if ab.isTank()then
aa.tanks[_b]=true;ca(ab,aa.fluids)end end end;return aa end
modules["utils.OSUtils"] = function() local c=require("utils.Logger")local d={}
d.timestampBaseIdGenerate=function()
local _a=os.epoch("utc")local aa=math.random(1000,9999)return
tostring(_a).."-"..tostring(aa)end
d.loadTable=function(_a)local aa={}local ba=fs.open(_a,"r")if ba then local ca=ba.readAll()
aa=textutils.unserialize(ca)ba.close()else return nil end;return aa end
d.saveTable=function(_a,aa)local ba
local ca,da=xpcall(function()ba=textutils.serialize(aa)end,function(ab)
return ab end)if not ca then
c.error("Failed to serialize table for {}, error: {}",_a,da)return end;local _b=fs.open(_a,"w")if _b then
_b.write(ba)_b.close()else
c.error("Failed to open file for writing: {}",_a)end end;return d end
return modules["programs.CommandLineTransfer"]()