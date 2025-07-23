local modules = {}
local loadedModules = {}
local baseRequire = require
require = function(path) if(modules[path])then if(loadedModules[path]==nil)then loadedModules[path] = modules[path]() end return loadedModules[path] end return baseRequire(path) end
modules["programs.Transfer"] = function() local _c=require("libraries.basalt")
local ac=require("elements.TabView")local bc=require("programs.transfer.TransferTab")
local cc=require("wrapper.PeripheralWrapper")local dc=require("programs.transfer.TransferJobManager")
local _d=require("utils.Logger")local ad=require("elements.LogBox")local bd=true
_c.LOGGER.setEnabled(bd)_c.LOGGER.setLogToFile(bd)
if bd then
_d.addPrintFunction(function(d_a,_aa,aaa,baa)
baa=string.format("[%s:%d] %s",_aa,aaa,baa)
if d_a==_d.levels.DEBUG then _c.LOGGER.debug(baa)elseif
d_a==_d.levels.INFO then _c.LOGGER.info(baa)elseif d_a==_d.levels.WARN then
_c.LOGGER.warn(baa)elseif d_a==_d.levels.ERROR then _c.LOGGER.error(baa)end end)end;cc.reloadAll()dc.load()local cd=_c.getMainFrame()
local dd=ac:new(cd:addFrame(),1,1,cd:getWidth(),cd:getHeight())local __a=dd:createTab("Transfers")
local a_a=bc:new(__a.frame,dd)local b_a=dd:createTab("Log")
local c_a=ad:new(b_a.frame,2,2,b_a.frame:getWidth()-2,
b_a.frame:getHeight()-2,colors.white,colors.gray)a_a:init()dd:init()
_d.addPrintFunction(function(d_a,_aa,aaa,baa)
c_a:addLog(string.format("[%d] %s",aaa,baa))end)
parallel.waitForAll(_c.run,function()while true do dc.exec()os.sleep(0.2)end end) end
modules["libraries.basalt"] = function() local ba=true;local ca={}local da={}local _b={}local ab={}local bb=require
require=function(cb)if(_b[cb..".lua"])then if
(ab[cb]==nil)then ab[cb]=_b[cb..".lua"]()end
return ab[cb]end;return bb(cb)end;da["canvas"]={}da["debug"]={}da["reactive"]={}
da["theme"]={}da["xml"]={}da["animation"]={}da["benchmark"]={}
da["state"]={}ca["Scrollbar"]={}ca["Display"]={}ca["Dropdown"]={}
ca["LineChart"]={}ca["Switch"]={}ca["Menu"]={}ca["Slider"]={}ca["Frame"]={}
ca["Flexbox"]={}ca["Timer"]={}ca["VisualElement"]={}ca["Graph"]={}
ca["BigFont"]={}ca["BaseFrame"]={}ca["Checkbox"]={}ca["Container"]={}
ca["List"]={}ca["ProgressBar"]={}ca["Program"]={}ca["Tree"]={}
ca["Image"]={}ca["Label"]={}ca["Input"]={}ca["BarChart"]={}
ca["Button"]={}ca["BaseElement"]={}ca["TextBox"]={}ca["Table"]={}
_b["plugins/canvas.lua"]=function(...)
local cb=require("libraries/colorHex")local db=require("errorManager")local _c={}_c.__index=_c
local ac,bc=string.sub,string.rep
function _c.new(dc)local _d=setmetatable({},_c)_d.commands={pre={},post={}}
_d.type="pre"_d.element=dc;return _d end
function _c:clear()self.commands={pre={},post={}}return self end;function _c:getValue(dc)
if type(dc)=="function"then return dc(self.element)end;return dc end
function _c:setType(dc)if
dc=="pre"or dc=="post"then self.type=dc else
db.error("Invalid type. Use 'pre' or 'post'.")end;return self end
function _c:addCommand(dc)
local _d=#self.commands[self.type]+1;self.commands[self.type][_d]=dc;return _d end
function _c:setCommand(dc,_d)self.commands[dc]=_d;return self end;function _c:removeCommand(dc)
table.remove(self.commands[self.type],dc)return self end
function _c:text(dc,_d,ad,bd,cd)
return
self:addCommand(function(dd)
local a_a,b_a=self:getValue(dc),self:getValue(_d)local c_a=self:getValue(ad)local d_a=self:getValue(bd)
local _aa=self:getValue(cd)
local aaa=type(d_a)=="number"and cb[d_a]:rep(#ad)or d_a
local baa=type(_aa)=="number"and cb[_aa]:rep(#ad)or _aa;dd:drawText(a_a,b_a,c_a)
if aaa then dd:drawFg(a_a,b_a,aaa)end;if baa then dd:drawBg(a_a,b_a,baa)end end)end;function _c:bg(dc,_d,ad)return
self:addCommand(function(bd)bd:drawBg(dc,_d,ad)end)end
function _c:fg(dc,_d,ad)return self:addCommand(function(bd)
bd:drawFg(dc,_d,ad)end)end
function _c:rect(_d,ad,bd,cd,dd,__a,a_a)
return
self:addCommand(function(b_a)local aaa,baa=self:getValue(_d),self:getValue(ad)
local caa,daa=self:getValue(bd),self:getValue(cd)local _ba=self:getValue(dd)local aba=self:getValue(__a)
local bba=self:getValue(a_a)if(type(aba)=="number")then aba=cb[aba]end;if
(type(bba)=="number")then bba=cb[bba]end
local cba=bba and ac(bba:rep(caa),1,caa)local dba=aba and ac(aba:rep(caa),1,caa)local _ca=_ba and
ac(_ba:rep(caa),1,caa)
for i=0,daa-1 do if bba then
b_a:drawBg(aaa,baa+i,cba)end
if aba then b_a:drawFg(aaa,baa+i,dba)end;if _ba then b_a:drawText(aaa,baa+i,_ca)end end end)end
function _c:line(_d,ad,bd,cd,dd,__a,a_a)
local function b_a(_aa,aaa,baa,caa)local daa={}local _ba=0;local aba=math.abs(baa-_aa)
local bba=math.abs(caa-aaa)local cba=(_aa<baa)and 1 or-1
local dba=(aaa<caa)and 1 or-1;local _ca=aba-bba
while true do _ba=_ba+1;daa[_ba]={x=_aa,y=aaa}if
(_aa==baa)and(aaa==caa)then break end;local aca=_ca*2
if aca>-bba then _ca=_ca-bba;_aa=_aa+cba end;if aca<aba then _ca=_ca+aba;aaa=aaa+dba end end;return daa end;local c_a=false;local d_a
if
type(_d)=="function"or type(ad)=="function"or type(bd)=="function"or
type(cd)=="function"then c_a=true else
d_a=b_a(self:getValue(_d),self:getValue(ad),self:getValue(bd),self:getValue(cd))end
return
self:addCommand(function(_aa)if c_a then
d_a=b_a(self:getValue(_d),self:getValue(ad),self:getValue(bd),self:getValue(cd))end
local aaa=self:getValue(dd)local baa=self:getValue(__a)local caa=self:getValue(a_a)local daa=type(baa)==
"number"and cb[baa]or baa
local _ba=
type(caa)=="number"and cb[caa]or caa
for aba,bba in ipairs(d_a)do local cba=math.floor(bba.x)
local dba=math.floor(bba.y)if aaa then _aa:drawText(cba,dba,aaa)end;if daa then
_aa:drawFg(cba,dba,daa)end;if _ba then _aa:drawBg(cba,dba,_ba)end end end)end
function _c:ellipse(_d,ad,bd,cd,dd,__a,a_a)
local function b_a(d_a,_aa,aaa,baa)local aba={}local bba=0;local cba=aaa*aaa;local dba=baa*baa;local _ca=0;local aca=baa;local bca=
dba-cba*baa+0.25 *cba;local cca=0;local dca=2 *cba*aca
local function _da(ada,bda)bba=bba+1;aba[bba]={x=
d_a+ada,y=_aa+bda}bba=bba+1
aba[bba]={x=d_a-ada,y=_aa+bda}bba=bba+1;aba[bba]={x=d_a+ada,y=_aa-bda}bba=bba+1;aba[bba]={x=d_a-
ada,y=_aa-bda}end;_da(_ca,aca)
while cca<dca do _ca=_ca+1;cca=cca+2 *dba
if bca<0 then
bca=bca+dba+cca else aca=aca-1;dca=dca-2 *cba;bca=bca+dba+cca-dca end;_da(_ca,aca)end;bca=
dba* (_ca+0.5)* (_ca+0.5)+cba* (aca-1)* (aca-1)-cba*dba;while aca>0 do
aca=aca-1;dca=dca-2 *cba;if bca>0 then bca=bca+cba-dca else _ca=_ca+1
cca=cca+2 *dba;bca=bca+cba-dca+cca end
_da(_ca,aca)end
return aba end;local c_a=b_a(_d,ad,bd,cd)
return
self:addCommand(function(d_a)local _aa=self:getValue(dd)
local aaa=self:getValue(__a)local baa=self:getValue(a_a)local caa=
type(aaa)=="number"and cb[aaa]or aaa;local daa=
type(baa)=="number"and cb[baa]or baa
for _ba,aba in pairs(c_a)do
local bba=math.floor(aba.x)local cba=math.floor(aba.y)
if _aa then d_a:drawText(bba,cba,_aa)end;if caa then d_a:drawFg(bba,cba,caa)end;if daa then
d_a:drawBg(bba,cba,daa)end end end)end;local cc={hooks={}}
function cc.setup(dc)
dc.defineProperty(dc,"canvas",{default=nil,type="table",getter=function(_d)if not _d._values.canvas then
_d._values.canvas=_c.new(_d)end;return _d._values.canvas end})end;function cc.hooks.render(dc)local _d=dc.get("canvas")
if
_d and#_d.commands.pre>0 then for ad,bd in pairs(_d.commands.pre)do bd(dc)end end end
function cc.hooks.postRender(dc)
local _d=dc.get("canvas")if _d and#_d.commands.post>0 then for ad,bd in pairs(_d.commands.post)do
bd(dc)end end end;return{VisualElement=cc,API=_c}end
_b["plugins/debug.lua"]=function(...)local dc=require("log")
local _d=require("libraries/colorHex")local ad=10;local bd=false;local cd={ERROR=1,WARN=2,INFO=3,DEBUG=4}
local function dd(c_a)
local d_a={renderCount=0,eventCount={},lastRender=os.epoch("utc"),properties={},children={}}
return
{trackProperty=function(_aa,aaa)d_a.properties[_aa]=aaa end,trackRender=function()
d_a.renderCount=d_a.renderCount+1;d_a.lastRender=os.epoch("utc")end,trackEvent=function(_aa)d_a.eventCount[_aa]=(
d_a.eventCount[_aa]or 0)+1 end,dump=function()return
{type=c_a.get("type"),id=c_a.get("id"),stats=d_a}end}end;local __a={}function __a.debug(c_a,d_a)c_a._debugger=dd(c_a)c_a._debugLevel=d_a or cd.INFO;return
c_a end
function __a.dumpDebug(c_a)if
not c_a._debugger then return end;return c_a._debugger.dump()end;local a_a={}
function a_a.openConsole(c_a)
if not c_a._debugFrame then local d_a=c_a.get("width")
local _aa=c_a.get("height")
c_a._debugFrame=c_a:addFrame("basaltDebugLog"):setWidth(d_a):setHeight(_aa):listenEvent("mouse_scroll",true)
c_a._debugFrame:addButton("basaltDebugLogClose"):setWidth(9):setHeight(1):setX(
d_a-8):setY(_aa):setText("Close"):onClick(function()
c_a:closeConsole()end)c_a._debugFrame._scrollOffset=0
c_a._debugFrame._processedLogs={}
local function aaa(aba,bba)local cba={}while#aba>0 do local dba=aba:sub(1,bba)table.insert(cba,dba)aba=aba:sub(
bba+1)end;return cba end
local function baa()local aba={}local bba=c_a._debugFrame.get("width")
for cba,dba in
ipairs(dc._logs)do local _ca=aaa(dba.message,bba)for aca,bca in ipairs(_ca)do
table.insert(aba,{text=bca,level=dba.level})end end;return aba end;local caa=#baa()-c_a.get("height")
c_a._scrollOffset=caa;local daa=c_a._debugFrame.render
c_a._debugFrame.render=function(aba)daa(aba)
aba._processedLogs=baa()local bba=aba.get("height")-2
local cba=#aba._processedLogs;local dba=math.max(0,cba-bba)
aba._scrollOffset=math.min(aba._scrollOffset,dba)
for i=1,bba-2 do local _ca=i+aba._scrollOffset
local aca=aba._processedLogs[_ca]
if aca then
local bca=

aca.level==dc.LEVEL.ERROR and colors.red or aca.level==
dc.LEVEL.WARN and colors.yellow or aca.level==dc.LEVEL.DEBUG and colors.lightGray or colors.white;aba:textFg(2,i,aca.text,bca)end end end;local _ba=c_a._debugFrame.dispatchEvent
c_a._debugFrame.dispatchEvent=function(aba,bba,cba,...)
if
(bba=="mouse_scroll")then
aba._scrollOffset=math.max(0,aba._scrollOffset+cba)aba:updateRender()return true else return _ba(aba,bba,cba,...)end end end
c_a._debugFrame.set("width",c_a.get("width"))
c_a._debugFrame.set("height",c_a.get("height"))c_a._debugFrame.set("visible",true)return c_a end
function a_a.closeConsole(c_a)if c_a._debugFrame then
c_a._debugFrame.set("visible",false)end;return c_a end
function a_a.toggleConsole(c_a)
if
c_a._debugFrame and c_a._debugFrame:getVisible()then c_a:closeConsole()else c_a:openConsole()end;return c_a end;local b_a={}
function b_a.debugChildren(c_a,d_a)c_a:debug(d_a)
for _aa,aaa in pairs(c_a.get("children"))do if
aaa.debug then aaa:debug(d_a)end end;return c_a end;return{BaseElement=__a,Container=b_a,BaseFrame=a_a}end
_b["plugins/reactive.lua"]=function(...)local ad=require("errorManager")
local bd=require("propertySystem")local cd={colors=true,math=true,clamp=true,round=true}
local dd={clamp=function(aaa,baa,caa)return
math.min(math.max(aaa,baa),caa)end,round=function(aaa)
return math.floor(aaa+0.5)end,floor=math.floor,ceil=math.ceil,abs=math.abs}
local function __a(aaa,baa,caa)aaa=aaa:gsub("^{(.+)}$","%1")
aaa=aaa:gsub("([%w_]+)%$([%w_]+)",function(bba,cba)
if bba=="self"then return
string.format('__getState("%s")',cba)elseif bba=="parent"then return
string.format('__getParentState("%s")',cba)else return
string.format('__getElementState("%s", "%s")',bba,cba)end end)
aaa=aaa:gsub("([%w_]+)%.([%w_]+)",function(bba,cba)if cd[bba]then return bba.."."..cba end;if
tonumber(bba)then return bba.."."..cba end;return
string.format('__getProperty("%s", "%s")',bba,cba)end)
local daa=setmetatable({colors=colors,math=math,tostring=tostring,tonumber=tonumber,__getState=function(bba)return baa:getState(bba)end,__getParentState=function(bba)return
baa.parent:getState(bba)end,__getElementState=function(bba,cba)if tonumber(bba)then return nil end
local dba=baa:getBaseFrame():getChild(bba)if not dba then ad.header="Reactive evaluation error"
ad.error("Could not find element: "..bba)return nil end;return
dba:getState(cba).value end,__getProperty=function(bba,cba)if
tonumber(bba)then return nil end
if bba=="self"then return baa.get(cba)elseif bba=="parent"then return
baa.parent.get(cba)else local dba=baa.parent:getChild(bba)if not dba then
ad.header="Reactive evaluation error"
ad.error("Could not find element: "..bba)return nil end
return dba.get(cba)end end},{__index=dd})if(baa._properties[caa].type=="string")then
aaa="tostring("..aaa..")"elseif(baa._properties[caa].type=="number")then
aaa="tonumber("..aaa..")"end;local _ba,aba=load(
"return "..aaa,"reactive","t",daa)
if not _ba then
ad.header="Reactive evaluation error"ad.error("Invalid expression: "..aba)return
function()return nil end end;return _ba end
local function a_a(aaa,baa)
for caa in aaa:gmatch("([%w_]+)%.")do
if not cd[caa]then
if caa=="self"then elseif caa=="parent"then
if not baa.parent then
ad.header="Reactive evaluation error"ad.error("No parent element available")return false end else
if(tonumber(caa)==nil)then local daa=baa.parent:getChild(caa)if not daa then
ad.header="Reactive evaluation error"
ad.error("Referenced element not found: "..caa)return false end end end end end;return true end;local b_a=setmetatable({},{__mode="k"})
local c_a=setmetatable({},{__mode="k",__index=function(aaa,baa)aaa[baa]={}return
aaa[baa]end})
local function d_a(aaa,baa,caa)
if c_a[aaa][caa]then for _ba,aba in ipairs(c_a[aaa][caa])do
aba.target:removeObserver(aba.property,aba.callback)end end;local daa={}
for _ba,aba in baa:gmatch("([%w_]+)%.([%w_]+)")do
if not cd[_ba]then local bba;if _ba=="self"then bba=aaa elseif _ba==
"parent"then bba=aaa.parent else
bba=aaa:getBaseFrame():getChild(_ba)end;if bba then
local cba={target=bba,property=aba,callback=function()
aaa:updateRender()end}bba:observe(aba,cba.callback)
table.insert(daa,cba)end end end;c_a[aaa][caa]=daa end
bd.addSetterHook(function(aaa,baa,caa,daa)
if type(caa)=="string"and caa:match("^{.+}$")then
local _ba=caa:gsub("^{(.+)}$","%1")if not a_a(_ba,aaa)then return daa.default end
d_a(aaa,_ba,baa)if not b_a[aaa]then b_a[aaa]={}end;if not b_a[aaa][caa]then
local aba=__a(caa,aaa,baa)b_a[aaa][caa]=aba end
return
function(aba)
local bba,cba=pcall(b_a[aaa][caa])
if not bba then ad.header="Reactive evaluation error"if type(cba)=="string"then ad.error(
"Error evaluating expression: "..cba)else
ad.error("Error evaluating expression")end
return daa.default end;return cba end end end)local _aa={}
_aa.hooks={destroy=function(aaa)
if c_a[aaa]then
for baa,caa in pairs(c_a[aaa])do for daa,_ba in ipairs(caa)do
_ba.target:removeObserver(_ba.property,_ba.callback)end end;c_a[aaa]=nil end end}return{BaseElement=_aa}end
_b["plugins/theme.lua"]=function(...)local ad=require("errorManager")
local bd={default={background=colors.lightGray,foreground=colors.black},BaseFrame={background=colors.white,foreground=colors.black,Frame={background=colors.black,names={basaltDebugLogClose={background=colors.blue,foreground=colors.white}}},Button={background="{self.clicked and colors.black or colors.cyan}",foreground="{self.clicked and colors.cyan or colors.black}"},names={basaltDebugLog={background=colors.red,foreground=colors.white},test={background="{self.clicked and colors.black or colors.green}",foreground="{self.clicked and colors.green or colors.black}"}}}}local cd={default=bd}local dd="default"
local __a={hooks={postInit={pre=function(aaa)if aaa._postInitialized then return aaa end
aaa:applyTheme()end}}}
function __a.____getElementPath(aaa,baa)
if baa then
table.insert(baa,1,aaa._values.type)else baa={aaa._values.type}end;local caa=aaa.parent
if caa then return caa.____getElementPath(caa,baa)else return baa end end
local function a_a(aaa,baa)local caa=aaa
for i=1,#baa do local daa=false;local _ba=baa[i]for aba,bba in ipairs(_ba)do if caa[bba]then caa=caa[bba]daa=true
break end end
if not daa then return nil end end;return caa end
local function b_a(aaa,baa)local caa={}
if aaa.default then for daa,_ba in pairs(aaa.default)do
if type(_ba)~="table"then caa[daa]=_ba end end;if aaa.default[baa]then
for daa,_ba in
pairs(aaa.default[baa])do if type(_ba)~="table"then caa[daa]=_ba end end end end;return caa end
local function c_a(aaa,baa,caa,daa,_ba)
if
baa.default and baa.default.names and baa.default.names[daa]then for aba,bba in pairs(baa.default.names[daa])do if type(bba)~="table"then
aaa[aba]=bba end end end
if

baa.default and baa.default[caa]and baa.default[caa].names and baa.default[caa].names[daa]then
for aba,bba in pairs(baa.default[caa].names[daa])do if
type(bba)~="table"then aaa[aba]=bba end end end;if _ba and _ba.names and _ba.names[daa]then
for aba,bba in
pairs(_ba.names[daa])do if type(bba)~="table"then aaa[aba]=bba end end end end
local function d_a(aaa,baa,caa,daa)local _ba={}local aba=a_a(aaa,baa)
if aba then for bba,cba in pairs(aba)do
if type(cba)~="table"then _ba[bba]=cba end end end;if next(_ba)==nil then _ba=b_a(aaa,caa)end
c_a(_ba,aaa,caa,daa,aba)return _ba end
function __a:applyTheme(aaa)local baa=self:getTheme()
if(baa~=nil)then
for caa,daa in pairs(baa)do
local _ba=self._properties[caa]
if(_ba)then
if( (_ba.type)=="color")then if(type(daa)=="string")then if(colors[daa])then
daa=colors[daa]end end end;self.set(caa,daa)end end end
if(aaa~=false)then
if(self:isType("Container"))then local caa=self.get("children")
for daa,_ba in
ipairs(caa)do if(_ba and _ba.applyTheme)then _ba:applyTheme()end end end end;return self end
function __a:getTheme()local aaa=self:____getElementPath()
local baa=self.get("type")local caa=self.get("name")return d_a(cd[dd],aaa,baa,caa)end;local _aa={}function _aa.setTheme(aaa)cd.default=aaa end
function _aa.getTheme()return cd.default end
function _aa.loadTheme(aaa)local baa=fs.open(aaa,"r")
if baa then local caa=baa.readAll()
baa.close()cd.default=textutils.unserializeJSON(caa)
if not cd.default then ad.error(
"Failed to load theme from "..aaa)end else
ad.error("Could not open theme file: "..aaa)end end;return{BaseElement=__a,API=_aa}end
_b["plugins/xml.lua"]=function(...)local ad=require("errorManager")
local bd=require("log")
local cd={new=function(aaa)
return
{tag=aaa,value=nil,attributes={},children={},addChild=function(baa,caa)table.insert(baa.children,caa)end,addAttribute=function(baa,caa,daa)
baa.attributes[caa]=daa end}end}
local dd=function(aaa,baa)
local caa,daa=string.gsub(baa,"(%w+)=([\"'])(.-)%2",function(bba,cba,dba)
aaa:addAttribute(bba,"\""..dba.."\"")end)
local _ba,aba=string.gsub(baa,"(%w+)={(.-)}",function(bba,cba)aaa:addAttribute(bba,cba)end)end
local __a={parseText=function(aaa)local baa={}local caa=cd.new()table.insert(baa,caa)local daa,_ba,aba,bba,cba
local dba,_ca=1,1
while true do
daa,_ca,_ba,aba,bba,cba=string.find(aaa,"<(%/?)([%w_:]+)(.-)(%/?)>",dba)if not daa then break end;local aca=string.sub(aaa,dba,daa-1)if not
string.find(aca,"^%s*$")then local bca=(caa.value or"")..aca
baa[#baa].value=bca end
if cba=="/"then local bca=cd.new(aba)
dd(bca,bba)caa:addChild(bca)elseif _ba==""then local bca=cd.new(aba)dd(bca,bba)
table.insert(baa,bca)caa=bca else local bca=table.remove(baa)caa=baa[#baa]
if#baa<1 then ad.error(
"XMLParser: nothing to close with "..aba)end;if bca.tag~=aba then
ad.error("XMLParser: trying to close "..bca.tag.." with "..aba)end;caa:addChild(bca)end;dba=_ca+1 end;if#baa>1 then
error("XMLParser: unclosed "..baa[#baa].tag)end;return caa.children end}
local function a_a(aaa)local baa={}local caa=1
while true do local daa,_ba,aba=aaa:find("%${([^}]+)}",caa)
if not daa then break end
table.insert(baa,{start=daa,ending=_ba,expression=aba,raw=aaa:sub(daa,_ba)})caa=_ba+1 end;return baa end
local function b_a(aaa,baa)if type(aaa)~="string"then return aaa end
if aaa:sub(1,1)=="\""and aaa:sub(
-1)=="\""then aaa=aaa:sub(2,-2)end;local caa=a_a(aaa)
for daa,_ba in ipairs(caa)do local aba=_ba.expression;local bba=_ba.start-1;local cba=
_ba.ending+1;if baa[aba]then aaa=aaa:sub(1,bba)..
tostring(baa[aba])..aaa:sub(cba)else
ad.error("XMLParser: variable '"..aba..
"' not found in scope")end end
if aaa:match("^%s*<!%[CDATA%[.*%]%]>%s*$")then
local daa=aaa:match("<!%[CDATA%[(.*)%]%]>")local _ba=_ENV;for aba,bba in pairs(baa)do _ba[aba]=bba end;return
load("return "..daa,nil,"bt",_ba)()end
if aaa=="true"then return true elseif aaa=="false"then return false elseif colors[aaa]then return colors[aaa]elseif
tonumber(aaa)then return tonumber(aaa)else return aaa end end
local function c_a(aaa,baa)local caa={}
for daa,_ba in pairs(aaa.children)do
if
_ba.tag=="item"or _ba.tag=="entry"then local aba={}
for bba,cba in pairs(_ba.attributes)do aba[bba]=b_a(cba,baa)end;for bba,cba in pairs(_ba.children)do
if cba.value then aba[cba.tag]=b_a(cba.value,baa)elseif#
cba.children>0 then aba[cba.tag]=c_a(cba)end end
table.insert(caa,aba)else if _ba.value then caa[_ba.tag]=b_a(_ba.value,baa)elseif#_ba.children>0 then
caa[_ba.tag]=c_a(_ba)end end end;return caa end;local d_a={}function d_a.setup(aaa)
aaa.defineProperty(aaa,"customXML",{default={attributes={},children={}},type="table"})end
function d_a:fromXML(aaa,baa)
if(aaa.attributes)then
for caa,daa in
pairs(aaa.attributes)do
if(self._properties[caa])then self.set(caa,b_a(daa,baa))elseif self[caa]then
if(
caa:sub(1,2)=="on")then local _ba=daa:gsub("\"","")
if(baa[_ba])then if
(type(baa[_ba])~="function")then
ad.error("XMLParser: variable '".._ba..
"' is not a function for element '"..self:getType().."' "..caa)end
self[caa](self,baa[_ba])else
ad.error("XMLParser: variable '".._ba.."' not found in scope")end else
ad.error("XMLParser: property '"..caa..
"' not found in element '"..self:getType().."'")end else local _ba=self.get("customXML")
_ba.attributes[caa]=b_a(daa,baa)end end end
if(aaa.children)then
for caa,daa in pairs(aaa.children)do
if(self._properties[daa.tag])then
if(
self._properties[daa.tag].type=="table")then
self.set(daa.tag,c_a(daa,baa))else self.set(daa.tag,b_a(daa.value,baa))end else local _ba={}
if(daa.children)then
for aba,bba in pairs(daa.children)do
if(bba.tag=="param")then
table.insert(_ba,b_a(bba.value,baa))elseif(bba.tag=="table")then table.insert(_ba,c_a(bba,baa))end end end
if(self[daa.tag])then
if(#_ba>0)then
self[daa.tag](self,table.unpack(_ba))elseif(daa.value)then
self[daa.tag](self,b_a(daa.value,baa))else self[daa.tag](self)end else local aba=self.get("customXML")
daa.value=b_a(daa.value,baa)aba.children[daa.tag]=daa end end end end;return self end;local _aa={}
function _aa:loadXML(aaa,baa)baa=baa or{}local caa=__a.parseText(aaa)
self:fromXML(caa,baa)
if(caa)then
for daa,_ba in ipairs(caa)do
local aba=_ba.tag:sub(1,1):upper().._ba.tag:sub(2)if self["add"..aba]then local bba=self["add"..aba](self)
bba:fromXML(_ba,baa)end end end;return self end
function _aa:fromXML(aaa,baa)d_a.fromXML(self,aaa,baa)
if(aaa.children)then
for caa,daa in ipairs(aaa.children)do local _ba=
daa.tag:sub(1,1):upper()..daa.tag:sub(2)if
self["add".._ba]then local aba=self["add".._ba](self)
aba:fromXML(daa,baa)end end end;return self end;return{API=__a,Container=_aa,BaseElement=d_a}end
_b["plugins/animation.lua"]=function(...)local cb={}
local db={linear=function(cc)return cc end,easeInQuad=function(cc)return cc*cc end,easeOutQuad=function(cc)return
1 - (1 -cc)* (1 -cc)end,easeInOutQuad=function(cc)if cc<0.5 then return
2 *cc*cc end;return 1 - (-2 *cc+2)^2 /2 end}local _c={}_c.__index=_c
function _c.new(cc,dc,_d,ad,bd)local cd=setmetatable({},_c)cd.element=cc
cd.type=dc;cd.args=_d;cd.duration=ad or 1;cd.startTime=0;cd.isPaused=false
cd.handlers=cb[dc]cd.easing=bd;return cd end;function _c:start()self.startTime=os.epoch("local")/1000;if
self.handlers.start then self.handlers.start(self)end
return self end
function _c:update(cc)local dc=math.min(1,
cc/self.duration)
local _d=db[self.easing](dc)return self.handlers.update(self,_d)end;function _c:complete()if self.handlers.complete then
self.handlers.complete(self)end end
local ac={}ac.__index=ac
function ac.registerAnimation(cc,dc)cb[cc]=dc
ac[cc]=function(_d,...)local ad={...}local bd="linear"
if(
type(ad[#ad])=="string")then bd=table.remove(ad,#ad)end;local cd=table.remove(ad,#ad)
return _d:addAnimation(cc,ad,cd,bd)end end;function ac.registerEasing(cc,dc)db[cc]=dc end
function ac.new(cc)local dc={}dc.element=cc
dc.sequences={{}}dc.sequenceCallbacks={}dc.currentSequence=1;dc.timer=nil
setmetatable(dc,ac)return dc end
function ac:sequence()table.insert(self.sequences,{})self.currentSequence=#
self.sequences;self.sequenceCallbacks[self.currentSequence]={start=nil,update=nil,complete=
nil}return self end
function ac:onStart(cc)
if
not self.sequenceCallbacks[self.currentSequence]then self.sequenceCallbacks[self.currentSequence]={}end
self.sequenceCallbacks[self.currentSequence].start=cc;return self end
function ac:onUpdate(cc)
if
not self.sequenceCallbacks[self.currentSequence]then self.sequenceCallbacks[self.currentSequence]={}end
self.sequenceCallbacks[self.currentSequence].update=cc;return self end
function ac:onComplete(cc)
if
not self.sequenceCallbacks[self.currentSequence]then self.sequenceCallbacks[self.currentSequence]={}end
self.sequenceCallbacks[self.currentSequence].complete=cc;return self end
function ac:addAnimation(cc,dc,_d,ad)local bd=_c.new(self.element,cc,dc,_d,ad)
table.insert(self.sequences[self.currentSequence],bd)return self end
function ac:start()self.currentSequence=1;self.timer=nil
if
(self.sequenceCallbacks[self.currentSequence])then if(self.sequenceCallbacks[self.currentSequence].start)then
self.sequenceCallbacks[self.currentSequence].start(self.element)end end
if
#self.sequences[self.currentSequence]>0 then self.timer=os.startTimer(0.05)for cc,dc in
ipairs(self.sequences[self.currentSequence])do dc:start()end end;return self end
function ac:event(cc,dc)
if cc=="timer"and dc==self.timer then
local _d=os.epoch("local")/1000;local ad=true;local bd={}
local cd=self.sequenceCallbacks[self.currentSequence]
for dd,__a in ipairs(self.sequences[self.currentSequence])do
local a_a=_d-__a.startTime;local b_a=a_a/__a.duration;local c_a=__a:update(a_a)if cd and cd.update then
cd.update(self.element,b_a)end;if not c_a then table.insert(bd,__a)ad=false else
__a:complete()end end
if ad then
if cd and cd.complete then cd.complete(self.element)end
if self.currentSequence<#self.sequences then
self.currentSequence=self.currentSequence+1;bd={}
local dd=self.sequenceCallbacks[self.currentSequence]if dd and dd.start then dd.start(self.element)end
for __a,a_a in
ipairs(self.sequences[self.currentSequence])do a_a:start()table.insert(bd,a_a)end end end;if#bd>0 then self.timer=os.startTimer(0.05)end
return true end end
ac.registerAnimation("move",{start=function(cc)cc.startX=cc.element.get("x")
cc.startY=cc.element.get("y")end,update=function(cc,dc)local _d=cc.startX+
(cc.args[1]-cc.startX)*dc;local ad=cc.startY+
(cc.args[2]-cc.startY)*dc
cc.element.set("x",math.floor(_d))cc.element.set("y",math.floor(ad))return dc>=1 end,complete=function(cc)
cc.element.set("x",cc.args[1])cc.element.set("y",cc.args[2])end})
ac.registerAnimation("resize",{start=function(cc)cc.startW=cc.element.get("width")
cc.startH=cc.element.get("height")end,update=function(cc,dc)local _d=cc.startW+
(cc.args[1]-cc.startW)*dc;local ad=cc.startH+
(cc.args[2]-cc.startH)*dc
cc.element.set("width",math.floor(_d))cc.element.set("height",math.floor(ad))
return dc>=1 end,complete=function(cc)
cc.element.set("width",cc.args[1])cc.element.set("height",cc.args[2])end})
ac.registerAnimation("moveOffset",{start=function(cc)cc.startX=cc.element.get("offsetX")
cc.startY=cc.element.get("offsetY")end,update=function(cc,dc)local _d=cc.startX+ (cc.args[1]-cc.startX)*
dc;local ad=cc.startY+ (cc.args[2]-
cc.startY)*dc
cc.element.set("offsetX",math.floor(_d))cc.element.set("offsetY",math.floor(ad))return
dc>=1 end,complete=function(cc)
cc.element.set("offsetX",cc.args[1])cc.element.set("offsetY",cc.args[2])end})
ac.registerAnimation("number",{start=function(cc)
cc.startValue=cc.element.get(cc.args[1])cc.targetValue=cc.args[2]end,update=function(cc,dc)
local _d=
cc.startValue+ (cc.targetValue-cc.startValue)*dc
cc.element.set(cc.args[1],math.floor(_d))return dc>=1 end,complete=function(cc)
cc.element.set(cc.args[1],cc.targetValue)end})
ac.registerAnimation("entries",{start=function(cc)
cc.startColor=cc.element.get(cc.args[1])cc.colorList=cc.args[2]end,update=function(cc,dc)
local _d=cc.colorList;local ad=math.floor(#_d*dc)+1;if ad>#_d then ad=#_d end
cc.element.set(cc.args[1],_d[ad])end,complete=function(cc)
cc.element.set(cc.args[1],cc.colorList[
#cc.colorList])end})
ac.registerAnimation("morphText",{start=function(cc)local dc=cc.element.get(cc.args[1])
local _d=cc.args[2]local ad=math.max(#dc,#_d)
local bd=string.rep(" ",math.floor(ad-#dc)/2)cc.startText=bd..dc..bd
cc.targetText=_d..string.rep(" ",ad-#_d)cc.length=ad end,update=function(cc,dc)
local _d=""
for i=1,cc.length do local ad=cc.startText:sub(i,i)
local bd=cc.targetText:sub(i,i)
if dc<0.5 then
_d=_d.. (math.random()>dc*2 and ad or" ")else _d=_d..
(math.random()> (dc-0.5)*2 and" "or bd)end end;cc.element.set(cc.args[1],_d)return dc>=1 end,complete=function(cc)
cc.element.set(cc.args[1],cc.targetText:gsub("%s+$",""))end})
ac.registerAnimation("typewrite",{start=function(cc)cc.targetText=cc.args[2]
cc.element.set(cc.args[1],"")end,update=function(cc,dc)
local _d=math.floor(#cc.targetText*dc)
cc.element.set(cc.args[1],cc.targetText:sub(1,_d))return dc>=1 end})
ac.registerAnimation("fadeText",{start=function(cc)cc.chars={}for i=1,#cc.args[2]do
cc.chars[i]={char=cc.args[2]:sub(i,i),visible=false}end end,update=function(cc,dc)
local _d=""for ad,bd in ipairs(cc.chars)do
if math.random()<dc then bd.visible=true end
_d=_d.. (bd.visible and bd.char or" ")end
cc.element.set(cc.args[1],_d)return dc>=1 end})
ac.registerAnimation("scrollText",{start=function(cc)cc.width=cc.element.get("width")
cc.targetText=cc.args[2]cc.element.set(cc.args[1],"")end,update=function(cc,dc)local _d=math.floor(
cc.width* (1 -dc))
local ad=string.rep(" ",_d)
cc.element.set(cc.args[1],ad..cc.targetText)return dc>=1 end})local bc={hooks={}}
function bc.hooks.handleEvent(cc,dc,...)if dc=="timer"then local _d=cc.get("animation")if _d then
_d:event(dc,...)end end end
function bc.setup(cc)
cc.defineProperty(cc,"animation",{default=nil,type="table"})cc.defineEvent(cc,"timer")end
function bc:animate()local cc=ac.new(self)self.set("animation",cc)return cc end;return{VisualElement=bc}end
_b["plugins/benchmark.lua"]=function(...)local _c=require("log")
local ac=setmetatable({},{__mode="k"})local function bc()return{methods={}}end
local function cc(bd,cd)local dd=bd[cd]
if not ac[bd]then ac[bd]=bc()end
if not ac[bd].methods[cd]then
ac[bd].methods[cd]={calls=0,totalTime=0,minTime=math.huge,maxTime=0,lastTime=0,startTime=0,path={},methodName=cd,originalMethod=dd}end
bd[cd]=function(__a,...)__a:startProfile(cd)local a_a=dd(__a,...)
__a:endProfile(cd)return a_a end end;local dc={}
function dc:startProfile(bd)local cd=ac[self]if not cd then cd=bc()ac[self]=cd end;if not
cd.methods[bd]then
cd.methods[bd]={calls=0,totalTime=0,minTime=math.huge,maxTime=0,lastTime=0,startTime=0,path={},methodName=bd}end
local dd=cd.methods[bd]dd.startTime=os.clock()*1000;dd.path={}local __a=self;while __a do
table.insert(dd.path,1,
__a.get("name")or __a.get("id"))__a=__a.parent end;return self end
function dc:endProfile(bd)local cd=ac[self]
if not cd or not cd.methods[bd]then return self end;local dd=cd.methods[bd]local __a=os.clock()*1000
local a_a=__a-dd.startTime;dd.calls=dd.calls+1;dd.totalTime=dd.totalTime+a_a
dd.minTime=math.min(dd.minTime,a_a)dd.maxTime=math.max(dd.maxTime,a_a)dd.lastTime=a_a;return self end
function dc:benchmark(bd)if not self[bd]then
_c.error("Method "..bd.." does not exist")return self end;ac[self]=bc()
ac[self].methodName=bd;ac[self].isRunning=true;cc(self,bd)return self end
function dc:logBenchmark(bd)local cd=ac[self]
if not cd or not cd.methods[bd]then return self end;local dd=cd.methods[bd]
if dd then local __a=
dd.calls>0 and(dd.totalTime/dd.calls)or 0
_c.info(string.format(
"Benchmark results for %s.%s: "..
"Path: %s ".."Calls: %d "..
"Average time: %.2fms ".."Min time: %.2fms ".."Max time: %.2fms "..
"Last time: %.2fms ".."Total time: %.2fms",table.concat(dd.path,"."),dd.methodName,table.concat(dd.path,"/"),dd.calls,__a,
dd.minTime~=math.huge and dd.minTime or 0,dd.maxTime,dd.lastTime,dd.totalTime))end;return self end
function dc:stopBenchmark(bd)local cd=ac[self]
if not cd or not cd.methods[bd]then return self end;local dd=cd.methods[bd]if dd and dd.originalMethod then
self[bd]=dd.originalMethod end;cd.methods[bd]=nil;if
not next(cd.methods)then ac[self]=nil end;return self end
function dc:getBenchmarkStats(bd)local cd=ac[self]
if not cd or not cd.methods[bd]then return nil end;local dd=cd.methods[bd]return
{averageTime=dd.totalTime/dd.calls,totalTime=dd.totalTime,calls=dd.calls,minTime=dd.minTime,maxTime=dd.maxTime,lastTime=dd.lastTime}end;local _d={}
function _d:benchmarkContainer(bd)self:benchmark(bd)
for cd,dd in
pairs(self.get("children"))do dd:benchmark(bd)if dd:isType("Container")then
dd:benchmarkContainer(bd)end end;return self end
function _d:logContainerBenchmarks(bd,cd)cd=cd or 0;local dd=string.rep("  ",cd)local __a=0;local a_a={}
for c_a,d_a in
pairs(self.get("children"))do local _aa=ac[d_a]
if _aa and _aa.methods[bd]then local aaa=_aa.methods[bd]__a=__a+
aaa.totalTime
table.insert(a_a,{element=d_a,type=d_a.get("type"),calls=aaa.calls,totalTime=aaa.totalTime,avgTime=aaa.totalTime/aaa.calls})end end;local b_a=ac[self]
if b_a and b_a.methods[bd]then local c_a=b_a.methods[bd]local d_a=
c_a.totalTime-__a;local _aa=d_a/c_a.calls
_c.info(string.format(
"%sBenchmark %s (%s): ".."%.2fms/call (Self: %.2fms/call) ".."[Total: %dms, Calls: %d]",dd,self.get("type"),bd,
c_a.totalTime/c_a.calls,_aa,c_a.totalTime,c_a.calls))
if#a_a>0 then
for aaa,baa in ipairs(a_a)do
if baa.element:isType("Container")then baa.element:logContainerBenchmarks(bd,
cd+1)else
_c.info(string.format("%s> %s: %.2fms/call [Total: %dms, Calls: %d]",
dd.." ",baa.type,baa.avgTime,baa.totalTime,baa.calls))end end end end;return self end
function _d:stopContainerBenchmark(bd)
for cd,dd in pairs(self.get("children"))do if dd:isType("Container")then
dd:stopContainerBenchmark(bd)else dd:stopBenchmark(bd)end end;self:stopBenchmark(bd)return self end;local ad={}
function ad.start(bd,cd)cd=cd or{}local dd=bc()dd.name=bd
dd.startTime=os.clock()*1000;dd.custom=true;dd.calls=0;dd.totalTime=0;dd.minTime=math.huge;dd.maxTime=0
dd.lastTime=0;ac[bd]=dd end
function ad.stop(bd)local cd=ac[bd]if not cd or not cd.custom then return end;local dd=
os.clock()*1000;local __a=dd-cd.startTime
cd.calls=cd.calls+1;cd.totalTime=cd.totalTime+__a
cd.minTime=math.min(cd.minTime,__a)cd.maxTime=math.max(cd.maxTime,__a)cd.lastTime=__a
_c.info(string.format(
"Custom Benchmark '%s': ".."Calls: %d "..
"Average time: %.2fms ".."Min time: %.2fms ".."Max time: %.2fms "..
"Last time: %.2fms ".."Total time: %.2fms",bd,cd.calls,
cd.totalTime/cd.calls,cd.minTime,cd.maxTime,cd.lastTime,cd.totalTime))end
function ad.getStats(bd)local cd=ac[bd]if not cd then return nil end;return
{averageTime=cd.totalTime/cd.calls,totalTime=cd.totalTime,calls=cd.calls,minTime=cd.minTime,maxTime=cd.maxTime,lastTime=cd.lastTime}end;function ad.clear(bd)ac[bd]=nil end;function ad.clearAll()for bd,cd in pairs(ac)do
if cd.custom then ac[bd]=nil end end end;return
{BaseElement=dc,Container=_d,API=ad}end
_b["plugins/state.lua"]=function(...)local cb=require("propertySystem")
local db=require("errorManager")local _c={}function _c.setup(bc)
bc.defineProperty(bc,"states",{default={},type="table"})
bc.defineProperty(bc,"stateObserver",{default={},type="table"})end
function _c:initializeState(bc,cc,dc,_d)
local ad=self.get("states")if ad[bc]then
db.error("State '"..bc.."' already exists")return self end;local bd=_d or"states/"..
self.get("name")..".state"local cd={}
if dc and
fs.exists(bd)then local dd=fs.open(bd,"r")cd=
textutils.unserialize(dd.readAll())or{}dd.close()end;ad[bc]={value=dc and cd[bc]or cc,persist=dc}
return self end;local ac={}
function ac:setState(bc,cc)local dc=self:getBaseFrame()
local _d=dc.get("states")local ad=dc.get("stateObserver")
if not _d[bc]then db.error("State '"..
bc.."' not initialized")end
if _d[bc].persist then
local bd="states/"..dc.get("name")..".state"local cd={}
if fs.exists(bd)then local a_a=fs.open(bd,"r")cd=
textutils.unserialize(a_a.readAll())or{}a_a.close()end;cd[bc]=cc;local dd=fs.getDir(bd)if not fs.exists(dd)then
fs.makeDir(dd)end;local __a=fs.open(bd,"w")
__a.write(textutils.serialize(cd))__a.close()end;_d[bc].value=cc
if ad[bc]then for bd,cd in ipairs(ad[bc])do cd(bc,cc)end end;for bd,cd in pairs(_d)do
if cd.computed then cd.value=cd.computeFn(self)if ad[bd]then for dd,__a in ipairs(ad[bd])do
__a(bd,cd.value)end end end end;return
self end
function ac:getState(bc)local cc=self:getBaseFrame()local dc=cc.get("states")if
not dc[bc]then
db.error("State '"..bc.."' not initialized")end;if dc[bc].computed then
return dc[bc].computeFn(self)end;return dc[bc].value end
function ac:onStateChange(bc,cc)local dc=self:getBaseFrame()
local _d=dc.get("states")[bc]if not _d then
db.error("Cannot observe state '"..bc.."': State not initialized")return self end
local ad=dc.get("stateObserver")if not ad[bc]then ad[bc]={}end;table.insert(ad[bc],cc)
return self end
function ac:removeStateChange(bc,cc)local dc=self:getBaseFrame()
local _d=dc.get("stateObserver")
if _d[bc]then for ad,bd in ipairs(_d[bc])do
if bd==cc then table.remove(_d[bc],ad)break end end end;return self end
function ac:computed(bc,cc)local dc=self:getBaseFrame()local _d=dc.get("states")if _d[bc]then
db.error(
"Computed state '"..bc.."' already exists")return self end
_d[bc]={computeFn=cc,value=cc(self),computed=true}return self end
function ac:bind(bc,cc)cc=cc or bc;local dc=self:getBaseFrame()local _d=false
if
self.get(bc)~=nil then self.set(bc,dc:getState(cc))end
self:onChange(bc,function(ad,bd)if _d then return end;_d=true;ad:setState(cc,bd)_d=false end)
self:onStateChange(cc,function(ad,bd)if _d then return end;_d=true;if self.get(bc)~=nil then
self.set(bc,bd)end;_d=false end)return self end;return{BaseElement=ac,BaseFrame=_c}end
_b["main.lua"]=function(...)local cb=require("elementManager")
local db=require("errorManager")local _c=require("propertySystem")
local ac=require("libraries/expect")local bc={}bc.traceback=true;bc._events={}bc._schedule={}bc._eventQueue={}
bc._plugins={}bc.isRunning=false;bc.LOGGER=require("log")
if(ba)then
bc.path=fs.getDir(shell.getRunningProgram())else bc.path=fs.getDir(select(2,...))end;local cc=nil;local dc=nil;local _d={}local aca=type;local bca={}local cca=10;local dca=0;local _da=false
local function ada()
if(_da)then return end;dca=os.startTimer(0.2)_da=true end
local function bda(c_b)for _=1,c_b do local d_b=bca[1]if(d_b)then d_b:create()end
table.remove(bca,1)end end;local function cda(c_b,d_b)
if(c_b=="timer")then if(d_b==dca)then bda(cca)_da=false;dca=0;if(#bca>0)then ada()end
return true end end end
function bc.create(c_b,d_b,_ab,aab)if(
aca(d_b)=="string")then d_b={name=d_b}end
if(d_b==nil)then d_b={name=c_b}end;local bab=cb.getElement(c_b)
if(_ab)then
local cab=_c.blueprint(bab,d_b,bc,aab)table.insert(bca,cab)ada()return cab else local cab=bab.new()
cab:init(d_b,bc)return cab end end
function bc.createFrame()local c_b=bc.create("BaseFrame")c_b:postInit()
if(cc==nil)then
cc=tostring(term.current())bc.setActiveFrame(c_b,true)end;return c_b end;function bc.getElementManager()return cb end;function bc.getErrorManager()return db end;function bc.getMainFrame()
local c_b=tostring(term.current())if(_d[c_b]==nil)then cc=c_b;bc.createFrame()end
return _d[c_b]end
function bc.setActiveFrame(c_b,d_b)
local _ab=c_b:getTerm()if(d_b==nil)then d_b=true end;if(_ab~=nil)then
_d[tostring(_ab)]=d_b and c_b or nil;c_b:updateRender()end end;function bc.getActiveFrame(c_b)if(c_b==nil)then c_b=term.current()end;return
_d[tostring(c_b)]end
function bc.setFocus(c_b)if(dc==c_b)then
return end
if(dc~=nil)then dc:dispatchEvent("blur")end;dc=c_b;if(dc~=nil)then dc:dispatchEvent("focus")end end;function bc.getFocus()return dc end
function bc.schedule(c_b)ac(1,c_b,"function")
local d_b=coroutine.create(c_b)local _ab,aab=coroutine.resume(d_b)
if(_ab)then
table.insert(bc._schedule,{coroutine=d_b,filter=aab})else db.header="Basalt Schedule Error"db.error(aab)end;return d_b end
function bc.removeSchedule(c_b)
for d_b,_ab in ipairs(bc._schedule)do if(_ab.coroutine==c_b)then
table.remove(bc._schedule,d_b)return true end end;return false end
local dda={mouse_click=true,mouse_up=true,mouse_scroll=true,mouse_drag=true}local __b={key=true,key_up=true,char=true}
local function a_b(c_b,...)if(c_b=="terminate")then bc.stop()
return end;if cda(c_b,...)then return end;local d_b={...}
local function _ab()
if(dda[c_b])then if
_d[cc]then
_d[cc]:dispatchEvent(c_b,table.unpack(d_b))end elseif(__b[c_b])then if(dc~=nil)then
dc:dispatchEvent(c_b,table.unpack(d_b))end else for dab,_bb in pairs(_d)do
_bb:dispatchEvent(c_b,table.unpack(d_b))end end end
for dab,_bb in pairs(bc._eventQueue)do
if
coroutine.status(_bb.coroutine)=="suspended"then
if _bb.filter==c_b or _bb.filter==nil then _bb.filter=nil
local abb,bbb=coroutine.resume(_bb.coroutine,c_b,...)
if not abb then db.header="Basalt Event Error"db.error(bbb)end;_bb.filter=bbb end end;if coroutine.status(_bb.coroutine)=="dead"then
table.remove(bc._eventQueue,dab)end end;local aab={coroutine=coroutine.create(_ab),filter=c_b}
local bab,cab=coroutine.resume(aab.coroutine,c_b,...)
if(not bab)then db.header="Basalt Event Error"db.error(cab)end;if(cab~=nil)then aab.filter=cab end
table.insert(bc._eventQueue,aab)
for dab,_bb in ipairs(bc._schedule)do
if
coroutine.status(_bb.coroutine)=="suspended"then
if c_b==_bb.filter or _bb.filter==nil then _bb.filter=nil
local abb,bbb=coroutine.resume(_bb.coroutine,c_b,...)
if(not abb)then db.header="Basalt Schedule Error"db.error(bbb)end;_bb.filter=bbb end end;if(coroutine.status(_bb.coroutine)=="dead")then
bc.removeSchedule(_bb.coroutine)end end;if bc._events[c_b]then
for dab,_bb in ipairs(bc._events[c_b])do _bb(...)end end end;local function b_b()
for c_b,d_b in pairs(_d)do d_b:render()d_b:postRender()end end;function bc.render()b_b()end
function bc.update(...)local c_b=function(...)
bc.isRunning=true;a_b(...)b_b()end
local d_b,_ab=pcall(c_b,...)
if not(d_b)then db.header="Basalt Runtime Error"db.error(_ab)end;bc.isRunning=false end;function bc.stop()bc.isRunning=false;term.clear()
term.setCursorPos(1,1)end
function bc.run(c_b)if(bc.isRunning)then
db.error("Basalt is already running")end
if(c_b==nil)then bc.isRunning=true else bc.isRunning=c_b end
local function d_b()b_b()while bc.isRunning do a_b(os.pullEventRaw())
if(bc.isRunning)then b_b()end end end
while bc.isRunning do local _ab,aab=pcall(d_b)if not(_ab)then db.header="Basalt Runtime Error"
db.error(aab)end end end;function bc.getElementClass(c_b)return cb.getElement(c_b)end;function bc.getAPI(c_b)return
cb.getAPI(c_b)end;return bc end
_b["render.lua"]=function(...)local cb=require("libraries/colorHex")
local db=require("log")local _c={}_c.__index=_c;local ac=string.sub
function _c.new(bc)local cc=setmetatable({},_c)
cc.terminal=bc;cc.width,cc.height=bc.getSize()
cc.buffer={text={},fg={},bg={},dirtyRects={}}
for y=1,cc.height do cc.buffer.text[y]=string.rep(" ",cc.width)
cc.buffer.fg[y]=string.rep("0",cc.width)cc.buffer.bg[y]=string.rep("f",cc.width)end;return cc end;function _c:addDirtyRect(bc,cc,dc,_d)
table.insert(self.buffer.dirtyRects,{x=bc,y=cc,width=dc,height=_d})return self end
function _c:blit(bc,cc,dc,_d,ad)if
cc<1 or cc>self.height then return self end;if(#dc~=#_d or
#dc~=#ad)then
error("Text, fg, and bg must be the same length")end
self.buffer.text[cc]=ac(self.buffer.text[cc]:sub(1,
bc-1)..dc..
self.buffer.text[cc]:sub(bc+#dc),1,self.width)
self.buffer.fg[cc]=ac(
self.buffer.fg[cc]:sub(1,bc-1).._d..self.buffer.fg[cc]:sub(bc+#_d),1,self.width)
self.buffer.bg[cc]=ac(
self.buffer.bg[cc]:sub(1,bc-1)..ad..self.buffer.bg[cc]:sub(bc+#ad),1,self.width)self:addDirtyRect(bc,cc,#dc,1)return self end
function _c:multiBlit(bc,cc,dc,_d,ad,bd,cd)if cc<1 or cc>self.height then return self end;if(
#ad~=#bd or#ad~=#cd)then
error("Text, fg, and bg must be the same length")end;ad=ad:rep(dc)
bd=bd:rep(dc)cd=cd:rep(dc)
for dy=0,_d-1 do local dd=cc+dy
if dd>=1 and dd<=self.height then
self.buffer.text[dd]=ac(self.buffer.text[dd]:sub(1,
bc-1)..ad..
self.buffer.text[dd]:sub(bc+#ad),1,self.width)
self.buffer.fg[dd]=ac(
self.buffer.fg[dd]:sub(1,bc-1)..bd..self.buffer.fg[dd]:sub(bc+#bd),1,self.width)
self.buffer.bg[dd]=ac(
self.buffer.bg[dd]:sub(1,bc-1)..cd..self.buffer.bg[dd]:sub(bc+#cd),1,self.width)end end;self:addDirtyRect(bc,cc,dc,_d)return self end
function _c:textFg(bc,cc,dc,_d)if cc<1 or cc>self.height then return self end
_d=cb[_d]or"0"_d=_d:rep(#dc)
self.buffer.text[cc]=ac(self.buffer.text[cc]:sub(1,
bc-1)..dc..
self.buffer.text[cc]:sub(bc+#dc),1,self.width)
self.buffer.fg[cc]=ac(
self.buffer.fg[cc]:sub(1,bc-1).._d..self.buffer.fg[cc]:sub(bc+#_d),1,self.width)self:addDirtyRect(bc,cc,#dc,1)return self end
function _c:textBg(bc,cc,dc,_d)if cc<1 or cc>self.height then return self end
_d=cb[_d]or"f"
self.buffer.text[cc]=ac(
self.buffer.text[cc]:sub(1,bc-1)..
dc..self.buffer.text[cc]:sub(bc+#dc),1,self.width)
self.buffer.bg[cc]=ac(
self.buffer.bg[cc]:sub(1,bc-1)..
_d:rep(#dc)..self.buffer.bg[cc]:sub(bc+#dc),1,self.width)self:addDirtyRect(bc,cc,#dc,1)return self end
function _c:text(bc,cc,dc)if cc<1 or cc>self.height then return self end
self.buffer.text[cc]=ac(self.buffer.text[cc]:sub(1,
bc-1)..dc..
self.buffer.text[cc]:sub(bc+#dc),1,self.width)self:addDirtyRect(bc,cc,#dc,1)return self end
function _c:fg(bc,cc,dc)if cc<1 or cc>self.height then return self end
self.buffer.fg[cc]=ac(self.buffer.fg[cc]:sub(1,
bc-1)..dc..
self.buffer.fg[cc]:sub(bc+#dc),1,self.width)self:addDirtyRect(bc,cc,#dc,1)return self end
function _c:bg(bc,cc,dc)if cc<1 or cc>self.height then return self end
self.buffer.bg[cc]=ac(self.buffer.bg[cc]:sub(1,
bc-1)..dc..
self.buffer.bg[cc]:sub(bc+#dc),1,self.width)self:addDirtyRect(bc,cc,#dc,1)return self end
function _c:text(bc,cc,dc)if cc<1 or cc>self.height then return self end
self.buffer.text[cc]=ac(self.buffer.text[cc]:sub(1,
bc-1)..dc..
self.buffer.text[cc]:sub(bc+#dc),1,self.width)self:addDirtyRect(bc,cc,#dc,1)return self end
function _c:fg(bc,cc,dc)if cc<1 or cc>self.height then return self end
self.buffer.fg[cc]=ac(self.buffer.fg[cc]:sub(1,
bc-1)..dc..
self.buffer.fg[cc]:sub(bc+#dc),1,self.width)self:addDirtyRect(bc,cc,#dc,1)return self end
function _c:bg(bc,cc,dc)if cc<1 or cc>self.height then return self end
self.buffer.bg[cc]=ac(self.buffer.bg[cc]:sub(1,
bc-1)..dc..
self.buffer.bg[cc]:sub(bc+#dc),1,self.width)self:addDirtyRect(bc,cc,#dc,1)return self end
function _c:clear(bc)local cc=cb[bc]or"f"
for y=1,self.height do
self.buffer.text[y]=string.rep(" ",self.width)self.buffer.fg[y]=string.rep("0",self.width)
self.buffer.bg[y]=string.rep(cc,self.width)self:addDirtyRect(1,y,self.width,1)end;return self end
function _c:render()local bc={}
for cc,dc in ipairs(self.buffer.dirtyRects)do local _d=false;for ad,bd in ipairs(bc)do
if
self:rectOverlaps(dc,bd)then self:mergeRects(bd,dc)_d=true;break end end;if not _d then
table.insert(bc,dc)end end
for cc,dc in ipairs(bc)do
for y=dc.y,dc.y+dc.height-1 do
if y>=1 and y<=self.height then
self.terminal.setCursorPos(dc.x,y)
self.terminal.blit(self.buffer.text[y]:sub(dc.x,dc.x+dc.width-1),self.buffer.fg[y]:sub(dc.x,
dc.x+dc.width-1),self.buffer.bg[y]:sub(dc.x,
dc.x+dc.width-1))end end end;self.buffer.dirtyRects={}
if self.blink then
self.terminal.setTextColor(self.cursorColor or
colors.white)
self.terminal.setCursorPos(self.xCursor,self.yCursor)self.terminal.setCursorBlink(true)else
self.terminal.setCursorBlink(false)end;return self end
function _c:rectOverlaps(bc,cc)return
not(
bc.x+bc.width<=cc.x or cc.x+cc.width<=bc.x or bc.y+bc.height<=cc.y or
cc.y+cc.height<=bc.y)end
function _c:mergeRects(bc,cc)local dc=math.min(bc.x,cc.x)
local _d=math.min(bc.y,cc.y)
local ad=math.max(bc.x+bc.width,cc.x+cc.width)
local bd=math.max(bc.y+bc.height,cc.y+cc.height)bc.x=dc;bc.y=_d;bc.width=ad-dc;bc.height=bd-_d;return self end
function _c:setCursor(bc,cc,dc,_d)
if _d~=nil then self.terminal.setTextColor(_d)end;self.terminal.setCursorPos(bc,cc)
self.terminal.setCursorBlink(dc)self.xCursor=bc;self.yCursor=cc;self.blink=dc;self.cursorColor=_d
return self end
function _c:clearArea(bc,cc,dc,_d,ad)local bd=cb[ad]or"f"
for dy=0,_d-1 do local cd=cc+dy;if
cd>=1 and cd<=self.height then local dd=string.rep(" ",dc)local __a=string.rep(bd,dc)
self:blit(bc,cd,dd,"0",bd)end end;return self end;function _c:getSize()return self.width,self.height end
function _c:setSize(bc,cc)
self.width=bc;self.height=cc
for y=1,self.height do
self.buffer.text[y]=string.rep(" ",self.width)self.buffer.fg[y]=string.rep("0",self.width)
self.buffer.bg[y]=string.rep("f",self.width)end;return self end;return _c end
_b["libraries/expect.lua"]=function(...)local cb=require("errorManager")
local function db(_c,ac,bc)
local cc=type(ac)if bc=="element"then
if cc=="table"and ac.get("type")~=nil then return true end end
if bc=="color"then
if cc=="number"then return true end;if cc=="string"and colors[ac]then return true end end;if cc~=bc then cb.header="Basalt Type Error"
cb.error(string.format("Bad argument #%d: expected %s, got %s",_c,bc,cc))end;return true end;return db end
_b["libraries/colorHex.lua"]=function(...)local cb={}for i=0,15 do cb[2 ^i]=("%x"):format(i)cb[("%x"):format(i)]=
2 ^i end;return cb end
_b["libraries/utils.lua"]=function(...)local cb,db=math.floor,string.len;local _c={}function _c.getCenteredPosition(ac,bc,cc)
local dc=db(ac)local _d=cb((bc-dc+1)/2 +0.5)
local ad=cb(cc/2 +0.5)return _d,ad end
function _c.deepCopy(ac)if
type(ac)~="table"then return ac end;local bc={}for cc,dc in pairs(ac)do
bc[_c.deepCopy(cc)]=_c.deepCopy(dc)end;return bc end
function _c.copy(ac)local bc={}for cc,dc in pairs(ac)do bc[cc]=dc end;return bc end;function _c.reverse(ac)local bc={}for i=#ac,1,-1 do table.insert(bc,ac[i])end
return bc end
function _c.uuid()
return
string.format('%04x%04x-%04x-%04x-%04x-%04x%04x%04x',math.random(0,0xffff),math.random(0,0xffff),math.random(0,0xffff),
math.random(0,0x0fff)+0x4000,math.random(0,0x3fff)+0x8000,math.random(0,0xffff),math.random(0,0xffff),math.random(0,0xffff))end
function _c.split(ac,bc)local cc={}for dc in(ac..bc):gmatch("(.-)"..bc)do
table.insert(cc,dc)end;return cc end;function _c.removeTags(ac)return ac:gsub("{[^}]+}","")end
function _c.wrapText(ac,bc)if
ac==nil then return{}end;ac=_c.removeTags(ac)local cc={}
local dc=_c.split(ac,"\n\n")
for _d,ad in ipairs(dc)do
if#ad==0 then table.insert(cc,"")if _d<#dc then
table.insert(cc,"")end else local bd=_c.split(ad,"\n")
for cd,dd in ipairs(bd)do
local __a=_c.split(dd," ")local a_a=""for b_a,c_a in ipairs(__a)do
if#a_a==0 then a_a=c_a elseif#a_a+#c_a+1 <=bc then
a_a=a_a.." "..c_a else table.insert(cc,a_a)a_a=c_a end end;if
#a_a>0 then table.insert(cc,a_a)end end;if _d<#dc then table.insert(cc,"")end end end;return cc end;return _c end
_b["elements/Scrollbar.lua"]=function(...)
local cb=require("elements/VisualElement")local db=require("libraries/colorHex")
local _c=setmetatable({},cb)_c.__index=_c
_c.defineProperty(_c,"value",{default=0,type="number",canTriggerRender=true})
_c.defineProperty(_c,"min",{default=0,type="number",canTriggerRender=true})
_c.defineProperty(_c,"max",{default=100,type="number",canTriggerRender=true})
_c.defineProperty(_c,"step",{default=10,type="number"})
_c.defineProperty(_c,"dragMultiplier",{default=1,type="number"})
_c.defineProperty(_c,"symbol",{default=" ",type="string",canTriggerRender=true})
_c.defineProperty(_c,"symbolColor",{default=colors.gray,type="color",canTriggerRender=true})
_c.defineProperty(_c,"symbolBackgroundColor",{default=colors.black,type="color",canTriggerRender=true})
_c.defineProperty(_c,"backgroundSymbol",{default="\127",type="string",canTriggerRender=true})
_c.defineProperty(_c,"attachedElement",{default=nil,type="table"})
_c.defineProperty(_c,"attachedProperty",{default=nil,type="string"})
_c.defineProperty(_c,"minValue",{default=0,type="number"})
_c.defineProperty(_c,"maxValue",{default=100,type="number"})
_c.defineProperty(_c,"orientation",{default="vertical",type="string",canTriggerRender=true})
_c.defineProperty(_c,"handleSize",{default=2,type="number",canTriggerRender=true})_c.defineEvent(_c,"mouse_click")
_c.defineEvent(_c,"mouse_release")_c.defineEvent(_c,"mouse_drag")
_c.defineEvent(_c,"mouse_scroll")
function _c.new()local cc=setmetatable({},_c):__init()
cc.class=_c;cc.set("width",1)cc.set("height",10)return cc end;function _c:init(cc,dc)cb.init(self,cc,dc)self.set("type","ScrollBar")return
self end
function _c:attach(cc,dc)
self.set("attachedElement",cc)self.set("attachedProperty",dc.property)self.set("minValue",
dc.min or 0)
self.set("maxValue",dc.max or 100)
cc:observe(dc.property,function(_d,ad)
if ad then local bd=self.get("minValue")
local cd=self.get("maxValue")if bd==cd then return end
self.set("value",math.floor((ad-bd)/ (cd-bd)*100 +0.5))end end)return self end
function _c:updateAttachedElement()local cc=self.get("attachedElement")
if not cc then return end;local dc=self.get("value")local _d=self.get("minValue")
local ad=self.get("maxValue")if type(_d)=="function"then _d=_d()end;if type(ad)=="function"then
ad=ad()end;local bd=_d+ (dc/100)* (ad-_d)cc.set(self.get("attachedProperty"),math.floor(
bd+0.5))
return self end;local function ac(cc)
return
cc.get("orientation")=="vertical"and cc.get("height")or cc.get("width")end
local function bc(cc,dc,_d)
local ad,bd=cc:getRelativePosition(dc,_d)return
cc.get("orientation")=="vertical"and bd or ad end
function _c:mouse_click(cc,dc,_d)
if cb.mouse_click(self,cc,dc,_d)then local ad=ac(self)
local bd=self.get("value")local cd=self.get("handleSize")local dd=
math.floor((bd/100)* (ad-cd))+1;local __a=bc(self,dc,_d)
if __a>=dd and
__a<dd+cd then self.dragOffset=__a-dd else
local a_a=( (__a-1)/ (ad-cd))*100
self.set("value",math.min(100,math.max(0,a_a)))self:updateAttachedElement()end;return true end end
function _c:mouse_drag(cc,dc,_d)
if(cb.mouse_drag(self,cc,dc,_d))then local ad=ac(self)
local bd=self.get("handleSize")local cd=self.get("dragMultiplier")local dd=bc(self,dc,_d)
dd=math.max(1,math.min(ad,dd))local __a=dd- (self.dragOffset or 0)local a_a=
(__a-1)/ (ad-bd)*100 *cd
self.set("value",math.min(100,math.max(0,a_a)))self:updateAttachedElement()return true end end
function _c:mouse_scroll(cc,dc,_d)
if not self:isInBounds(dc,_d)then return false end;cc=cc>0 and-1 or 1;local ad=self.get("step")
local bd=self.get("value")local cd=bd-cc*ad
self.set("value",math.min(100,math.max(0,cd)))self:updateAttachedElement()return true end
function _c:render()cb.render(self)local _d=ac(self)local ad=self.get("value")
local bd=self.get("handleSize")local cd=self.get("symbol")local dd=self.get("symbolColor")
local __a=self.get("symbolBackgroundColor")local a_a=self.get("backgroundSymbol")local b_a=self.get("orientation")==
"vertical"local c_a=
math.floor((ad/100)* (_d-bd))+1
for i=1,_d do
if b_a then
self:blit(1,i,a_a,db[self.get("foreground")],db[self.get("background")])else
self:blit(i,1,a_a,db[self.get("foreground")],db[self.get("background")])end end
for i=c_a,c_a+bd-1 do if b_a then self:blit(1,i,cd,db[dd],db[__a])else
self:blit(i,1,cd,db[dd],db[__a])end end end;return _c end
_b["elements/Display.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("VisualElement")
local _c=require("libraries/utils").getCenteredPosition;local ac=require("libraries/utils").deepcopy
local bc=require("libraries/colorHex")local cc=setmetatable({},db)cc.__index=cc;function cc.new()
local dc=setmetatable({},cc):__init()dc.class=cc;dc.set("width",25)dc.set("height",8)
dc.set("z",5)return dc end
function cc:init(dc,_d)
db.init(self,dc,_d)self.set("type","Display")
self._window=window.create(_d.getActiveFrame():getTerm(),1,1,self.get("width"),self.get("height"),false)local ad=self._window.reposition;local bd=self._window.blit
local cd=self._window.write
self._window.reposition=function(dd,__a,a_a,b_a)self.set("x",dd)self.set("y",__a)
self.set("width",a_a)self.set("height",b_a)ad(1,1,a_a,b_a)end
self._window.getPosition=function(dd)return dd.get("x"),dd.get("y")end
self._window.setVisible=function(dd)self.set("visible",dd)end
self._window.isVisible=function(dd)return dd.get("visible")end
self._window.blit=function(dd,__a,a_a,b_a,c_a)bd(dd,__a,a_a,b_a,c_a)
self:updateRender()end
self._window.write=function(dd,__a,a_a)cd(dd,__a,a_a)self:updateRender()end
self:observe("width",function(dd,__a)local a_a=dd._window;if a_a then
a_a.reposition(1,1,__a,dd.get("height"))end end)
self:observe("height",function(dd,__a)local a_a=dd._window;if a_a then
a_a.reposition(1,1,dd.get("width"),__a)end end)end;function cc:getWindow()return self._window end
function cc:write(dc,_d,ad,bd,cd)local dd=self._window
if dd then if bd then
dd.setTextColor(bd)end;if cd then dd.setBackgroundColor(cd)end
dd.setCursorPos(dc,_d)dd.write(ad)end;self:updateRender()return self end
function cc:render()db.render(self)local dc=self._window;local _d,ad=dc.getSize()
if dc then for y=1,ad do
local bd,cd,dd=dc.getLine(y)self:blit(1,y,bd,cd,dd)end end end;return cc end
_b["elements/Dropdown.lua"]=function(...)
local cb=require("elements/VisualElement")local db=require("elements/List")
local _c=require("libraries/colorHex")local ac=setmetatable({},db)ac.__index=ac
ac.defineProperty(ac,"isOpen",{default=false,type="boolean",canTriggerRender=true})
ac.defineProperty(ac,"dropdownHeight",{default=5,type="number"})
ac.defineProperty(ac,"selectedText",{default="",type="string"})
ac.defineProperty(ac,"dropSymbol",{default="\31",type="string"})function ac.new()local bc=setmetatable({},ac):__init()
bc.class=ac;bc.set("width",16)bc.set("height",1)bc.set("z",8)
return bc end
function ac:init(bc,cc)
db.init(self,bc,cc)self.set("type","Dropdown")return self end
function ac:mouse_click(bc,cc,dc)
if not cb.mouse_click(self,bc,cc,dc)then return false end;local _d,ad=self:getRelativePosition(cc,dc)
if ad==1 then self.set("isOpen",not
self.get("isOpen"))if
not self.get("isOpen")then self.set("height",1)else
self.set("height",1 +math.min(self.get("dropdownHeight"),#
self.get("items")))end
return true elseif
self.get("isOpen")and ad>1 and self.get("selectable")then local bd=(ad-1)+self.get("offset")
local cd=self.get("items")
if bd<=#cd then local dd=cd[bd]
if type(dd)=="string"then dd={text=dd}cd[bd]=dd end
if not self.get("multiSelection")then for __a,a_a in ipairs(cd)do if type(a_a)=="table"then
a_a.selected=false end end end;dd.selected=not dd.selected
if dd.callback then dd.callback(self)end;self:fireEvent("select",bd,dd)
self.set("isOpen",false)self.set("height",1)self:updateRender()return true end end;return false end
function ac:render()cb.render(self)local bc=self.get("selectedText")
local cc=self:getSelectedItems()if#cc>0 then local dc=cc[1]bc=dc.text or""
bc=bc:sub(1,self.get("width")-2)end
self:blit(1,1,bc..string.rep(" ",self.get("width")-#
bc-1).. (
self.get("isOpen")and"\31"or"\17"),string.rep(_c[self.get("foreground")],self.get("width")),string.rep(_c[self.get("background")],self.get("width")))
if self.get("isOpen")then local dc=self.get("items")
local _d=self.get("height")-1;local ad=self.get("offset")local bd=self.get("width")
for i=1,_d do local cd=i+ad
local dd=dc[cd]
if dd then if type(dd)=="string"then dd={text=dd}dc[cd]=dd end
if
dd.separator then local __a=(dd.text or"-"):sub(1,1)
local a_a=string.rep(__a,bd)local b_a=dd.foreground or self.get("foreground")local c_a=
dd.background or self.get("background")self:textBg(1,
i+1,string.rep(" ",bd),c_a)
self:textFg(1,i+1,a_a,b_a)else local __a=dd.text;local a_a=dd.selected;__a=__a:sub(1,bd)
local b_a=a_a and(dd.selectedBackground or
self.get("selectedBackground"))or(dd.background or
self.get("background"))
local c_a=
a_a and(dd.selectedForeground or self.get("selectedForeground"))or(dd.foreground or self.get("foreground"))self:textBg(1,i+1,string.rep(" ",bd),b_a)self:textFg(1,
i+1,__a,c_a)end end end end end;return ac end
_b["elements/LineChart.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("VisualElement")local _c=cb.getElement("Graph")
local ac=require("libraries/colorHex")local bc=setmetatable({},_c)bc.__index=bc;function bc.new()
local dc=setmetatable({},bc):__init()dc.class=bc;return dc end
function bc:init(dc,_d)
_c.init(self,dc,_d)self.set("type","LineChart")return self end
local function cc(ad,bd,cd,dd,__a,a_a,b_a,c_a)local d_a=dd-bd;local _aa=__a-cd
local aaa=math.max(math.abs(d_a),math.abs(_aa))
for i=0,aaa do local baa=aaa==0 and 0 or i/aaa
local caa=math.floor(bd+d_a*baa)local daa=math.floor(cd+_aa*baa)
if
caa>=1 and
caa<=ad.get("width")and daa>=1 and daa<=ad.get("height")then ad:blit(caa,daa,a_a,ac[b_a],ac[c_a])end end end
function bc:render()db.render(self)local dc=self.get("width")
local _d=self.get("height")local ad=self.get("minValue")local bd=self.get("maxValue")
local cd=self.get("series")
for dd,__a in pairs(cd)do
if(__a.visible)then local a_a,b_a;local c_a=#__a.data
local d_a=(dc-1)/math.max((c_a-1),1)
for _aa,aaa in ipairs(__a.data)do
local baa=math.floor(( (_aa-1)*d_a)+1)local caa=(aaa-ad)/ (bd-ad)
local daa=math.floor(_d- (caa* (_d-1)))daa=math.max(1,math.min(daa,_d))if a_a then
cc(self,a_a,b_a,baa,daa,__a.symbol,__a.bgColor,__a.fgColor)end;a_a,b_a=baa,daa end end end end;return bc end
_b["elements/Switch.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("VisualElement")local _c=setmetatable({},db)_c.__index=_c
_c.defineProperty(_c,"checked",{default=false,type="boolean",canTriggerRender=true})_c.defineEvent(_c,"mouse_click")
_c.defineEvent(_c,"mouse_up")function _c.new()local ac=setmetatable({},_c):__init()
ac.class=_c;ac.set("width",2)ac.set("height",1)ac.set("z",5)
return ac end;function _c:init(ac,bc)
db.init(self,ac,bc)self.set("type","Switch")end;function _c:render()
db.render(self)end;return _c end
_b["elements/Menu.lua"]=function(...)local cb=require("elements/VisualElement")
local db=require("elements/List")local _c=require("libraries/colorHex")
local ac=setmetatable({},db)ac.__index=ac
ac.defineProperty(ac,"separatorColor",{default=colors.gray,type="color"})
function ac.new()local bc=setmetatable({},ac):__init()
bc.class=ac;bc.set("width",30)bc.set("height",1)
bc.set("background",colors.gray)return bc end
function ac:init(bc,cc)db.init(self,bc,cc)self.set("type","Menu")return self end
function ac:setItems(bc)local cc={}local dc=0
for _d,ad in ipairs(bc)do
if ad.separator then
table.insert(cc,{text=ad.text or"|",selectable=false})dc=dc+1 else local bd=" "..ad.text.." "ad.text=bd
table.insert(cc,ad)dc=dc+#bd end end;self.set("width",dc)return db.setItems(self,cc)end
function ac:render()cb.render(self)local bc=1
for cc,dc in ipairs(self.get("items"))do if type(dc)==
"string"then dc={text=" "..dc.." "}
self.get("items")[cc]=dc end;local _d=dc.selected
local ad=
dc.selectable==false and self.get("separatorColor")or(_d and(dc.selectedForeground or
self.get("selectedForeground"))or(dc.foreground or
self.get("foreground")))
local bd=
_d and(dc.selectedBackground or self.get("selectedBackground"))or(dc.background or self.get("background"))
self:blit(bc,1,dc.text,string.rep(_c[ad],#dc.text),string.rep(_c[bd],#dc.text))bc=bc+#dc.text end end
function ac:mouse_click(bc,cc,dc)
if not cb.mouse_click(self,bc,cc,dc)then return false end
if(self.get("selectable")==false)then return false end
local _d=select(1,self:getRelativePosition(cc,dc))local ad=1
for bd,cd in ipairs(self.get("items"))do
if
_d>=ad and _d<ad+#cd.text then
if cd.selectable~=false then if type(cd)=="string"then cd={text=cd}
self.get("items")[bd]=cd end
if
not self.get("multiSelection")then for dd,__a in ipairs(self.get("items"))do
if type(__a)=="table"then __a.selected=false end end end;cd.selected=not cd.selected
if cd.callback then cd.callback(self)end;self:fireEvent("select",bd,cd)end;return true end;ad=ad+#cd.text end;return false end;return ac end
_b["elements/Slider.lua"]=function(...)
local cb=require("elements/VisualElement")local db=require("libraries/colorHex")
local _c=setmetatable({},cb)_c.__index=_c
_c.defineProperty(_c,"step",{default=1,type="number",canTriggerRender=true})
_c.defineProperty(_c,"max",{default=100,type="number"})
_c.defineProperty(_c,"horizontal",{default=true,type="boolean",canTriggerRender=true,setter=function(ac,bc)if bc then ac.set("backgroundEnabled",false)else
ac.set("backgroundEnabled",true)end end})
_c.defineProperty(_c,"barColor",{default=colors.gray,type="color",canTriggerRender=true})
_c.defineProperty(_c,"sliderColor",{default=colors.blue,type="color",canTriggerRender=true})_c.defineEvent(_c,"mouse_click")
_c.defineEvent(_c,"mouse_drag")_c.defineEvent(_c,"mouse_up")
_c.defineEvent(_c,"mouse_scroll")
function _c.new()local ac=setmetatable({},_c):__init()
ac.class=_c;ac.set("width",8)ac.set("height",1)
ac.set("backgroundEnabled",false)return ac end
function _c:init(ac,bc)cb.init(self,ac,bc)self.set("type","Slider")end
function _c:getValue()local ac=self.get("step")local bc=self.get("max")
local cc=
self.get("horizontal")and self.get("width")or self.get("height")return math.floor((ac-1)* (bc/ (cc-1)))end
function _c:mouse_click(ac,bc,cc)
if self:isInBounds(bc,cc)then
local dc,_d=self:getRelativePosition(bc,cc)
local ad=self.get("horizontal")and dc or _d;local bd=self.get("horizontal")and self.get("width")or
self.get("height")
self.set("step",math.min(bd,math.max(1,ad)))self:updateRender()return true end;return false end;_c.mouse_drag=_c.mouse_click
function _c:mouse_scroll(ac,bc,cc)
if self:isInBounds(bc,cc)then
local dc=self.get("step")local _d=self.get("horizontal")and self.get("width")or
self.get("height")
self.set("step",math.min(_d,math.max(1,
dc+ac)))self:updateRender()return true end;return false end
function _c:render()cb.render(self)local ac=self.get("width")
local bc=self.get("height")local cc=self.get("horizontal")local dc=self.get("step")local _d=
cc and"\140"or" "
local ad=string.rep(_d,cc and ac or bc)
if cc then self:textFg(1,1,ad,self.get("barColor"))
self:textBg(dc,1," ",self.get("sliderColor"))else local bd=self.get("background")
for y=1,bc do self:textBg(1,y," ",bd)end
self:textBg(1,dc," ",self.get("sliderColor"))end end;return _c end
_b["elements/Frame.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("VisualElement")local _c=cb.getElement("Container")local ac=setmetatable({},_c)
ac.__index=ac
ac.defineProperty(ac,"draggable",{default=false,type="boolean",setter=function(bc,cc)
if cc then bc:listenEvent("mouse_click",true)
bc:listenEvent("mouse_up",true)bc:listenEvent("mouse_drag",true)end;return cc end})
ac.defineProperty(ac,"draggingMap",{default={{x=1,y=1,width="width",height=1}},type="table"})
function ac.new()local bc=setmetatable({},ac):__init()
bc.class=ac;bc.set("width",12)bc.set("height",6)
bc.set("background",colors.gray)bc.set("z",10)return bc end;function ac:init(bc,cc)_c.init(self,bc,cc)self.set("type","Frame")
return self end
function ac:mouse_click(bc,cc,dc)
if
db.mouse_click(self,bc,cc,dc)then
if self.get("draggable")then local _d,ad=self:getRelativePosition(cc,dc)
local bd=self.get("draggingMap")
for cd,dd in ipairs(bd)do local __a=dd.width or 1;local a_a=dd.height or 1;if
type(__a)=="string"and __a=="width"then __a=self.get("width")elseif
type(__a)=="function"then __a=__a(self)end
if
type(a_a)=="string"and a_a=="height"then
a_a=self.get("height")elseif type(a_a)=="function"then a_a=a_a(self)end;local b_a=dd.y or 1
if
_d>=dd.x and _d<=dd.x+__a-1 and ad>=b_a and ad<=b_a+a_a-1 then
self.dragStartX=cc-self.get("x")self.dragStartY=dc-self.get("y")self.dragging=true
return true end end end;return _c.mouse_click(self,bc,cc,dc)end;return false end
function ac:mouse_up(bc,cc,dc)self.dragging=false;self.dragStartX=nil;self.dragStartY=nil;return
_c.mouse_up(self,bc,cc,dc)end
function ac:mouse_drag(bc,cc,dc)
if self.get("clicked")and self.dragging then
local _d=cc-self.dragStartX;local ad=dc-self.dragStartY;self.set("x",_d)
self.set("y",ad)return true end
if not self.dragging then return _c.mouse_drag(self,bc,cc,dc)end;return false end;return ac end
_b["elements/Flexbox.lua"]=function(...)local bc=require("elementManager")
local cc=bc.getElement("Container")local dc=setmetatable({},cc)dc.__index=dc
dc.defineProperty(dc,"flexDirection",{default="row",type="string"})
dc.defineProperty(dc,"flexSpacing",{default=1,type="number"})
dc.defineProperty(dc,"flexJustifyContent",{default="flex-start",type="string",setter=function(__a,a_a)if not a_a:match("^flex%-")then
a_a="flex-"..a_a end;return a_a end})
dc.defineProperty(dc,"flexAlignItems",{default="flex-start",type="string",setter=function(__a,a_a)if
not a_a:match("^flex%-")and a_a~="stretch"then a_a="flex-"..a_a end;return a_a end})
dc.defineProperty(dc,"flexCrossPadding",{default=0,type="number"})
dc.defineProperty(dc,"flexWrap",{default=false,type="boolean"})
dc.defineProperty(dc,"flexUpdateLayout",{default=false,type="boolean"})
local _d={getHeight=function(__a)return 0 end,getWidth=function(__a)return 0 end,getZ=function(__a)return 1 end,getPosition=function(__a)return 0,0 end,getSize=function(__a)
return 0,0 end,isType=function(__a)return false end,getType=function(__a)return"lineBreak"end,getName=function(__a)
return"lineBreak"end,setPosition=function(__a)end,setParent=function(__a)end,setSize=function(__a)end,getFlexGrow=function(__a)return 0 end,getFlexShrink=function(__a)return 0 end,getFlexBasis=function(__a)return
0 end,init=function(__a)end,getVisible=function(__a)return true end}
local function ad(__a,a_a,b_a,c_a)local d_a={}local _aa={}local aaa=0
for caa,daa in pairs(__a.get("children"))do if daa.get("visible")then
table.insert(_aa,daa)if daa~=_d then aaa=aaa+1 end end end;if aaa==0 then return d_a end
if not c_a then d_a[1]={offset=1}
for caa,daa in ipairs(_aa)do if daa==_d then
local _ba=#d_a+1;if d_a[_ba]==nil then d_a[_ba]={offset=1}end else
table.insert(d_a[#d_a],daa)end end else
local caa=a_a=="row"and __a.get("width")or __a.get("height")local daa={{}}local _ba=1
for aba,bba in ipairs(_aa)do if bba==_d then _ba=_ba+1;daa[_ba]={}else
table.insert(daa[_ba],bba)end end
for aba,bba in ipairs(daa)do
if#bba==0 then d_a[#d_a+1]={offset=1}else local cba={}local dba={}local _ca=0
for aca,bca in
ipairs(bba)do local cca=0
local dca=a_a=="row"and bca.get("width")or bca.get("height")local _da=false
if a_a=="row"then
local cda,dda=pcall(function()return bca.get("intrinsicWidth")end)if cda and dda then cca=dda;_da=true end else
local cda,dda=pcall(function()
return bca.get("intrinsicHeight")end)if cda and dda then cca=dda;_da=true end end;local ada=_da and cca or dca;local bda=ada
if#dba>0 then bda=bda+b_a end
if _ca+bda<=caa or#dba==0 then table.insert(dba,bca)
_ca=_ca+bda else table.insert(cba,dba)dba={bca}_ca=ada end end;if#dba>0 then table.insert(cba,dba)end;for aca,bca in ipairs(cba)do
d_a[#d_a+1]={offset=1}
for cca,dca in ipairs(bca)do table.insert(d_a[#d_a],dca)end end end end end;local baa={}for caa,daa in ipairs(d_a)do
if#daa>0 then table.insert(baa,daa)end end;return baa end
local function bd(__a,a_a,b_a,c_a)local dca={}for bcb,ccb in ipairs(a_a)do
if ccb~=_d then table.insert(dca,ccb)end end;if#dca==0 then return end
local _da=__a.get("width")local ada=__a.get("height")local bda=__a.get("flexAlignItems")
local cda=__a.get("flexCrossPadding")local dda=__a.get("flexWrap")if _da<=0 then return end
local __b=ada- (cda*2)if __b<1 then __b=ada;cda=0 end;local a_b=math.max;local b_b=math.min
local c_b=math.floor;local d_b=math.ceil;local _ab=0;local aab=0;local bab={}local cab={}local dab={}
for bcb,ccb in ipairs(dca)do local dcb=
ccb.get("flexGrow")or 0
local _db=ccb.get("flexShrink")or 0;local adb=ccb.get("width")cab[ccb]=dcb;dab[ccb]=_db;bab[ccb]=adb;if
dcb>0 then aab=aab+dcb else _ab=_ab+adb end end;local _bb=#dca
local abb=(_bb>1)and( (_bb-1)*b_a)or 0;local bbb=_da-_ab-abb
if bbb>0 and aab>0 then
for bcb,ccb in ipairs(dca)do local dcb=cab[ccb]if dcb>0 then
local _db=bab[ccb]local adb=c_b((dcb/aab)*bbb)
ccb.set("width",a_b(adb,1))end end elseif bbb<0 then local bcb=0;local ccb={}
for dcb,_db in ipairs(dca)do local adb=dab[_db]if adb>0 then bcb=bcb+adb
table.insert(ccb,_db)end end
if bcb>0 and#ccb>0 then local dcb=-bbb;for _db,adb in ipairs(ccb)do local bdb=adb.get("width")
local cdb=dab[adb]local ddb=cdb/bcb;local __c=d_b(dcb*ddb)
adb.set("width",a_b(1,bdb-__c))end end;_ab=0
for dcb,_db in ipairs(dca)do _ab=_ab+_db.get("width")end
if aab>0 then local dcb={}local _db=0
for adb,bdb in ipairs(dca)do if cab[bdb]>0 then table.insert(dcb,bdb)_db=
_db+bdb.get("width")end end
if#dcb>0 and _db>0 then local adb=a_b(c_b(_da*0.2),#dcb)
local bdb=b_b(adb,_da-abb)
for cdb,ddb in ipairs(dcb)do local __c=cab[ddb]local a_c=__c/aab
local b_c=a_b(1,c_b(bdb*a_c))ddb.set("width",b_c)end end end end;local cbb=1
for bcb,ccb in ipairs(dca)do ccb.set("x",cbb)
if not dda then
if bda=="stretch"then
ccb.set("height",__b)ccb.set("y",1 +cda)else local _db=ccb.get("height")local adb=1
if
bda=="flex-end"then adb=ada-_db+1 elseif bda=="flex-center"or bda=="center"then adb=c_b(
(ada-_db)/2)+1 end;ccb.set("y",a_b(1,adb))end end
local dcb=ccb.get("y")+ccb.get("height")-1;if
dcb>ada and(ccb.get("flexShrink")or 0)>0 then
ccb.set("height",a_b(1,ada-ccb.get("y")+1))end;cbb=
cbb+ccb.get("width")+b_a end;local dbb=dca[#dca]local _cb=0;if dbb then
_cb=dbb.get("x")+dbb.get("width")-1 end;local acb=_da-_cb
if acb>0 then
if c_a=="flex-end"then for bcb,ccb in ipairs(dca)do ccb.set("x",
ccb.get("x")+acb)end elseif c_a==
"flex-center"or c_a=="center"then local bcb=c_b(acb/2)for ccb,dcb in ipairs(dca)do dcb.set("x",
dcb.get("x")+bcb)end end end end
local function cd(__a,a_a,b_a,c_a)local dca={}for bcb,ccb in ipairs(a_a)do
if ccb~=_d then table.insert(dca,ccb)end end;if#dca==0 then return end
local _da=__a.get("width")local ada=__a.get("height")local bda=__a.get("flexAlignItems")
local cda=__a.get("flexCrossPadding")local dda=__a.get("flexWrap")if ada<=0 then return end
local __b=_da- (cda*2)if __b<1 then __b=_da;cda=0 end;local a_b=math.max;local b_b=math.min
local c_b=math.floor;local d_b=math.ceil;local _ab=0;local aab=0;local bab={}local cab={}local dab={}
for bcb,ccb in ipairs(dca)do local dcb=
ccb.get("flexGrow")or 0
local _db=ccb.get("flexShrink")or 0;local adb=ccb.get("height")cab[ccb]=dcb;dab[ccb]=_db;bab[ccb]=adb;if
dcb>0 then aab=aab+dcb else _ab=_ab+adb end end;local _bb=#dca
local abb=(_bb>1)and( (_bb-1)*b_a)or 0;local bbb=ada-_ab-abb
if bbb>0 and aab>0 then
for bcb,ccb in ipairs(dca)do local dcb=cab[ccb]if dcb>0 then
local _db=bab[ccb]local adb=c_b((dcb/aab)*bbb)
ccb.set("height",a_b(adb,1))end end elseif bbb<0 then local bcb=0;local ccb={}
for dcb,_db in ipairs(dca)do local adb=dab[_db]if adb>0 then bcb=bcb+adb
table.insert(ccb,_db)end end
if bcb>0 and#ccb>0 then local dcb=-bbb
for _db,adb in ipairs(ccb)do local bdb=adb.get("height")
local cdb=dab[adb]local ddb=cdb/bcb;local __c=d_b(dcb*ddb)
adb.set("height",a_b(1,bdb-__c))end end;_ab=0
for dcb,_db in ipairs(dca)do _ab=_ab+_db.get("height")end
if aab>0 then local dcb={}local _db=0;for adb,bdb in ipairs(dca)do
if cab[bdb]>0 then table.insert(dcb,bdb)_db=
_db+bdb.get("height")end end
if#dcb>0 and _db>0 then local adb=a_b(c_b(ada*
0.2),#dcb)local bdb=b_b(adb,ada-abb)for cdb,ddb in
ipairs(dcb)do local __c=cab[ddb]local a_c=__c/aab;local b_c=a_b(1,c_b(bdb*a_c))
ddb.set("height",b_c)end end end end;local cbb=1
for bcb,ccb in ipairs(dca)do ccb.set("y",cbb)
if not dda then
if bda=="stretch"then
ccb.set("width",__b)ccb.set("x",1 +cda)else local _db=ccb.get("width")local adb=1
if
bda=="flex-end"then adb=_da-_db+1 elseif bda=="flex-center"or bda=="center"then adb=c_b(
(_da-_db)/2)+1 end;ccb.set("x",a_b(1,adb))end end
local dcb=ccb.get("x")+ccb.get("width")-1;if
dcb>_da and(ccb.get("flexShrink")or 0)>0 then
ccb.set("width",a_b(1,_da-ccb.get("x")+1))end;cbb=
cbb+ccb.get("height")+b_a end;local dbb=dca[#dca]local _cb=0;if dbb then
_cb=dbb.get("y")+dbb.get("height")-1 end;local acb=ada-_cb
if acb>0 then
if c_a=="flex-end"then for bcb,ccb in ipairs(dca)do ccb.set("y",
ccb.get("y")+acb)end elseif c_a==
"flex-center"or c_a=="center"then local bcb=c_b(acb/2)for ccb,dcb in ipairs(dca)do dcb.set("y",
dcb.get("y")+bcb)end end end end
local function dd(__a,a_a,b_a,c_a,d_a)if
__a.get("width")<=0 or __a.get("height")<=0 then return end;a_a=
(a_a=="row"or a_a=="column")and a_a or"row"
local _aa,aaa=__a.get("width"),__a.get("height")
local baa=_aa~=__a._lastLayoutWidth or aaa~=__a._lastLayoutHeight;__a._lastLayoutWidth=_aa;__a._lastLayoutHeight=aaa
if
d_a and baa and(
_aa>__a._lastLayoutWidth or aaa>__a._lastLayoutHeight)then
for _ba,aba in pairs(__a.get("children"))do
if
aba~=_d and aba:getVisible()and
aba.get("flexGrow")and aba.get("flexGrow")>0 then
if a_a=="row"then
local bba,cba=pcall(function()return aba.get("intrinsicWidth")end)if bba and cba then aba.set("width",cba)end else
local bba,cba=pcall(function()return
aba.get("intrinsicHeight")end)if bba and cba then aba.set("height",cba)end end end end end;local caa=ad(__a,a_a,b_a,d_a)if#caa==0 then return end
local daa=a_a=="row"and bd or cd
if a_a=="row"and d_a then local _ba=1
for aba,bba in ipairs(caa)do
if#bba>0 then for dba,_ca in ipairs(bba)do if _ca~=_d then
_ca.set("y",_ba)end end
daa(__a,bba,b_a,c_a)local cba=0;for dba,_ca in ipairs(bba)do if _ca~=_d then
cba=math.max(cba,_ca.get("height"))end end;if aba<
#caa then _ba=_ba+cba+b_a else _ba=_ba+cba end end end elseif a_a=="column"and d_a then local _ba=1
for aba,bba in ipairs(caa)do
if#bba>0 then for dba,_ca in ipairs(bba)do if _ca~=_d then
_ca.set("x",_ba)end end
daa(__a,bba,b_a,c_a)local cba=0;for dba,_ca in ipairs(bba)do if _ca~=_d then
cba=math.max(cba,_ca.get("width"))end end;if
aba<#caa then _ba=_ba+cba+b_a else _ba=_ba+cba end end end else for _ba,aba in ipairs(caa)do daa(__a,aba,b_a,c_a)end end;__a:sortChildren()
__a.set("childrenEventsSorted",false)__a.set("flexUpdateLayout",false)end
function dc.new()local __a=setmetatable({},dc):__init()
__a.class=dc;__a.set("width",12)__a.set("height",6)
__a.set("background",colors.blue)__a.set("z",10)__a._lastLayoutWidth=0;__a._lastLayoutHeight=0
__a:observe("width",function()
__a.set("flexUpdateLayout",true)end)
__a:observe("height",function()__a.set("flexUpdateLayout",true)end)
__a:observe("flexDirection",function()__a.set("flexUpdateLayout",true)end)
__a:observe("flexSpacing",function()__a.set("flexUpdateLayout",true)end)
__a:observe("flexWrap",function()__a.set("flexUpdateLayout",true)end)
__a:observe("flexJustifyContent",function()__a.set("flexUpdateLayout",true)end)
__a:observe("flexAlignItems",function()__a.set("flexUpdateLayout",true)end)
__a:observe("flexCrossPadding",function()__a.set("flexUpdateLayout",true)end)return __a end;function dc:init(__a,a_a)cc.init(self,__a,a_a)self.set("type","Flexbox")return
self end
function dc:addChild(__a)
cc.addChild(self,__a)
if(__a~=_d)then
__a:instanceProperty("flexGrow",{default=0,type="number"})
__a:instanceProperty("flexShrink",{default=0,type="number"})
__a:instanceProperty("flexBasis",{default=0,type="number"})
__a:instanceProperty("intrinsicWidth",{default=__a.get("width"),type="number"})
__a:instanceProperty("intrinsicHeight",{default=__a.get("height"),type="number"})
__a:observe("flexGrow",function()self.set("flexUpdateLayout",true)end)
__a:observe("flexShrink",function()self.set("flexUpdateLayout",true)end)
__a:observe("width",function(a_a,b_a,c_a)if __a.get("flexGrow")==0 then
__a.set("intrinsicWidth",b_a)end
self.set("flexUpdateLayout",true)end)
__a:observe("height",function(a_a,b_a,c_a)if __a.get("flexGrow")==0 then
__a.set("intrinsicHeight",b_a)end
self.set("flexUpdateLayout",true)end)end;self.set("flexUpdateLayout",true)return self end
function dc:removeChild(__a)cc.removeChild(self,__a)
if(__a~=_d)then __a.setFlexGrow=nil;__a.setFlexShrink=
nil;__a.setFlexBasis=nil;__a.getFlexGrow=nil
__a.getFlexShrink=nil;__a.getFlexBasis=nil;__a.set("flexGrow",nil)
__a.set("flexShrink",nil)__a.set("flexBasis",nil)end;self.set("flexUpdateLayout",true)return self end;function dc:addLineBreak()self:addChild(_d)return self end
function dc:render()
if
(self.get("flexUpdateLayout"))then
dd(self,self.get("flexDirection"),self.get("flexSpacing"),self.get("flexJustifyContent"),self.get("flexWrap"))end;cc.render(self)end;return dc end
_b["elements/Timer.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("BaseElement")local _c=setmetatable({},db)_c.__index=_c
_c.defineProperty(_c,"interval",{default=1,type="number"})
_c.defineProperty(_c,"action",{default=function()end,type="function"})
_c.defineProperty(_c,"running",{default=false,type="boolean"})
_c.defineProperty(_c,"amount",{default=-1,type="number"})_c.defineEvent(_c,"timer")function _c.new()
local ac=setmetatable({},_c):__init()ac.class=_c;return ac end;function _c:init(ac,bc)
db.init(self,ac,bc)self.set("type","Timer")end
function _c:start()if
not self.running then self.running=true;local ac=self.get("interval")
self.timerId=os.startTimer(ac)end;return self end
function _c:stop()if self.running then self.running=false
os.cancelTimer(self.timerId)end;return self end
function _c:dispatchEvent(ac,...)db.dispatchEvent(self,ac,...)
if ac=="timer"then
local bc=select(1,...)
if bc==self.timerId then self.action()local cc=self.get("amount")if cc>0 then self.set("amount",
cc-1)end;if cc~=0 then
self.timerId=os.startTimer(self.get("interval"))end end end end;return _c end
_b["elements/VisualElement.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("BaseElement")local _c=require("libraries/colorHex")
local ac=setmetatable({},db)ac.__index=ac
ac.defineProperty(ac,"x",{default=1,type="number",canTriggerRender=true})
ac.defineProperty(ac,"y",{default=1,type="number",canTriggerRender=true})
ac.defineProperty(ac,"z",{default=1,type="number",canTriggerRender=true,setter=function(dc,_d)
if dc.parent then dc.parent:sortChildren()end;return _d end})
ac.defineProperty(ac,"width",{default=1,type="number",canTriggerRender=true})
ac.defineProperty(ac,"height",{default=1,type="number",canTriggerRender=true})
ac.defineProperty(ac,"background",{default=colors.black,type="color",canTriggerRender=true})
ac.defineProperty(ac,"foreground",{default=colors.white,type="color",canTriggerRender=true})
ac.defineProperty(ac,"clicked",{default=false,type="boolean"})
ac.defineProperty(ac,"hover",{default=false,type="boolean"})
ac.defineProperty(ac,"backgroundEnabled",{default=true,type="boolean",canTriggerRender=true})
ac.defineProperty(ac,"focused",{default=false,type="boolean",setter=function(dc,_d,ad)local bd=dc.get("focused")
if _d==bd then return _d end;if _d then dc:focus()else dc:blur()end;if not ad and dc.parent then
if _d then
dc.parent:setFocusedChild(dc)else dc.parent:setFocusedChild(nil)end end;return _d end})
ac.defineProperty(ac,"visible",{default=true,type="boolean",canTriggerRender=true,setter=function(dc,_d)
if(dc.parent~=nil)then
dc.parent.set("childrenSorted",false)dc.parent.set("childrenEventsSorted",false)end;if(_d==false)then dc.set("clicked",false)end;return _d end})
ac.defineProperty(ac,"ignoreOffset",{default=false,type="boolean"})ac.combineProperties(ac,"position","x","y")
ac.combineProperties(ac,"size","width","height")
ac.combineProperties(ac,"color","foreground","background")ac.defineEvent(ac,"focus")
ac.defineEvent(ac,"blur")
ac.registerEventCallback(ac,"Click","mouse_click","mouse_up")
ac.registerEventCallback(ac,"ClickUp","mouse_up","mouse_click")
ac.registerEventCallback(ac,"Drag","mouse_drag","mouse_click","mouse_up")
ac.registerEventCallback(ac,"Scroll","mouse_scroll")
ac.registerEventCallback(ac,"Enter","mouse_enter","mouse_move")
ac.registerEventCallback(ac,"Leave","mouse_leave","mouse_move")ac.registerEventCallback(ac,"Focus","focus","blur")
ac.registerEventCallback(ac,"Blur","blur","focus")ac.registerEventCallback(ac,"Key","key","key_up")
ac.registerEventCallback(ac,"Char","char")ac.registerEventCallback(ac,"KeyUp","key_up","key")
local bc,cc=math.max,math.min;function ac.new()local dc=setmetatable({},ac):__init()
dc.class=ac;return dc end
function ac:init(dc,_d)
db.init(self,dc,_d)self.set("type","VisualElement")end
function ac:multiBlit(_d,ad,bd,cd,dd,__a,a_a)local b_a,c_a=self:calculatePosition()_d=_d+b_a-1
ad=ad+c_a-1;self.parent:multiBlit(_d,ad,bd,cd,dd,__a,a_a)end
function ac:textFg(dc,_d,ad,bd)local cd,dd=self:calculatePosition()dc=dc+cd-1
_d=_d+dd-1;self.parent:textFg(dc,_d,ad,bd)end
function ac:textBg(dc,_d,ad,bd)local cd,dd=self:calculatePosition()dc=dc+cd-1
_d=_d+dd-1;self.parent:textBg(dc,_d,ad,bd)end
function ac:drawText(dc,_d,ad)local bd,cd=self:calculatePosition()dc=dc+bd-1
_d=_d+cd-1;self.parent:drawText(dc,_d,ad)end
function ac:drawFg(dc,_d,ad)local bd,cd=self:calculatePosition()dc=dc+bd-1
_d=_d+cd-1;self.parent:drawFg(dc,_d,ad)end
function ac:drawBg(dc,_d,ad)local bd,cd=self:calculatePosition()dc=dc+bd-1
_d=_d+cd-1;self.parent:drawBg(dc,_d,ad)end
function ac:blit(dc,_d,ad,bd,cd)local dd,__a=self:calculatePosition()dc=dc+dd-1
_d=_d+__a-1;self.parent:blit(dc,_d,ad,bd,cd)end
function ac:isInBounds(dc,_d)local ad,bd=self.get("x"),self.get("y")
local cd,dd=self.get("width"),self.get("height")if(self.get("ignoreOffset"))then
if(self.parent)then
dc=dc-self.parent.get("offsetX")_d=_d-self.parent.get("offsetY")end end;return
dc>=ad and dc<=
ad+cd-1 and _d>=bd and _d<=bd+dd-1 end
function ac:mouse_click(dc,_d,ad)if self:isInBounds(_d,ad)then self.set("clicked",true)
self:fireEvent("mouse_click",dc,self:getRelativePosition(_d,ad))return true end;return
false end
function ac:mouse_up(dc,_d,ad)if self:isInBounds(_d,ad)then self.set("clicked",false)
self:fireEvent("mouse_up",dc,self:getRelativePosition(_d,ad))return true end;return
false end
function ac:mouse_release(dc,_d,ad)
self:fireEvent("mouse_release",dc,self:getRelativePosition(_d,ad))self.set("clicked",false)end
function ac:mouse_move(dc,_d,ad)if(_d==nil)or(ad==nil)then return end
local bd=self.get("hover")
if(self:isInBounds(_d,ad))then if(not bd)then self.set("hover",true)
self:fireEvent("mouse_enter",self:getRelativePosition(_d,ad))end;return true else if(bd)then
self.set("hover",false)
self:fireEvent("mouse_leave",self:getRelativePosition(_d,ad))end end;return false end
function ac:mouse_scroll(dc,_d,ad)if(self:isInBounds(_d,ad))then
self:fireEvent("mouse_scroll",dc,self:getRelativePosition(_d,ad))return true end;return false end
function ac:mouse_drag(dc,_d,ad)if(self.get("clicked"))then
self:fireEvent("mouse_drag",dc,self:getRelativePosition(_d,ad))return true end;return false end;function ac:focus()self:fireEvent("focus")end;function ac:blur()
self:fireEvent("blur")self:setCursor(1,1,false)end
function ac:key(dc,_d)if
(self.get("focused"))then self:fireEvent("key",dc,_d)end end;function ac:key_up(dc)
if(self.get("focused"))then self:fireEvent("key_up",dc)end end;function ac:char(dc)if(self.get("focused"))then
self:fireEvent("char",dc)end end
function ac:calculatePosition()
local dc,_d=self.get("x"),self.get("y")
if not self.get("ignoreOffset")then if self.parent~=nil then
local ad,bd=self.parent.get("offsetX"),self.parent.get("offsetY")dc=dc-ad;_d=_d-bd end end;return dc,_d end
function ac:getAbsolutePosition(dc,_d)local ad,bd=self.get("x"),self.get("y")if(dc~=nil)then
ad=ad+dc-1 end;if(_d~=nil)then bd=bd+_d-1 end;local cd=self.parent
while cd do
local dd,__a=cd.get("x"),cd.get("y")ad=ad+dd-1;bd=bd+__a-1;cd=cd.parent end;return ad,bd end
function ac:getRelativePosition(dc,_d)if(dc==nil)or(_d==nil)then
dc,_d=self.get("x"),self.get("y")end;local ad,bd=1,1;if self.parent then
ad,bd=self.parent:getRelativePosition()end
local cd,dd=self.get("x"),self.get("y")return dc- (cd-1)- (ad-1),_d- (dd-1)- (bd-1)end
function ac:setCursor(dc,_d,ad,bd)
if self.parent then local cd,dd=self:calculatePosition()
if
(dc+cd-1 <1)or(
dc+cd-1 >self.parent.get("width"))or(_d+dd-1 <1)or(_d+dd-1 >
self.parent.get("height"))then return self.parent:setCursor(
dc+cd-1,_d+dd-1,false)end
return self.parent:setCursor(dc+cd-1,_d+dd-1,ad,bd)end;return self end
function ac:prioritize()
if(self.parent)then local dc=self.parent;dc:removeChild(self)
dc:addChild(self)self:updateRender()end;return self end
function ac:render()
if(not self.get("backgroundEnabled"))then return end;local dc,_d=self.get("width"),self.get("height")
self:multiBlit(1,1,dc,_d," ",_c[self.get("foreground")],_c[self.get("background")])end;function ac:postRender()end;return ac end
_b["elements/Graph.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("VisualElement")local _c=require("libraries/colorHex")
local ac=setmetatable({},db)ac.__index=ac
ac.defineProperty(ac,"minValue",{default=0,type="number",canTriggerRender=true})
ac.defineProperty(ac,"maxValue",{default=100,type="number",canTriggerRender=true})
ac.defineProperty(ac,"series",{default={},type="table",canTriggerRender=true})function ac.new()local bc=setmetatable({},ac):__init()
bc.class=ac;return bc end;function ac:init(bc,cc)
db.init(self,bc,cc)self.set("type","Graph")self.set("width",20)
self.set("height",10)return self end
function ac:addSeries(bc,cc,dc,_d,ad)
local bd=self.get("series")
table.insert(bd,{name=bc,symbol=cc or" ",bgColor=dc or colors.white,fgColor=_d or colors.black,pointCount=ad or self.get("width"),data={},visible=true})self:updateRender()return self end
function ac:removeSeries(bc)local cc=self.get("series")for dc,_d in ipairs(cc)do if _d.name==bc then
table.remove(cc,dc)break end end
self:updateRender()return self end
function ac:getSeries(bc)local cc=self.get("series")for dc,_d in ipairs(cc)do
if _d.name==bc then return _d end end;return nil end
function ac:changeSeriesVisibility(bc,cc)local dc=self.get("series")for _d,ad in ipairs(dc)do if ad.name==bc then
ad.visible=cc;break end end
self:updateRender()return self end
function ac:addPoint(bc,cc)local dc=self.get("series")
for _d,ad in ipairs(dc)do if ad.name==bc then
table.insert(ad.data,cc)
while#ad.data>ad.pointCount do table.remove(ad.data,1)end;break end end;self:updateRender()return self end
function ac:focusSeries(bc)local cc=self.get("series")
for dc,_d in ipairs(cc)do if _d.name==bc then
table.remove(cc,dc)table.insert(cc,_d)break end end;self:updateRender()return self end
function ac:setSeriesPointCount(bc,cc)local dc=self.get("series")
for _d,ad in ipairs(dc)do if ad.name==bc then
ad.pointCount=cc;while#ad.data>cc do table.remove(ad.data,1)end
break end end;self:updateRender()return self end
function ac:clear(bc)local cc=self.get("series")
if bc then for dc,_d in ipairs(cc)do
if _d.name==bc then _d.data={}break end end else for dc,_d in ipairs(cc)do _d.data={}end end;return self end
function ac:render()db.render(self)local bc=self.get("width")
local cc=self.get("height")local dc=self.get("minValue")local _d=self.get("maxValue")
local ad=self.get("series")
for bd,cd in pairs(ad)do
if(cd.visible)then local dd=#cd.data
local __a=(bc-1)/math.max((dd-1),1)
for a_a,b_a in ipairs(cd.data)do
local c_a=math.floor(( (a_a-1)*__a)+1)local d_a=(b_a-dc)/ (_d-dc)
local _aa=math.floor(cc- (d_a* (cc-1)))_aa=math.max(1,math.min(_aa,cc))
self:blit(c_a,_aa,cd.symbol,_c[cd.bgColor],_c[cd.fgColor])end end end end;return ac end
_b["elements/BigFont.lua"]=function(...)local dc=require("libraries/colorHex")
local _d={{"\32\32\32\137\156\148\158\159\148\135\135\144\159\139\32\136\157\32\159\139\32\32\143\32\32\143\32\32\32\32\32\32\32\32\147\148\150\131\148\32\32\32\151\140\148\151\140\147","\32\32\32\149\132\149\136\156\149\144\32\133\139\159\129\143\159\133\143\159\133\138\32\133\138\32\133\32\32\32\32\32\32\150\150\129\137\156\129\32\32\32\133\131\129\133\131\132","\32\32\32\130\131\32\130\131\32\32\129\32\32\32\32\130\131\32\130\131\32\32\32\32\143\143\143\32\32\32\32\32\32\130\129\32\130\135\32\32\32\32\131\32\32\131\32\131","\139\144\32\32\143\148\135\130\144\149\32\149\150\151\149\158\140\129\32\32\32\135\130\144\135\130\144\32\149\32\32\139\32\159\148\32\32\32\32\159\32\144\32\148\32\147\131\132","\159\135\129\131\143\149\143\138\144\138\32\133\130\149\149\137\155\149\159\143\144\147\130\132\32\149\32\147\130\132\131\159\129\139\151\129\148\32\32\139\131\135\133\32\144\130\151\32","\32\32\32\32\32\32\130\135\32\130\32\129\32\129\129\131\131\32\130\131\129\140\141\132\32\129\32\32\129\32\32\32\32\32\32\32\131\131\129\32\32\32\32\32\32\32\32\32","\32\32\32\32\149\32\159\154\133\133\133\144\152\141\132\133\151\129\136\153\32\32\154\32\159\134\129\130\137\144\159\32\144\32\148\32\32\32\32\32\32\32\32\32\32\32\151\129","\32\32\32\32\133\32\32\32\32\145\145\132\141\140\132\151\129\144\150\146\129\32\32\32\138\144\32\32\159\133\136\131\132\131\151\129\32\144\32\131\131\129\32\144\32\151\129\32","\32\32\32\32\129\32\32\32\32\130\130\32\32\129\32\129\32\129\130\129\129\32\32\32\32\130\129\130\129\32\32\32\32\32\32\32\32\133\32\32\32\32\32\129\32\129\32\32","\150\156\148\136\149\32\134\131\148\134\131\148\159\134\149\136\140\129\152\131\32\135\131\149\150\131\148\150\131\148\32\148\32\32\148\32\32\152\129\143\143\144\130\155\32\134\131\148","\157\129\149\32\149\32\152\131\144\144\131\148\141\140\149\144\32\149\151\131\148\32\150\32\150\131\148\130\156\133\32\144\32\32\144\32\130\155\32\143\143\144\32\152\129\32\134\32","\130\131\32\131\131\129\131\131\129\130\131\32\32\32\129\130\131\32\130\131\32\32\129\32\130\131\32\130\129\32\32\129\32\32\133\32\32\32\129\32\32\32\130\32\32\32\129\32","\150\140\150\137\140\148\136\140\132\150\131\132\151\131\148\136\147\129\136\147\129\150\156\145\138\143\149\130\151\32\32\32\149\138\152\129\149\32\32\157\152\149\157\144\149\150\131\148","\149\143\142\149\32\149\149\32\149\149\32\144\149\32\149\149\32\32\149\32\32\149\32\149\149\32\149\32\149\32\144\32\149\149\130\148\149\32\32\149\32\149\149\130\149\149\32\149","\130\131\129\129\32\129\131\131\32\130\131\32\131\131\32\131\131\129\129\32\32\130\131\32\129\32\129\130\131\32\130\131\32\129\32\129\131\131\129\129\32\129\129\32\129\130\131\32","\136\140\132\150\131\148\136\140\132\153\140\129\131\151\129\149\32\149\149\32\149\149\32\149\137\152\129\137\152\129\131\156\133\149\131\32\150\32\32\130\148\32\152\137\144\32\32\32","\149\32\32\149\159\133\149\32\149\144\32\149\32\149\32\149\32\149\150\151\129\138\155\149\150\130\148\32\149\32\152\129\32\149\32\32\32\150\32\32\149\32\32\32\32\32\32\32","\129\32\32\130\129\129\129\32\129\130\131\32\32\129\32\130\131\32\32\129\32\129\32\129\129\32\129\32\129\32\131\131\129\130\131\32\32\32\129\130\131\32\32\32\32\140\140\132","\32\154\32\159\143\32\149\143\32\159\143\32\159\144\149\159\143\32\159\137\145\159\143\144\149\143\32\32\145\32\32\32\145\149\32\144\32\149\32\143\159\32\143\143\32\159\143\32","\32\32\32\152\140\149\151\32\149\149\32\145\149\130\149\157\140\133\32\149\32\154\143\149\151\32\149\32\149\32\144\32\149\149\153\32\32\149\32\149\133\149\149\32\149\149\32\149","\32\32\32\130\131\129\131\131\32\130\131\32\130\131\129\130\131\129\32\129\32\140\140\129\129\32\129\32\129\32\137\140\129\130\32\129\32\130\32\129\32\129\129\32\129\130\131\32","\144\143\32\159\144\144\144\143\32\159\143\144\159\138\32\144\32\144\144\32\144\144\32\144\144\32\144\144\32\144\143\143\144\32\150\129\32\149\32\130\150\32\134\137\134\134\131\148","\136\143\133\154\141\149\151\32\129\137\140\144\32\149\32\149\32\149\154\159\133\149\148\149\157\153\32\154\143\149\159\134\32\130\148\32\32\149\32\32\151\129\32\32\32\32\134\32","\133\32\32\32\32\133\129\32\32\131\131\32\32\130\32\130\131\129\32\129\32\130\131\129\129\32\129\140\140\129\131\131\129\32\130\129\32\129\32\130\129\32\32\32\32\32\129\32","\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32","\32\32\32\32\32\32\32\32\32\32\32\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\32\32\32\32\32\32\32\32\32\32\32","\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32\32","\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32\32\32\32\32\149\32\32\149\32\32\32\32","\32\32\32\32\32\32\32\32\32\32\32\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\32\32\32\32\32\32\32\32\32\32\32","\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32\32\149\32","\32\32\32\32\145\32\159\139\32\151\131\132\155\143\132\134\135\145\32\149\32\158\140\129\130\130\32\152\147\155\157\134\32\32\144\144\32\32\32\32\32\32\152\131\155\131\131\129","\32\32\32\32\149\32\149\32\145\148\131\32\149\32\149\140\157\132\32\148\32\137\155\149\32\32\32\149\154\149\137\142\32\153\153\32\131\131\149\131\131\129\149\135\145\32\32\32","\32\32\32\32\129\32\130\135\32\131\131\129\134\131\132\32\129\32\32\129\32\131\131\32\32\32\32\130\131\129\32\32\32\32\129\129\32\32\32\32\32\32\130\131\129\32\32\32","\150\150\32\32\148\32\134\32\32\132\32\32\134\32\32\144\32\144\150\151\149\32\32\32\32\32\32\145\32\32\152\140\144\144\144\32\133\151\129\133\151\129\132\151\129\32\145\32","\130\129\32\131\151\129\141\32\32\142\32\32\32\32\32\149\32\149\130\149\149\32\143\32\32\32\32\142\132\32\154\143\133\157\153\132\151\150\148\151\158\132\151\150\148\144\130\148","\32\32\32\140\140\132\32\32\32\32\32\32\32\32\32\151\131\32\32\129\129\32\32\32\32\134\32\32\32\32\32\32\32\129\129\32\129\32\129\129\130\129\129\32\129\130\131\32","\156\143\32\159\141\129\153\140\132\153\137\32\157\141\32\159\142\32\150\151\129\150\131\132\140\143\144\143\141\145\137\140\148\141\141\144\157\142\32\159\140\32\151\134\32\157\141\32","\157\140\149\157\140\149\157\140\149\157\140\149\157\140\149\157\140\149\151\151\32\154\143\132\157\140\32\157\140\32\157\140\32\157\140\32\32\149\32\32\149\32\32\149\32\32\149\32","\129\32\129\129\32\129\129\32\129\129\32\129\129\32\129\129\32\129\129\131\129\32\134\32\131\131\129\131\131\129\131\131\129\131\131\129\130\131\32\130\131\32\130\131\32\130\131\32","\151\131\148\152\137\145\155\140\144\152\142\145\153\140\132\153\137\32\154\142\144\155\159\132\150\156\148\147\32\144\144\130\145\136\137\32\146\130\144\144\130\145\130\136\32\151\140\132","\151\32\149\151\155\149\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\152\137\144\157\129\149\149\32\149\149\32\149\149\32\149\149\32\149\130\150\32\32\157\129\149\32\149","\131\131\32\129\32\129\130\131\32\130\131\32\130\131\32\130\131\32\130\131\32\32\32\32\130\131\32\130\131\32\130\131\32\130\131\32\130\131\32\32\129\32\130\131\32\133\131\32","\156\143\32\159\141\129\153\140\132\153\137\32\157\141\32\159\142\32\159\159\144\152\140\144\156\143\32\159\141\129\153\140\132\157\141\32\130\145\32\32\147\32\136\153\32\130\146\32","\152\140\149\152\140\149\152\140\149\152\140\149\152\140\149\152\140\149\149\157\134\154\143\132\157\140\133\157\140\133\157\140\133\157\140\133\32\149\32\32\149\32\32\149\32\32\149\32","\130\131\129\130\131\129\130\131\129\130\131\129\130\131\129\130\131\129\130\130\131\32\134\32\130\131\129\130\131\129\130\131\129\130\131\129\32\129\32\32\129\32\32\129\32\32\129\32","\159\134\144\137\137\32\156\143\32\159\141\129\153\140\132\153\137\32\157\141\32\32\132\32\159\143\32\147\32\144\144\130\145\136\137\32\146\130\144\144\130\145\130\138\32\146\130\144","\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\149\32\149\131\147\129\138\134\149\149\32\149\149\32\149\149\32\149\149\32\149\154\143\149\32\157\129\154\143\149","\130\131\32\129\32\129\130\131\32\130\131\32\130\131\32\130\131\32\130\131\32\32\32\32\130\131\32\130\131\129\130\131\129\130\131\129\130\131\129\140\140\129\130\131\32\140\140\129"},{"000110000110110000110010101000000010000000100101","000000110110000000000010101000000010000000100101","000000000000000000000000000000000000000000000000","100010110100000010000110110000010100000100000110","000000110000000010110110000110000000000000110000","000000000000000000000000000000000000000000000000","000000110110000010000000100000100000000000000010","000000000110110100010000000010000000000000000100","000000000000000000000000000000000000000000000000","010000000000100110000000000000000000000110010000","000000000000000000000000000010000000010110000000","000000000000000000000000000000000000000000000000","011110110000000100100010110000000100000000000000","000000000000000000000000000000000000000000000000","000000000000000000000000000000000000000000000000","110000110110000000000000000000010100100010000000","000010000000000000110110000000000100010010000000","000000000000000000000000000000000000000000000000","010110010110100110110110010000000100000110110110","000000000000000000000110000000000110000000000000","000000000000000000000000000000000000000000000000","010100010110110000000000000000110000000010000000","110110000000000000110000110110100000000010000000","000000000000000000000000000000000000000000000000","000100011111000100011111000100011111000100011111","000000000000100100100100011011011011111111111111","000000000000000000000000000000000000000000000000","000100011111000100011111000100011111000100011111","000000000000100100100100011011011011111111111111","100100100100100100100100100100100100100100100100","000000110100110110000010000011110000000000011000","000000000100000000000010000011000110000000001000","000000000000000000000000000000000000000000000000","010000100100000000000000000100000000010010110000","000000000000000000000000000000110110110110110000","000000000000000000000000000000000000000000000000","110110110110110110000000110110110110110110110110","000000000000000000000110000000000000000000000000","000000000000000000000000000000000000000000000000","000000000000110110000110010000000000000000010010","000010000000000000000000000000000000000000000000","000000000000000000000000000000000000000000000000","110110110110110110110000110110110110000000000000","000000000000000000000110000000000000000000000000","000000000000000000000000000000000000000000000000","110110110110110110110000110000000000000000010000","000000000000000000000000100000000000000110000110","000000000000000000000000000000000000000000000000"}}local ad={}local bd={}
do local c_a=0;local d_a=#_d[1]local _aa=#_d[1][1]
for i=1,d_a,3 do
for j=1,_aa,3 do
local aaa=string.char(c_a)local baa={}baa[1]=_d[1][i]:sub(j,j+2)baa[2]=_d[1][i+1]:sub(j,
j+2)
baa[3]=_d[1][i+2]:sub(j,j+2)local caa={}caa[1]=_d[2][i]:sub(j,j+2)caa[2]=_d[2][i+1]:sub(j,
j+2)
caa[3]=_d[2][i+2]:sub(j,j+2)bd[aaa]={baa,caa}c_a=c_a+1 end end;ad[1]=bd end
local function cd(c_a,d_a)local _aa={["0"]="1",["1"]="0"}if c_a<=#ad then return true end
for f=#ad+1,c_a do
local aaa={}local baa=ad[f-1]
for char=0,255 do local caa=string.char(char)local daa={}local _ba={}
local aba=baa[caa][1]local bba=baa[caa][2]
for i=1,#aba do local cba,dba,_ca,aca,bca,cca={},{},{},{},{},{}
for j=1,#aba[1]do
local dca=bd[aba[i]:sub(j,j)][1]table.insert(cba,dca[1])
table.insert(dba,dca[2])table.insert(_ca,dca[3])
local _da=bd[aba[i]:sub(j,j)][2]
if bba[i]:sub(j,j)=="1"then
table.insert(aca,(_da[1]:gsub("[01]",_aa)))
table.insert(bca,(_da[2]:gsub("[01]",_aa)))
table.insert(cca,(_da[3]:gsub("[01]",_aa)))else table.insert(aca,_da[1])
table.insert(bca,_da[2])table.insert(cca,_da[3])end end;table.insert(daa,table.concat(cba))
table.insert(daa,table.concat(dba))table.insert(daa,table.concat(_ca))
table.insert(_ba,table.concat(aca))table.insert(_ba,table.concat(bca))
table.insert(_ba,table.concat(cca))end;aaa[caa]={daa,_ba}if d_a then d_a="Font"..f.."Yeld"..char
os.queueEvent(d_a)os.pullEvent(d_a)end end;ad[f]=aaa end;return true end
local function dd(c_a,d_a,_aa,aaa,baa)
if not type(d_a)=="string"then error("Not a String",3)end
local daa=
type(_aa)=="string"and _aa:sub(1,1)or dc[_aa]or error("Wrong Front Color",3)
local _ba=
type(aaa)=="string"and aaa:sub(1,1)or dc[aaa]or error("Wrong Back Color",3)if(ad[c_a]==nil)then cd(3,false)end;local aba=ad[c_a]or
error("Wrong font size selected",3)if d_a==""then
return{{""},{""},{""}}end;local bba={}
for dca in d_a:gmatch('.')do table.insert(bba,dca)end;local cba={}local dba=#aba[bba[1]][1]
for nLine=1,dba do local dca={}for i=1,#bba do
dca[i]=
aba[bba[i]]and aba[bba[i]][1][nLine]or""end;cba[nLine]=table.concat(dca)end;local _ca={}local aca={}local bca={["0"]=daa,["1"]=_ba}
local cca={["0"]=_ba,["1"]=daa}
for nLine=1,dba do local dca={}local _da={}
for i=1,#bba do local ada=
aba[bba[i]]and aba[bba[i]][2][nLine]or""
dca[i]=ada:gsub("[01]",baa and
{["0"]=_aa:sub(i,i),["1"]=aaa:sub(i,i)}or bca)
_da[i]=ada:gsub("[01]",
baa and{["0"]=aaa:sub(i,i),["1"]=_aa:sub(i,i)}or cca)end;_ca[nLine]=table.concat(dca)
aca[nLine]=table.concat(_da)end;return{cba,_ca,aca}end;local __a=require("elementManager")
local a_a=__a.getElement("VisualElement")local b_a=setmetatable({},a_a)b_a.__index=b_a
b_a.defineProperty(b_a,"text",{default="BigFont",type="string",canTriggerRender=true,setter=function(c_a,d_a)
c_a.bigfontText=dd(c_a.get("fontSize"),d_a,c_a.get("foreground"),c_a.get("background"))return d_a end})
b_a.defineProperty(b_a,"fontSize",{default=1,type="number",canTriggerRender=true,setter=function(c_a,d_a)
c_a.bigfontText=dd(d_a,c_a.get("text"),c_a.get("foreground"),c_a.get("background"))return d_a end})
function b_a.new()local c_a=setmetatable({},b_a):__init()
c_a.class=b_a;c_a.set("width",16)c_a.set("height",3)
c_a.set("z",5)return c_a end
function b_a:init(c_a,d_a)a_a.init(self,c_a,d_a)
self.set("type","BigFont")
self:observe("background",function(_aa,aaa)
_aa.bigfontText=dd(_aa.get("fontSize"),_aa.get("text"),_aa.get("foreground"),aaa)end)
self:observe("foreground",function(_aa,aaa)
_aa.bigfontText=dd(_aa.get("fontSize"),_aa.get("text"),aaa,_aa.get("background"))end)end
function b_a:render()a_a.render(self)
if(self.bigfontText)then
local c_a,d_a=self.get("x"),self.get("y")
for i=1,#self.bigfontText[1]do
local _aa=self.bigfontText[1][i]:sub(1,self.get("width"))
local aaa=self.bigfontText[2][i]:sub(1,self.get("width"))
local baa=self.bigfontText[3][i]:sub(1,self.get("width"))self:blit(c_a,d_a+i-1,_aa,aaa,baa)end end end;return b_a end
_b["elements/BaseFrame.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("Container")local _c=require("errorManager")local ac=require("render")
local bc=setmetatable({},db)bc.__index=bc
local function cc(dc)
local _d,ad=pcall(function()return peripheral.getType(dc)end)if _d then return true end;return false end
bc.defineProperty(bc,"term",{default=nil,type="table",setter=function(dc,_d)dc._peripheralName=nil;if
dc.basalt.getActiveFrame(dc._values.term)==dc then
dc.basalt.setActiveFrame(dc,false)end;if
_d==nil or _d.setCursorPos==nil then return _d end;if(cc(_d))then
dc._peripheralName=peripheral.getName(_d)end;dc._values.term=_d
if
dc.basalt.getActiveFrame(_d)==nil then dc.basalt.setActiveFrame(dc)end;dc._render=ac.new(_d)dc._renderUpdate=true;local ad,bd=_d.getSize()
dc.set("width",ad)dc.set("height",bd)return _d end})function bc.new()local dc=setmetatable({},bc):__init()
dc.class=bc;return dc end;function bc:init(dc,_d)
db.init(self,dc,_d)self.set("term",term.current())
self.set("type","BaseFrame")return self end
function bc:multiBlit(_d,ad,bd,cd,dd,__a,a_a)if
(_d<1)then bd=bd+_d-1;_d=1 end;if(ad<1)then cd=cd+ad-1;ad=1 end
self._render:multiBlit(_d,ad,bd,cd,dd,__a,a_a)end;function bc:textFg(dc,_d,ad,bd)if dc<1 then ad=string.sub(ad,1 -dc)dc=1 end
self._render:textFg(dc,_d,ad,bd)end;function bc:textBg(dc,_d,ad,bd)if dc<1 then ad=string.sub(ad,1 -
dc)dc=1 end
self._render:textBg(dc,_d,ad,bd)end;function bc:drawText(dc,_d,ad)if dc<1 then ad=string.sub(ad,
1 -dc)dc=1 end
self._render:text(dc,_d,ad)end
function bc:drawFg(dc,_d,ad)if dc<1 then
ad=string.sub(ad,1 -dc)dc=1 end;self._render:fg(dc,_d,ad)end;function bc:drawBg(dc,_d,ad)if dc<1 then ad=string.sub(ad,1 -dc)dc=1 end
self._render:bg(dc,_d,ad)end
function bc:blit(dc,_d,ad,bd,cd)
if dc<1 then
ad=string.sub(ad,1 -dc)bd=string.sub(bd,1 -dc)cd=string.sub(cd,1 -dc)dc=1 end;self._render:blit(dc,_d,ad,bd,cd)end;function bc:setCursor(dc,_d,ad,bd)local cd=self.get("term")
self._render:setCursor(dc,_d,ad,bd)end
function bc:monitor_touch(dc,_d,ad)
local bd=self.get("term")if bd==nil then return end
if(cc(bd))then if self._peripheralName==dc then
self:mouse_click(1,_d,ad)
self.basalt.schedule(function()sleep(0.1)self:mouse_up(1,_d,ad)end)end end end;function bc:mouse_click(dc,_d,ad)db.mouse_click(self,dc,_d,ad)
self.basalt.setFocus(self)end
function bc:mouse_up(dc,_d,ad)
db.mouse_up(self,dc,_d,ad)db.mouse_release(self,dc,_d,ad)end
function bc:term_resize()local dc,_d=self.get("term").getSize()
if(dc==
self.get("width")and _d==self.get("height"))then return end;self.set("width",dc)self.set("height",_d)
self._render:setSize(dc,_d)self._renderUpdate=true end
function bc:key(dc)self:fireEvent("key",dc)db.key(self,dc)end
function bc:key_up(dc)self:fireEvent("key_up",dc)db.key_up(self,dc)end
function bc:char(dc)self:fireEvent("char",dc)db.char(self,dc)end
function bc:dispatchEvent(dc,...)local _d=self.get("term")if _d==nil then return end;if(cc(_d))then if
dc=="mouse_click"then return end end
db.dispatchEvent(self,dc,...)end;function bc:render()
if(self._renderUpdate)then if self._render~=nil then db.render(self)
self._render:render()self._renderUpdate=false end end end
return bc end
_b["elements/Checkbox.lua"]=function(...)
local cb=require("elements/VisualElement")local db=setmetatable({},cb)db.__index=db
db.defineProperty(db,"checked",{default=false,type="boolean",canTriggerRender=true})
db.defineProperty(db,"text",{default=" ",type="string",canTriggerRender=true,setter=function(_c,ac)local bc=_c.get("checkedText")
local cc=math.max(#ac,#bc)if(_c.get("autoSize"))then _c.set("width",cc)end;return ac end})
db.defineProperty(db,"checkedText",{default="x",type="string",canTriggerRender=true,setter=function(_c,ac)local bc=_c.get("text")
local cc=math.max(#ac,#bc)if(_c.get("autoSize"))then _c.set("width",cc)end;return ac end})
db.defineProperty(db,"autoSize",{default=true,type="boolean"})db.defineEvent(db,"mouse_click")
db.defineEvent(db,"mouse_up")
function db.new()local _c=setmetatable({},db):__init()
_c.class=db;_c.set("backgroundEnabled",false)return _c end
function db:init(_c,ac)cb.init(self,_c,ac)self.set("type","Checkbox")end
function db:mouse_click(_c,ac,bc)if cb.mouse_click(self,_c,ac,bc)then
self.set("checked",not self.get("checked"))return true end;return false end
function db:render()cb.render(self)local _c=self.get("checked")
local ac=self.get("text")local bc=self.get("checkedText")
local cc=string.sub(_c and bc or ac,1,self.get("width"))self:textFg(1,1,cc,self.get("foreground"))end;return db end
_b["elements/Container.lua"]=function(...)local bc=require("elementManager")
local cc=require("errorManager")local dc=bc.getElement("VisualElement")
local _d=require("libraries/expect")local ad=require("libraries/utils").split
local bd=setmetatable({},dc)bd.__index=bd
bd.defineProperty(bd,"children",{default={},type="table"})
bd.defineProperty(bd,"childrenSorted",{default=true,type="boolean"})
bd.defineProperty(bd,"childrenEventsSorted",{default=true,type="boolean"})
bd.defineProperty(bd,"childrenEvents",{default={},type="table"})
bd.defineProperty(bd,"eventListenerCount",{default={},type="table"})
bd.defineProperty(bd,"focusedChild",{default=nil,type="table",allowNil=true,setter=function(__a,a_a,b_a)local c_a=__a._values.focusedChild
if a_a==c_a then return a_a end
if c_a then
if c_a:isType("Container")then c_a.set("focusedChild",nil,true)end;c_a.set("focused",false,true)end
if a_a and not b_a then a_a.set("focused",true,true)if __a.parent then
__a.parent:setFocusedChild(__a)end end;return a_a end})
bd.defineProperty(bd,"visibleChildren",{default={},type="table"})
bd.defineProperty(bd,"visibleChildrenEvents",{default={},type="table"})
bd.defineProperty(bd,"offsetX",{default=0,type="number",canTriggerRender=true,setter=function(__a,a_a)__a.set("childrenSorted",false)
__a.set("childrenEventsSorted",false)return a_a end})
bd.defineProperty(bd,"offsetY",{default=0,type="number",canTriggerRender=true,setter=function(__a,a_a)__a.set("childrenSorted",false)
__a.set("childrenEventsSorted",false)return a_a end})
bd.combineProperties(bd,"offset","offsetX","offsetY")
for __a,a_a in pairs(bc:getElementList())do local b_a=__a:sub(1,1):upper()..
__a:sub(2)
if b_a~="BaseFrame"then
bd["add"..b_a]=function(c_a,...)
_d(1,c_a,"table")local d_a=c_a.basalt.create(__a,...)c_a:addChild(d_a)
d_a:postInit()return d_a end
bd["addDelayed"..b_a]=function(c_a,d_a)_d(1,c_a,"table")
local _aa=c_a.basalt.create(__a,d_a,true,c_a)return _aa end end end;function bd.new()local __a=setmetatable({},bd):__init()
__a.class=bd;return __a end
function bd:init(__a,a_a)
dc.init(self,__a,a_a)self.set("type","Container")
self:observe("width",function()
self.set("childrenSorted",false)self.set("childrenEventsSorted",false)end)
self:observe("height",function()self.set("childrenSorted",false)
self.set("childrenEventsSorted",false)end)end
function bd:isChildVisible(__a)
if not __a:isType("VisualElement")then return false end;if(__a.get("visible")==false)then return false end;if
(__a._destroyed)then return false end
local c_a,d_a=self.get("width"),self.get("height")local _aa,aaa=self.get("offsetX"),self.get("offsetY")
local baa,caa=__a.get("x"),__a.get("y")local daa,_ba=__a.get("width"),__a.get("height")local aba;local bba
if
(__a.get("ignoreOffset"))then aba=baa;bba=caa else aba=baa-_aa;bba=caa-aaa end;return
(aba+daa>0)and(aba<=c_a)and(bba+_ba>0)and(bba<=d_a)end
function bd:addChild(__a)
if __a==self then error("Cannot add container to itself")end
if(__a~=nil)then
table.insert(self._values.children,__a)__a.parent=self;__a:postInit()
self.set("childrenSorted",false)self:registerChildrenEvents(__a)end;return self end
local function cd(__a,a_a)local b_a={}
for c_a,d_a in ipairs(a_a)do if
__a:isChildVisible(d_a)and d_a.get("visible")then table.insert(b_a,d_a)end end
for i=2,#b_a do local c_a=b_a[i]local d_a=c_a.get("z")local _aa=i-1;while _aa>0 do
local aaa=b_a[_aa].get("z")
if aaa>d_a then b_a[_aa+1]=b_a[_aa]_aa=_aa-1 else break end end;b_a[_aa+1]=c_a end;return b_a end
function bd:clear()self.set("children",{})
self.set("childrenEvents",{})self.set("visibleChildren",{})
self.set("visibleChildrenEvents",{})self.set("childrenSorted",true)
self.set("childrenEventsSorted",true)return self end
function bd:sortChildren()
self.set("visibleChildren",cd(self,self._values.children))self.set("childrenSorted",true)return self end
function bd:sortChildrenEvents(__a)if self._values.childrenEvents[__a]then
self._values.visibleChildrenEvents[__a]=cd(self,self._values.childrenEvents[__a])end
self.set("childrenEventsSorted",true)return self end
function bd:registerChildrenEvents(__a)if(__a._registeredEvents==nil)then return end
for a_a in
pairs(__a._registeredEvents)do self:registerChildEvent(__a,a_a)end;return self end
function bd:registerChildEvent(__a,a_a)
if not self._values.childrenEvents[a_a]then
self._values.childrenEvents[a_a]={}self._values.eventListenerCount[a_a]=0;if self.parent then
self.parent:registerChildEvent(self,a_a)end end;for b_a,c_a in ipairs(self._values.childrenEvents[a_a])do if c_a==__a then
return self end end
self.set("childrenEventsSorted",false)
table.insert(self._values.childrenEvents[a_a],__a)self._values.eventListenerCount[a_a]=
self._values.eventListenerCount[a_a]+1;return self end
function bd:removeChildrenEvents(__a)
if __a~=nil then
if(__a._registeredEvents==nil)then return self end;for a_a in pairs(__a._registeredEvents)do
self:unregisterChildEvent(__a,a_a)end end;return self end
function bd:unregisterChildEvent(__a,a_a)
if self._values.childrenEvents[a_a]then
for b_a,c_a in
ipairs(self._values.childrenEvents[a_a])do
if c_a.get("id")==__a.get("id")then
table.remove(self._values.childrenEvents[a_a],b_a)self._values.eventListenerCount[a_a]=
self._values.eventListenerCount[a_a]-1
if
self._values.eventListenerCount[a_a]<=0 then
self._values.childrenEvents[a_a]=nil;self._values.eventListenerCount[a_a]=nil;if self.parent then
self.parent:unregisterChildEvent(self,a_a)end end;self.set("childrenEventsSorted",false)
self:updateRender()break end end end;return self end
function bd:removeChild(__a)if __a==nil then return self end
for a_a,b_a in ipairs(self._values.children)do if
b_a.get("id")==__a.get("id")then
table.remove(self._values.children,a_a)__a.parent=nil;break end end;self:removeChildrenEvents(__a)
self:updateRender()self.set("childrenSorted",false)return self end
function bd:getChild(__a)
if type(__a)=="string"then local a_a=ad(__a,"/")
for b_a,c_a in
pairs(self._values.children)do if c_a.get("name")==a_a[1]then
if#a_a==1 then return c_a else if(c_a:isType("Container"))then return
c_a:find(table.concat(a_a,"/",2))end end end end end;return nil end
local function dd(__a,a_a,...)local b_a={...}
if a_a then
if a_a:find("mouse_")then local c_a,d_a,_aa=...
local aaa,baa=__a.get("offsetX"),__a.get("offsetY")local caa,daa=__a:getRelativePosition(d_a+aaa,_aa+baa)
b_a={c_a,caa,daa}end end;return b_a end
function bd:callChildrenEvent(__a,a_a,...)local b_a=__a and self.get("visibleChildrenEvents")or
self.get("childrenEvents")
if
b_a[a_a]then local c_a=b_a[a_a]for i=#c_a,1,-1 do local d_a=c_a[i]
if(d_a:dispatchEvent(a_a,...))then return true,d_a end end end
if(b_a["*"])then local c_a=b_a["*"]for i=#c_a,1,-1 do local d_a=c_a[i]if(d_a:dispatchEvent(a_a,...))then
return true,d_a end end end;return false end;function bd:handleEvent(__a,...)dc.handleEvent(self,__a,...)
local a_a=dd(self,__a,...)
return self:callChildrenEvent(false,__a,table.unpack(a_a))end
function bd:mouse_click(__a,a_a,b_a)
if
dc.mouse_click(self,__a,a_a,b_a)then local c_a=dd(self,"mouse_click",__a,a_a,b_a)
local d_a,_aa=self:callChildrenEvent(true,"mouse_click",table.unpack(c_a))
if(d_a)then self.set("focusedChild",_aa)return true end;self.set("focusedChild",nil)return true end;return false end
function bd:mouse_up(__a,a_a,b_a)
if dc.mouse_up(self,__a,a_a,b_a)then
local c_a=dd(self,"mouse_up",__a,a_a,b_a)
local d_a,_aa=self:callChildrenEvent(true,"mouse_up",table.unpack(c_a))if(d_a)then return true end end;return false end
function bd:mouse_release(__a,a_a,b_a)dc.mouse_release(self,__a,a_a,b_a)
local c_a=dd(self,"mouse_release",__a,a_a,b_a)
self:callChildrenEvent(false,"mouse_release",table.unpack(c_a))end
function bd:mouse_move(__a,a_a,b_a)
if dc.mouse_move(self,__a,a_a,b_a)then
local c_a=dd(self,"mouse_move",__a,a_a,b_a)
local d_a,_aa=self:callChildrenEvent(true,"mouse_move",table.unpack(c_a))if(d_a)then return true end end;return false end
function bd:mouse_drag(__a,a_a,b_a)
if dc.mouse_drag(self,__a,a_a,b_a)then
local c_a=dd(self,"mouse_drag",__a,a_a,b_a)
local d_a,_aa=self:callChildrenEvent(true,"mouse_drag",table.unpack(c_a))if(d_a)then return true end end;return false end
function bd:mouse_scroll(__a,a_a,b_a)local c_a=dd(self,"mouse_scroll",__a,a_a,b_a)
local d_a,_aa=self:callChildrenEvent(true,"mouse_scroll",table.unpack(c_a))if(d_a)then return true end
if(dc.mouse_scroll(self,__a,a_a,b_a))then return true end;return false end;function bd:key(__a)if self.get("focusedChild")then return
self.get("focusedChild"):dispatchEvent("key",__a)end;return
true end
function bd:char(__a)if
self.get("focusedChild")then
return self.get("focusedChild"):dispatchEvent("char",__a)end;return true end;function bd:key_up(__a)
if self.get("focusedChild")then return
self.get("focusedChild"):dispatchEvent("key_up",__a)end;return true end
function bd:multiBlit(__a,a_a,b_a,c_a,d_a,_aa,aaa)
local baa,caa=self.get("width"),self.get("height")b_a=__a<1 and math.min(b_a+__a-1,baa)or
math.min(b_a,math.max(0,baa-__a+1))c_a=
a_a<1 and math.min(c_a+a_a-1,caa)or
math.min(c_a,math.max(0,caa-a_a+1))if
b_a<=0 or c_a<=0 then return self end
dc.multiBlit(self,math.max(1,__a),math.max(1,a_a),b_a,c_a,d_a,_aa,aaa)return self end
function bd:textFg(__a,a_a,b_a,c_a)local d_a,_aa=self.get("width"),self.get("height")if a_a<1 or
a_a>_aa then return self end
local aaa=__a<1 and(2 -__a)or 1
local baa=math.min(#b_a-aaa+1,d_a-math.max(1,__a)+1)if baa<=0 then return self end
dc.textFg(self,math.max(1,__a),math.max(1,a_a),b_a:sub(aaa,aaa+
baa-1),c_a)return self end
function bd:textBg(__a,a_a,b_a,c_a)local d_a,_aa=self.get("width"),self.get("height")if a_a<1 or
a_a>_aa then return self end
local aaa=__a<1 and(2 -__a)or 1
local baa=math.min(#b_a-aaa+1,d_a-math.max(1,__a)+1)if baa<=0 then return self end
dc.textBg(self,math.max(1,__a),math.max(1,a_a),b_a:sub(aaa,aaa+
baa-1),c_a)return self end
function bd:drawText(__a,a_a,b_a)local c_a,d_a=self.get("width"),self.get("height")if a_a<1 or a_a>
d_a then return self end
local _aa=__a<1 and(2 -__a)or 1
local aaa=math.min(#b_a-_aa+1,c_a-math.max(1,__a)+1)if aaa<=0 then return self end
dc.drawText(self,math.max(1,__a),math.max(1,a_a),b_a:sub(_aa,_aa+
aaa-1))return self end
function bd:drawFg(__a,a_a,b_a)local c_a,d_a=self.get("width"),self.get("height")if a_a<1 or
a_a>d_a then return self end
local _aa=__a<1 and(2 -__a)or 1
local aaa=math.min(#b_a-_aa+1,c_a-math.max(1,__a)+1)if aaa<=0 then return self end
dc.drawFg(self,math.max(1,__a),math.max(1,a_a),b_a:sub(_aa,_aa+
aaa-1))return self end
function bd:drawBg(__a,a_a,b_a)local c_a,d_a=self.get("width"),self.get("height")if a_a<1 or
a_a>d_a then return self end
local _aa=__a<1 and(2 -__a)or 1
local aaa=math.min(#b_a-_aa+1,c_a-math.max(1,__a)+1)if aaa<=0 then return self end
dc.drawBg(self,math.max(1,__a),math.max(1,a_a),b_a:sub(_aa,_aa+
aaa-1))return self end
function bd:blit(__a,a_a,b_a,c_a,d_a)local aaa,baa=self.get("width"),self.get("height")if a_a<1 or
a_a>baa then return self end
local caa=__a<1 and(2 -__a)or 1
local daa=math.min(#b_a-caa+1,aaa-math.max(1,__a)+1)
local _ba=math.min(#c_a-caa+1,aaa-math.max(1,__a)+1)
local aba=math.min(#d_a-caa+1,aaa-math.max(1,__a)+1)if daa<=0 then return self end;local bba=b_a:sub(caa,caa+daa-1)local cba=c_a:sub(caa,
caa+_ba-1)
local dba=d_a:sub(caa,caa+aba-1)
dc.blit(self,math.max(1,__a),math.max(1,a_a),bba,cba,dba)return self end
function bd:render()dc.render(self)if not self.get("childrenSorted")then
self:sortChildren()end
if
not self.get("childrenEventsSorted")then for __a in pairs(self._values.childrenEvents)do
self:sortChildrenEvents(__a)end end
for __a,a_a in ipairs(self.get("visibleChildren"))do if a_a==self then
cc.error("CIRCULAR REFERENCE DETECTED!")return end;a_a:render()
a_a:postRender()end end
function bd:destroy()
if not self:isType("BaseFrame")then for __a,a_a in
ipairs(self.get("children"))do a_a:destroy()end
self.set("childrenSorted",false)dc.destroy(self)return self else cc.header="Basalt Error"
cc.error("Cannot destroy a BaseFrame.")end end;return bd end
_b["elements/List.lua"]=function(...)local cb=require("elements/VisualElement")
local db=setmetatable({},cb)db.__index=db
db.defineProperty(db,"items",{default={},type="table",canTriggerRender=true})
db.defineProperty(db,"selectable",{default=true,type="boolean"})
db.defineProperty(db,"multiSelection",{default=false,type="boolean"})
db.defineProperty(db,"offset",{default=0,type="number",canTriggerRender=true})
db.defineProperty(db,"selectedBackground",{default=colors.blue,type="color"})
db.defineProperty(db,"selectedForeground",{default=colors.white,type="color"})db.defineEvent(db,"mouse_click")
db.defineEvent(db,"mouse_scroll")
function db.new()local _c=setmetatable({},db):__init()
_c.class=db;_c.set("width",16)_c.set("height",8)_c.set("z",5)
_c.set("background",colors.gray)return _c end
function db:init(_c,ac)cb.init(self,_c,ac)self.set("type","List")return self end;function db:addItem(_c)local ac=self.get("items")table.insert(ac,_c)
self:updateRender()return self end
function db:removeItem(_c)
local ac=self.get("items")table.remove(ac,_c)self:updateRender()return self end
function db:clear()self.set("items",{})self:updateRender()return self end
function db:getSelectedItems()local _c={}for ac,bc in ipairs(self.get("items"))do
if type(bc)=="table"and
bc.selected then local cc=bc;cc.index=ac;table.insert(_c,cc)end end;return _c end
function db:getSelectedItem()local _c=self.get("items")
for ac,bc in ipairs(_c)do if type(bc)=="table"and
bc.selected then return bc end end;return nil end
function db:mouse_click(_c,ac,bc)
if
self:isInBounds(ac,bc)and self.get("selectable")then local cc,dc=self:getRelativePosition(ac,bc)
local _d=dc+self.get("offset")local ad=self.get("items")
if _d<=#ad then local bd=ad[_d]if type(bd)=="string"then
bd={text=bd}ad[_d]=bd end;if
not self.get("multiSelection")then
for cd,dd in ipairs(ad)do if type(dd)=="table"then dd.selected=false end end end
bd.selected=not bd.selected;if bd.callback then bd.callback(self)end
self:fireEvent("mouse_click",_c,ac,bc)self:fireEvent("select",_d,bd)self:updateRender()end;return true end;return false end
function db:mouse_scroll(_c,ac,bc)
if self:isInBounds(ac,bc)then local cc=self.get("offset")
local dc=math.max(0,#
self.get("items")-self.get("height"))cc=math.min(dc,math.max(0,cc+_c))
self.set("offset",cc)self:fireEvent("mouse_scroll",_c,ac,bc)return true end;return false end
function db:selectItem(_c)local ac=self.get("items")if
not self.get("multiSelection")then
for cc,dc in ipairs(ac)do if type(dc)=="table"then dc.selected=false end end end;local bc=ac[_c]if
type(bc)=="string"then bc={text=bc}ac[_c]=bc end
bc.selected=true;if bc.callback then bc.callback(self)end
self:fireEvent("select",_c,bc)self:updateRender()return self end
function db:onSelect(_c)self:registerCallback("select",_c)return self end
function db:scrollToBottom()
local _c=math.max(0,#self.get("items")-self.get("height"))self.set("offset",_c)return self end
function db:scrollToTop()self.set("offset",0)return self end
function db:render()cb.render(self)local _c=self.get("items")
local ac=self.get("height")local bc=self.get("offset")local cc=self.get("width")
for i=1,ac do local dc=i+bc
local _d=_c[dc]
if _d then if type(_d)=="string"then _d={text=_d}_c[dc]=_d end
if
_d.separator then local ad=(_d.text or"-"):sub(1,1)
local bd=string.rep(ad,cc)local cd=_d.foreground or self.get("foreground")local dd=
_d.background or self.get("background")
self:textBg(1,i,string.rep(" ",cc),dd)self:textFg(1,i,bd:sub(1,cc),cd)else local ad=_d.text
local bd=_d.selected
local cd=
bd and(_d.selectedBackground or self.get("selectedBackground"))or(_d.background or self.get("background"))
local dd=
bd and(_d.selectedForeground or self.get("selectedForeground"))or(_d.foreground or self.get("foreground"))self:textBg(1,i,string.rep(" ",cc),cd)
self:textFg(1,i,ad:sub(1,cc),dd)end end end end;return db end
_b["elements/ProgressBar.lua"]=function(...)
local cb=require("elements/VisualElement")local db=require("libraries/colorHex")
local _c=setmetatable({},cb)_c.__index=_c
_c.defineProperty(_c,"progress",{default=0,type="number",canTriggerRender=true})
_c.defineProperty(_c,"showPercentage",{default=false,type="boolean"})
_c.defineProperty(_c,"progressColor",{default=colors.black,type="color"})
_c.defineProperty(_c,"direction",{default="right",type="string"})
function _c.new()local ac=setmetatable({},_c):__init()
ac.class=_c;ac.set("width",25)ac.set("height",3)return ac end;function _c:init(ac,bc)cb.init(self,ac,bc)
self.set("type","ProgressBar")end
function _c:render()cb.render(self)
local ac=self.get("width")local bc=self.get("height")
local cc=math.min(100,math.max(0,self.get("progress")))local dc=math.floor((ac*cc)/100)
local _d=math.floor((bc*cc)/100)local ad=self.get("direction")
local bd=self.get("progressColor")
if ad=="right"then
self:multiBlit(1,1,dc,bc," ",db[self.get("foreground")],db[bd])elseif ad=="left"then
self:multiBlit(ac-dc+1,1,dc,bc," ",db[self.get("foreground")],db[bd])elseif ad=="up"then
self:multiBlit(1,bc-_d+1,ac,_d," ",db[self.get("foreground")],db[bd])elseif ad=="down"then
self:multiBlit(1,1,ac,_d," ",db[self.get("foreground")],db[bd])end
if self.get("showPercentage")then local cd=tostring(cc).."%"local dd=math.floor(
(ac-#cd)/2)+1
local __a=math.floor((bc-1)/2)+1
self:textFg(dd,__a,cd,self.get("foreground"))end end;return _c end
_b["elements/Program.lua"]=function(...)local _c=require("elementManager")
local ac=_c.getElement("VisualElement")local bc=require("errorManager")local cc=setmetatable({},ac)
cc.__index=cc
cc.defineProperty(cc,"program",{default=nil,type="table"})
cc.defineProperty(cc,"path",{default="",type="string"})
cc.defineProperty(cc,"running",{default=false,type="boolean"})
cc.defineProperty(cc,"errorCallback",{default=nil,type="function"})
cc.defineProperty(cc,"doneCallback",{default=nil,type="function"})cc.defineEvent(cc,"*")local dc={}dc.__index=dc
local _d=dofile("rom/modules/main/cc/require.lua").make
function dc.new(bd,cd,dd)local __a=setmetatable({},dc)__a.env=cd or{}__a.args={}__a.addEnvironment=
dd==nil and true or dd;__a.program=bd;return __a end;function dc:setArgs(...)self.args={...}end
local function ad(bd)
local cd={shell=shell,multishell=multishell}cd.require,cd.package=_d(cd,bd)return cd end
function dc:run(bd,cd,dd)
self.window=window.create(self.program:getBaseFrame():getTerm(),1,1,cd,dd,false)
local __a=shell.resolveProgram(bd)or fs.exists(bd)and bd or nil
if(__a~=nil)then
if(fs.exists(__a))then local a_a=fs.open(__a,"r")
local b_a=a_a.readAll()a_a.close()
local c_a=setmetatable(ad(fs.getDir(bd)),{__index=_ENV})c_a.term=self.window;c_a.term.current=term.current
c_a.term.redirect=term.redirect;c_a.term.native=function()return self.window end
if
(self.addEnvironment)then for baa,caa in pairs(self.env)do c_a[baa]=caa end else c_a=self.env end
self.coroutine=coroutine.create(function()local baa=load(b_a,"@/"..bd,nil,c_a)if baa then
local caa=baa(table.unpack(self.args))return caa end end)local d_a=term.current()term.redirect(self.window)
local _aa,aaa=coroutine.resume(self.coroutine)term.redirect(d_a)
if not _aa then
local baa=self.program.get("doneCallback")if baa then baa(self.program,_aa,aaa)end
local caa=self.program.get("errorCallback")
if caa then local daa=debug.traceback(self.coroutine,aaa)
local _ba=caa(self.program,aaa,daa:gsub(aaa,""))if(_ba==false)then self.filter=nil;return _aa,aaa end end;bc.header="Basalt Program Error "..bd;bc.error(aaa)end
if coroutine.status(self.coroutine)=="dead"then
self.program.set("running",false)self.program.set("program",nil)
local baa=self.program.get("doneCallback")if baa then baa(self.program,_aa,aaa)end end else bc.header="Basalt Program Error "..bd
bc.error("File not found")end else bc.header="Basalt Program Error"
bc.error("Program "..bd.." not found")end end;function dc:resize(bd,cd)self.window.reposition(1,1,bd,cd)
self:resume("term_resize",bd,cd)end
function dc:resume(bd,...)local cd={...}if
(bd:find("mouse_"))then
cd[2],cd[3]=self.program:getRelativePosition(cd[2],cd[3])end;if self.coroutine==nil or
coroutine.status(self.coroutine)=="dead"then
self.program.set("running",false)return end
if
(self.filter~=nil)then if(bd~=self.filter)then return end;self.filter=nil end;local dd=term.current()term.redirect(self.window)
local __a,a_a=coroutine.resume(self.coroutine,bd,table.unpack(cd))term.redirect(dd)
if __a then self.filter=a_a
if
coroutine.status(self.coroutine)=="dead"then
self.program.set("running",false)self.program.set("program",nil)
local b_a=self.program.get("doneCallback")if b_a then b_a(self.program,__a,a_a)end end else local b_a=self.program.get("doneCallback")if b_a then
b_a(self.program,__a,a_a)end
local c_a=self.program.get("errorCallback")
if c_a then local d_a=debug.traceback(self.coroutine,a_a)d_a=
d_a==nil and""or d_a;a_a=a_a or"Unknown error"
local _aa=c_a(self.program,a_a,d_a:gsub(a_a,""))if(_aa==false)then self.filter=nil;return __a,a_a end end;bc.header="Basalt Program Error"bc.error(a_a)end;return __a,a_a end
function dc:stop()if self.coroutine==nil or
coroutine.status(self.coroutine)=="dead"then
self.program.set("running",false)return end
coroutine.close(self.coroutine)self.coroutine=nil end;function cc.new()local bd=setmetatable({},cc):__init()
bd.class=cc;bd.set("z",5)bd.set("width",30)bd.set("height",12)
return bd end
function cc:init(bd,cd)
ac.init(self,bd,cd)self.set("type","Program")
self:observe("width",function(dd,__a)
local a_a=dd.get("program")
if a_a then a_a:resize(__a,dd.get("height"))end end)
self:observe("height",function(dd,__a)local a_a=dd.get("program")if a_a then
a_a:resize(dd.get("width"),__a)end end)return self end
function cc:execute(bd,cd,dd,...)self.set("path",bd)self.set("running",true)
local __a=dc.new(self,cd,dd)self.set("program",__a)__a:setArgs(...)
__a:run(bd,self.get("width"),self.get("height"),...)self:updateRender()return self end;function cc:stop()local bd=self.get("program")if bd then bd:stop()
self.set("running",false)self.set("program",nil)end
return self end;function cc:sendEvent(bd,...)
self:dispatchEvent(bd,...)return self end;function cc:onError(bd)
self.set("errorCallback",bd)return self end;function cc:onDone(bd)
self.set("doneCallback",bd)return self end
function cc:dispatchEvent(bd,...)
local cd=self.get("program")local dd=ac.dispatchEvent(self,bd,...)
if cd then cd:resume(bd,...)
if
(self.get("focused"))then local __a=cd.window.getCursorBlink()
local a_a,b_a=cd.window.getCursorPos()
self:setCursor(a_a,b_a,__a,cd.window.getTextColor())end;self:updateRender()end;return dd end
function cc:focus()
if(ac.focus(self))then local bd=self.get("program")if bd then
local cd=bd.window.getCursorBlink()local dd,__a=bd.window.getCursorPos()
self:setCursor(dd,__a,cd,bd.window.getTextColor())end end end
function cc:render()ac.render(self)local bd=self.get("program")
if bd then
local cd,dd=bd.window.getSize()for y=1,dd do local __a,a_a,b_a=bd.window.getLine(y)if __a then
self:blit(1,y,__a,a_a,b_a)end end end end;return cc end
_b["elements/Tree.lua"]=function(...)local cb=require("elements/VisualElement")
local db=string.sub;local _c=setmetatable({},cb)_c.__index=_c
_c.defineProperty(_c,"nodes",{default={},type="table",canTriggerRender=true,setter=function(bc,cc)if#cc>0 then
bc.get("expandedNodes")[cc[1]]=true end;return cc end})
_c.defineProperty(_c,"selectedNode",{default=nil,type="table",canTriggerRender=true})
_c.defineProperty(_c,"expandedNodes",{default={},type="table",canTriggerRender=true})
_c.defineProperty(_c,"scrollOffset",{default=0,type="number",canTriggerRender=true})
_c.defineProperty(_c,"horizontalOffset",{default=0,type="number",canTriggerRender=true})
_c.defineProperty(_c,"nodeColor",{default=colors.white,type="color"})
_c.defineProperty(_c,"selectedColor",{default=colors.lightBlue,type="color"})_c.defineEvent(_c,"mouse_click")
_c.defineEvent(_c,"mouse_scroll")function _c.new()local bc=setmetatable({},_c):__init()
bc.class=_c;bc.set("width",30)bc.set("height",10)bc.set("z",5)
return bc end
function _c:init(bc,cc)
cb.init(self,bc,cc)self.set("type","Tree")return self end;function _c:expandNode(bc)self.get("expandedNodes")[bc]=true
self:updateRender()return self end
function _c:collapseNode(bc)self.get("expandedNodes")[bc]=
nil;self:updateRender()return self end;function _c:toggleNode(bc)if self.get("expandedNodes")[bc]then
self:collapseNode(bc)else self:expandNode(bc)end
return self end
local function ac(bc,cc,dc,_d)_d=_d or{}dc=
dc or 0;for ad,bd in ipairs(bc)do table.insert(_d,{node=bd,level=dc})
if
cc[bd]and bd.children then ac(bd.children,cc,dc+1,_d)end end;return _d end
function _c:mouse_click(bc,cc,dc)
if cb.mouse_click(self,bc,cc,dc)then
local _d,ad=self:getRelativePosition(cc,dc)
local bd=ac(self.get("nodes"),self.get("expandedNodes"))local cd=ad+self.get("scrollOffset")
if bd[cd]then local dd=bd[cd]
local __a=dd.node
if _d<=dd.level*2 +2 then self:toggleNode(__a)end;self.set("selectedNode",__a)
self:fireEvent("node_select",__a)end;return true end;return false end
function _c:onSelect(bc)self:registerCallback("node_select",bc)return self end
function _c:mouse_scroll(bc,cc,dc)
if cb.mouse_scroll(self,bc,cc,dc)then
local _d=ac(self.get("nodes"),self.get("expandedNodes"))
local ad=math.max(0,#_d-self.get("height"))
local bd=math.min(ad,math.max(0,self.get("scrollOffset")+bc))self.set("scrollOffset",bd)return true end;return false end
function _c:getNodeSize()local bc,cc=0,0
local dc=ac(self.get("nodes"),self.get("expandedNodes"))for _d,ad in ipairs(dc)do
bc=math.max(bc,ad.level+#ad.node.text)end;cc=#dc;return bc,cc end
function _c:render()cb.render(self)
local bc=ac(self.get("nodes"),self.get("expandedNodes"))local cc=self.get("height")local dc=self.get("selectedNode")
local _d=self.get("expandedNodes")local ad=self.get("scrollOffset")
local bd=self.get("horizontalOffset")
for y=1,cc do local cd=bc[y+ad]
if cd then local dd=cd.node;local __a=cd.level
local a_a=string.rep("  ",__a)local b_a=" "if dd.children and#dd.children>0 then
b_a=_d[dd]and"\31"or"\16"end
local c_a=
dd==dc and self.get("selectedColor")or self.get("background")
local d_a=a_a..b_a.." ".. (dd.text or"Node")local _aa=db(d_a,bd+1,bd+self.get("width"))
self:textFg(1,y,
_aa..string.rep(" ",self.get("width")-#_aa),self.get("foreground"))else
self:textFg(1,y,string.rep(" ",self.get("width")),self.get("foreground"),self.get("background"))end end end;return _c end
_b["elements/Image.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("VisualElement")local _c=require("libraries/colorHex")
local ac=setmetatable({},db)ac.__index=ac
ac.defineProperty(ac,"bimg",{default={{}},type="table",canTriggerRender=true})
ac.defineProperty(ac,"currentFrame",{default=1,type="number",canTriggerRender=true})
ac.defineProperty(ac,"autoResize",{default=false,type="boolean"})
ac.defineProperty(ac,"offsetX",{default=0,type="number",canTriggerRender=true})
ac.defineProperty(ac,"offsetY",{default=0,type="number",canTriggerRender=true})
ac.combineProperties(ac,"offset","offsetX","offsetY")
function ac.new()local dc=setmetatable({},ac):__init()
dc.class=ac;dc.set("width",12)dc.set("height",6)
dc.set("background",colors.black)dc.set("z",5)return dc end;function ac:init(dc,_d)db.init(self,dc,_d)self.set("type","Image")
return self end
function ac:resizeImage(dc,_d)
local ad=self.get("bimg")
for bd,cd in ipairs(ad)do local dd={}
for y=1,_d do local __a=string.rep(" ",dc)
local a_a=string.rep("f",dc)local b_a=string.rep("0",dc)
if cd[y]and cd[y][1]then local c_a=cd[y][1]
local d_a=cd[y][2]local _aa=cd[y][3]
__a=(c_a..string.rep(" ",dc)):sub(1,dc)
a_a=(d_a..string.rep("f",dc)):sub(1,dc)
b_a=(_aa..string.rep("0",dc)):sub(1,dc)end;dd[y]={__a,a_a,b_a}end;ad[bd]=dd end;self:updateRender()return self end
function ac:getImageSize()local dc=self.get("bimg")if not dc[1]or not dc[1][1]then
return 0,0 end;return#dc[1][1][1],#dc[1]end
function ac:getPixelData(dc,_d)
local bd=self.get("bimg")[self.get("currentFrame")]if not bd or not bd[_d]then return end;local cd=bd[_d][1]
local dd=bd[_d][2]local __a=bd[_d][3]
if not cd or not dd or not __a then return end;local a_a=tonumber(dd:sub(dc,dc),16)
local b_a=tonumber(__a:sub(dc,dc),16)local c_a=cd:sub(dc,dc)return a_a,b_a,c_a end
local function bc(dc,_d)
local ad=dc.get("bimg")[dc.get("currentFrame")]if not ad then ad={}
dc.get("bimg")[dc.get("currentFrame")]=ad end
if not ad[_d]then ad[_d]={"","",""}end;return ad end
local function cc(dc,_d,ad)if not dc.get("autoResize")then return end
local bd=dc.get("bimg")local cd=_d;local dd=ad
for __a,a_a in ipairs(bd)do for b_a,c_a in pairs(a_a)do cd=math.max(cd,#c_a[1])
dd=math.max(dd,b_a)end end
for __a,a_a in ipairs(bd)do
for y=1,dd do if not a_a[y]then a_a[y]={"","",""}end;local b_a=a_a[y]while#
b_a[1]<cd do b_a[1]=b_a[1].." "end;while#b_a[2]<cd do b_a[2]=
b_a[2].."f"end;while#b_a[3]<cd do
b_a[3]=b_a[3].."0"end end end end
function ac:setText(dc,_d,ad)if
type(ad)~="string"or#ad<1 or dc<1 or _d<1 then return self end
if
not self.get("autoResize")then local dd,__a=self:getImageSize()if _d>__a then return self end end;local bd=bc(self,_d)if self.get("autoResize")then
cc(self,dc+#ad-1,_d)else local dd=#bd[_d][1]if dc>dd then return self end
ad=ad:sub(1,dd-dc+1)end
local cd=bd[_d][1]
bd[_d][1]=cd:sub(1,dc-1)..ad..cd:sub(dc+#ad)self:updateRender()return self end
function ac:getText(dc,_d,ad)if not dc or not _d then return""end
local bd=self.get("bimg")[self.get("currentFrame")]if not bd or not bd[_d]then return""end;local cd=bd[_d][1]if not cd then
return""end
if ad then return cd:sub(dc,dc+ad-1)else return cd:sub(dc,dc)end end
function ac:setFg(dc,_d,ad)if
type(ad)~="string"or#ad<1 or dc<1 or _d<1 then return self end
if
not self.get("autoResize")then local dd,__a=self:getImageSize()if _d>__a then return self end end;local bd=bc(self,_d)if self.get("autoResize")then
cc(self,dc+#ad-1,_d)else local dd=#bd[_d][2]if dc>dd then return self end
ad=ad:sub(1,dd-dc+1)end
local cd=bd[_d][2]
bd[_d][2]=cd:sub(1,dc-1)..ad..cd:sub(dc+#ad)self:updateRender()return self end
function ac:getFg(dc,_d,ad)if not dc or not _d then return""end
local bd=self.get("bimg")[self.get("currentFrame")]if not bd or not bd[_d]then return""end;local cd=bd[_d][2]if not cd then
return""end
if ad then return cd:sub(dc,dc+ad-1)else return cd:sub(dc)end end
function ac:setBg(dc,_d,ad)if
type(ad)~="string"or#ad<1 or dc<1 or _d<1 then return self end
if
not self.get("autoResize")then local dd,__a=self:getImageSize()if _d>__a then return self end end;local bd=bc(self,_d)if self.get("autoResize")then
cc(self,dc+#ad-1,_d)else local dd=#bd[_d][3]if dc>dd then return self end
ad=ad:sub(1,dd-dc+1)end
local cd=bd[_d][3]
bd[_d][3]=cd:sub(1,dc-1)..ad..cd:sub(dc+#ad)self:updateRender()return self end
function ac:getBg(dc,_d,ad)if not dc or not _d then return""end
local bd=self.get("bimg")[self.get("currentFrame")]if not bd or not bd[_d]then return""end;local cd=bd[_d][3]if not cd then
return""end
if ad then return cd:sub(dc,dc+ad-1)else return cd:sub(dc)end end
function ac:setPixel(dc,_d,ad,bd,cd)if ad then self:setText(dc,_d,ad)end;if bd then
self:setFg(dc,_d,bd)end;if cd then self:setBg(dc,_d,cd)end;return self end
function ac:nextFrame()
if not self.get("bimg").animation then return self end;local dc=self.get("bimg")local _d=self.get("currentFrame")
local ad=_d+1;if ad>#dc then ad=1 end;self.set("currentFrame",ad)return self end
function ac:addFrame()local _d=self.get("bimg")
local ad=_d.width or#_d[1][1][1]local bd=_d.height or#_d[1]local cd={}local dd=string.rep(" ",ad)
local __a=string.rep("f",ad)local a_a=string.rep("0",ad)
for y=1,bd do cd[y]={dd,__a,a_a}end;table.insert(_d,cd)return self end;function ac:updateFrame(dc,_d)local ad=self.get("bimg")ad[dc]=_d
self:updateRender()return self end;function ac:getFrame(dc)
local _d=self.get("bimg")
return _d[dc or self.get("currentFrame")]end
function ac:getMetadata()local dc={}
local _d=self.get("bimg")
for ad,bd in pairs(_d)do if(type(bd)=="string")then dc[ad]=bd end end;return dc end
function ac:setMetadata(dc,_d)if(type(dc)=="table")then
for bd,cd in pairs(dc)do self:setMetadata(bd,cd)end;return self end
local ad=self.get("bimg")if(type(_d)=="string")then ad[dc]=_d end;return self end
function ac:render()db.render(self)
local dc=self.get("bimg")[self.get("currentFrame")]if not dc then return end;local _d=self.get("offsetX")
local ad=self.get("offsetY")local bd=self.get("width")local cd=self.get("height")
for y=1,cd do local dd=y+ad
local __a=dc[dd]
if __a then local a_a=__a[1]local b_a=__a[2]local c_a=__a[3]
if a_a and b_a and c_a then local d_a=bd-
math.max(0,_d)
if d_a>0 then
if _d<0 then local _aa=math.abs(_d)+1
a_a=a_a:sub(_aa)b_a=b_a:sub(_aa)c_a=c_a:sub(_aa)end;a_a=a_a:sub(1,d_a)b_a=b_a:sub(1,d_a)c_a=c_a:sub(1,d_a)self:blit(math.max(1,
1 +_d),y,a_a,b_a,c_a)end end end end end;return ac end
_b["elements/Label.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("VisualElement")local _c=require("libraries/utils").wrapText
local ac=setmetatable({},db)ac.__index=ac
ac.defineProperty(ac,"text",{default="Label",type="string",canTriggerRender=true,setter=function(bc,cc)
if(type(cc)=="function")then cc=cc()end
if(bc.get("autoSize"))then bc.set("width",#cc)else bc.set("height",#
_c(cc,bc.get("width")))end;return cc end})
ac.defineProperty(ac,"autoSize",{default=true,type="boolean",canTriggerRender=true,setter=function(bc,cc)if(cc)then
bc.set("width",#bc.get("text"))else
bc.set("height",#_c(bc.get("text"),bc.get("width")))end;return cc end})
function ac.new()local bc=setmetatable({},ac):__init()
bc.class=ac;bc.set("z",3)bc.set("foreground",colors.black)
bc.set("backgroundEnabled",false)return bc end
function ac:init(bc,cc)db.init(self,bc,cc)if(self.parent)then
self.set("background",self.parent.get("background"))
self.set("foreground",self.parent.get("foreground"))end
self.set("type","Label")return self end;function ac:getWrappedText()local bc=self.get("text")
local cc=_c(bc,self.get("width"))return cc end
function ac:render()
db.render(self)local bc=self.get("text")
if(self.get("autoSize"))then
self:textFg(1,1,bc,self.get("foreground"))else local cc=_c(bc,self.get("width"))for dc,_d in ipairs(cc)do
self:textFg(1,dc,_d,self.get("foreground"))end end end;return ac end
_b["elements/Input.lua"]=function(...)
local cb=require("elements/VisualElement")local db=require("libraries/colorHex")
local _c=setmetatable({},cb)_c.__index=_c
_c.defineProperty(_c,"text",{default="",type="string",canTriggerRender=true})
_c.defineProperty(_c,"cursorPos",{default=1,type="number"})
_c.defineProperty(_c,"viewOffset",{default=0,type="number",canTriggerRender=true})
_c.defineProperty(_c,"maxLength",{default=nil,type="number"})
_c.defineProperty(_c,"placeholder",{default="...",type="string"})
_c.defineProperty(_c,"placeholderColor",{default=colors.gray,type="color"})
_c.defineProperty(_c,"focusedBackground",{default=colors.blue,type="color"})
_c.defineProperty(_c,"focusedForeground",{default=colors.white,type="color"})
_c.defineProperty(_c,"pattern",{default=nil,type="string"})
_c.defineProperty(_c,"cursorColor",{default=nil,type="number"})
_c.defineProperty(_c,"replaceChar",{default=nil,type="string",canTriggerRender=true})_c.defineEvent(_c,"mouse_click")
_c.defineEvent(_c,"key")_c.defineEvent(_c,"char")
_c.defineEvent(_c,"paste")
function _c.new()local ac=setmetatable({},_c):__init()
ac.class=_c;ac.set("width",8)ac.set("z",3)return ac end;function _c:init(ac,bc)cb.init(self,ac,bc)self.set("type","Input")
return self end
function _c:setCursor(ac,bc,cc,dc)
ac=math.min(self.get("width"),math.max(1,ac))return cb.setCursor(self,ac,bc,cc,dc)end
function _c:char(ac)if not self.get("focused")then return false end
local bc=self.get("text")local cc=self.get("cursorPos")local dc=self.get("maxLength")
local _d=self.get("pattern")if dc and#bc>=dc then return false end;if _d and not ac:match(_d)then return
false end
self.set("text",bc:sub(1,cc-1)..ac..bc:sub(cc))self.set("cursorPos",cc+1)self:updateViewport()local ad=
self.get("cursorPos")-self.get("viewOffset")
self:setCursor(ad,1,true,
self.get("cursorColor")or self.get("foreground"))cb.char(self,ac)return true end
function _c:key(ac,bc)if not self.get("focused")then return false end
local cc=self.get("cursorPos")local dc=self.get("text")local _d=self.get("viewOffset")
local ad=self.get("width")
if ac==keys.left then if cc>1 then self.set("cursorPos",cc-1)
if cc-1 <=_d then self.set("viewOffset",math.max(0,
cc-2))end end elseif ac==keys.right then if cc<=#dc then self.set("cursorPos",
cc+1)if cc-_d>=ad then
self.set("viewOffset",cc-ad+1)end end elseif
ac==keys.backspace then if cc>1 then
self.set("text",dc:sub(1,cc-2)..dc:sub(cc))self.set("cursorPos",cc-1)self:updateRender()
self:updateViewport()end end
local bd=self.get("cursorPos")-self.get("viewOffset")
self:setCursor(bd,1,true,self.get("cursorColor")or self.get("foreground"))cb.key(self,ac,bc)return true end
function _c:mouse_click(ac,bc,cc)
if cb.mouse_click(self,ac,bc,cc)then
local dc,_d=self:getRelativePosition(bc,cc)local ad=self.get("text")local bd=self.get("viewOffset")
local cd=#ad+1;local dd=math.min(cd,bd+dc)self.set("cursorPos",dd)
local __a=dd-bd
self:setCursor(__a,1,true,self.get("cursorColor")or self.get("foreground"))return true end;return false end
function _c:updateViewport()local ac=self.get("width")
local bc=self.get("cursorPos")local cc=self.get("viewOffset")
local dc=#self.get("text")
if bc-cc>=ac then self.set("viewOffset",bc-ac+1)elseif bc<=cc then self.set("viewOffset",
bc-1)end
self.set("viewOffset",math.max(0,math.min(self.get("viewOffset"),dc-ac+1)))return self end
function _c:focus()cb.focus(self)
self:setCursor(self.get("cursorPos")-
self.get("viewOffset"),1,true,self.get("cursorColor")or self.get("foreground"))self:updateRender()end
function _c:blur()cb.blur(self)
self:setCursor(1,1,false,self.get("cursorColor")or
self.get("foreground"))self:updateRender()end
function _c:paste(ac)if not self.get("focused")then return false end
local bc=self.get("text")local cc=self.get("cursorPos")local dc=self.get("maxLength")
local _d=self.get("pattern")local ad=bc:sub(1,cc-1)..ac..bc:sub(cc)if
dc and#ad>dc then ad=ad:sub(1,dc)end;if _d and not ad:match(_d)then
return false end;self.set("text",ad)
self.set("cursorPos",cc+#ac)self:updateViewport()end
function _c:render()local cc=self.get("text")local dc=self.get("viewOffset")
local _d=self.get("width")local ad=self.get("placeholder")
local bd=self.get("focusedBackground")local cd=self.get("focusedForeground")
local dd=self.get("focused")local __a,a_a=self.get("width"),self.get("height")
local b_a=self.get("replaceChar")
self:multiBlit(1,1,__a,a_a," ",db[dd and cd or self.get("foreground")],db[
dd and bd or self.get("background")])if
#cc==0 and#ad~=0 and self.get("focused")==false then
self:textFg(1,1,ad:sub(1,__a),self.get("placeholderColor"))return end;if(dd)then
self:setCursor(
self.get("cursorPos")-dc,1,true,self.get("cursorColor")or self.get("foreground"))end
local c_a=cc:sub(dc+1,dc+__a)if b_a and#b_a>0 then c_a=b_a:rep(#c_a)end
self:textFg(1,1,c_a,self.get("foreground"))end;return _c end
_b["elements/BarChart.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("VisualElement")local _c=cb.getElement("Graph")
local ac=require("libraries/colorHex")local bc=setmetatable({},_c)bc.__index=bc;function bc.new()
local cc=setmetatable({},bc):__init()cc.class=bc;return cc end
function bc:init(cc,dc)
_c.init(self,cc,dc)self.set("type","BarChart")return self end
function bc:render()db.render(self)local ad=self.get("width")
local bd=self.get("height")local cd=self.get("minValue")local dd=self.get("maxValue")
local __a=self.get("series")local a_a=0;local b_a={}
for aaa,baa in pairs(__a)do if(baa.visible)then if#baa.data>0 then a_a=a_a+1
table.insert(b_a,baa)end end end;local c_a=a_a;local d_a=1
local _aa=math.min(b_a[1]and b_a[1].pointCount or 0,math.floor((
ad+d_a)/ (c_a+d_a)))
for groupIndex=1,_aa do local aaa=( (groupIndex-1)* (c_a+d_a))+1
for baa,caa in
ipairs(b_a)do local daa=caa.data[groupIndex]
if daa then local _ba=aaa+ (baa-1)
local aba=(daa-cd)/ (dd-cd)local bba=math.floor(bd- (aba* (bd-1)))
bba=math.max(1,math.min(bba,bd))for barY=bba,bd do
self:blit(_ba,barY,caa.symbol,ac[caa.fgColor],ac[caa.bgColor])end end end end end;return bc end
_b["elements/Button.lua"]=function(...)local cb=require("elementManager")
local db=cb.getElement("VisualElement")
local _c=require("libraries/utils").getCenteredPosition;local ac=setmetatable({},db)ac.__index=ac
ac.defineProperty(ac,"text",{default="Button",type="string",canTriggerRender=true})ac.defineEvent(ac,"mouse_click")
ac.defineEvent(ac,"mouse_up")function ac.new()local bc=setmetatable({},ac):__init()
bc.class=ac;bc.set("width",10)bc.set("height",3)bc.set("z",5)
return bc end;function ac:init(bc,cc)
db.init(self,bc,cc)self.set("type","Button")end
function ac:render()
db.render(self)local bc=self.get("text")
bc=bc:sub(1,self.get("width"))
local cc,dc=_c(bc,self.get("width"),self.get("height"))
self:textFg(cc,dc,bc,self.get("foreground"))end;return ac end
_b["elements/BaseElement.lua"]=function(...)local cb=require("propertySystem")
local db=require("libraries/utils").uuid;local _c=require("errorManager")local ac=setmetatable({},cb)
ac.__index=ac
ac.defineProperty(ac,"type",{default={"BaseElement"},type="string",setter=function(bc,cc)if type(cc)=="string"then
table.insert(bc._values.type,1,cc)return bc._values.type end;return cc end,getter=function(bc,cc,dc)if
dc~=nil and dc<1 then return bc._values.type end;return bc._values.type[
dc or 1]end})
ac.defineProperty(ac,"id",{default="",type="string",readonly=true})
ac.defineProperty(ac,"name",{default="",type="string"})
ac.defineProperty(ac,"eventCallbacks",{default={},type="table"})
ac.defineProperty(ac,"enabled",{default=true,type="boolean"})
function ac.defineEvent(bc,cc,dc)
if not rawget(bc,'_eventConfigs')then bc._eventConfigs={}end;bc._eventConfigs[cc]={requires=dc and dc or cc}end
function ac.registerEventCallback(bc,cc,...)
local dc=cc:match("^on")and cc or"on"..cc;local _d={...}local ad=_d[1]
bc[dc]=function(bd,...)
for cd,dd in ipairs(_d)do if not bd._registeredEvents[dd]then
bd:listenEvent(dd,true)end end;bd:registerCallback(ad,...)return bd end end;function ac.new()local bc=setmetatable({},ac):__init()
bc.class=ac;return bc end
function ac:init(bc,cc)
if self._initialized then return self end;self._initialized=true;self._props=bc;self._values.id=db()
self.basalt=cc;self._registeredEvents={}local dc=getmetatable(self).__index
local _d={}dc=self.class
while dc do
if type(dc)=="table"and dc._eventConfigs then for ad,bd in
pairs(dc._eventConfigs)do if not _d[ad]then _d[ad]=bd end end end
dc=getmetatable(dc)and getmetatable(dc).__index end
for ad,bd in pairs(_d)do self._registeredEvents[bd.requires]=true end;if self._callbacks then
for ad,bd in pairs(self._callbacks)do self[bd]=function(cd,...)
cd:registerCallback(ad,...)return cd end end end
return self end
function ac:postInit()if self._postInitialized then return self end
self._postInitialized=true;if(self._props)then
for bc,cc in pairs(self._props)do self.set(bc,cc)end end;self._props=nil;return self end;function ac:isType(bc)
for cc,dc in ipairs(self._values.type)do if dc==bc then return true end end;return false end
function ac:listenEvent(bc,cc)cc=
cc~=false
if
cc~= (self._registeredEvents[bc]or false)then
if cc then self._registeredEvents[bc]=true;if self.parent then
self.parent:registerChildEvent(self,bc)end else self._registeredEvents[bc]=nil
if
self.parent then self.parent:unregisterChildEvent(self,bc)end end end;return self end
function ac:registerCallback(bc,cc)if not self._registeredEvents[bc]then
self:listenEvent(bc,true)end
if
not self._values.eventCallbacks[bc]then self._values.eventCallbacks[bc]={}end
table.insert(self._values.eventCallbacks[bc],cc)return self end
function ac:fireEvent(bc,...)
if self.get("eventCallbacks")[bc]then for cc,dc in
ipairs(self.get("eventCallbacks")[bc])do local _d=dc(self,...)return _d end end;return self end
function ac:dispatchEvent(bc,...)
if self.get("enabled")==false then return false end;if self[bc]then return self[bc](self,...)end;return
self:handleEvent(bc,...)end;function ac:handleEvent(bc,...)return false end;function ac:onChange(bc,cc)
self:observe(bc,cc)return self end
function ac:getBaseFrame()if self.parent then return
self.parent:getBaseFrame()end;return self end
function ac:destroy()self._destroyed=true;self:removeAllObservers()
self:setFocused(false)
for bc in pairs(self._registeredEvents)do self:listenEvent(bc,false)end
if(self.parent)then self.parent:removeChild(self)end end
function ac:updateRender()if(self.parent)then self.parent:updateRender()else
self._renderUpdate=true end;return self end;return ac end
_b["elements/TextBox.lua"]=function(...)
local _c=require("elements/VisualElement")local ac=require("libraries/colorHex")
local bc=setmetatable({},_c)bc.__index=bc
bc.defineProperty(bc,"lines",{default={""},type="table",canTriggerRender=true})
bc.defineProperty(bc,"cursorX",{default=1,type="number"})
bc.defineProperty(bc,"cursorY",{default=1,type="number"})
bc.defineProperty(bc,"scrollX",{default=0,type="number",canTriggerRender=true})
bc.defineProperty(bc,"scrollY",{default=0,type="number",canTriggerRender=true})
bc.defineProperty(bc,"editable",{default=true,type="boolean"})
bc.defineProperty(bc,"syntaxPatterns",{default={},type="table"})
bc.defineProperty(bc,"cursorColor",{default=nil,type="color"})bc.defineEvent(bc,"mouse_click")
bc.defineEvent(bc,"key")bc.defineEvent(bc,"char")
bc.defineEvent(bc,"mouse_scroll")bc.defineEvent(bc,"paste")
function bc.new()
local bd=setmetatable({},bc):__init()bd.class=bc;bd.set("width",20)bd.set("height",10)return bd end;function bc:init(bd,cd)_c.init(self,bd,cd)self.set("type","TextBox")
return self end;function bc:addSyntaxPattern(bd,cd)
table.insert(self.get("syntaxPatterns"),{pattern=bd,color=cd})return self end
local function cc(bd,cd)
local dd=bd.get("lines")local __a=bd.get("cursorX")local a_a=bd.get("cursorY")
local b_a=dd[a_a]
dd[a_a]=b_a:sub(1,__a-1)..cd..b_a:sub(__a)bd.set("cursorX",__a+1)bd:updateViewport()
bd:updateRender()end
local function dc(bd)local cd=bd.get("lines")local dd=bd.get("cursorX")
local __a=bd.get("cursorY")local a_a=cd[__a]local b_a=a_a:sub(dd)cd[__a]=a_a:sub(1,dd-1)table.insert(cd,
__a+1,b_a)bd.set("cursorX",1)
bd.set("cursorY",__a+1)bd:updateViewport()bd:updateRender()end
local function _d(bd)local cd=bd.get("lines")local dd=bd.get("cursorX")
local __a=bd.get("cursorY")local a_a=cd[__a]
if dd>1 then
cd[__a]=a_a:sub(1,dd-2)..a_a:sub(dd)bd.set("cursorX",dd-1)elseif __a>1 then local b_a=cd[__a-1]
bd.set("cursorX",#b_a+1)bd.set("cursorY",__a-1)cd[__a-1]=b_a..a_a
table.remove(cd,__a)end;bd:updateViewport()bd:updateRender()end
function bc:updateViewport()local bd=self.get("cursorX")
local cd=self.get("cursorY")local dd=self.get("scrollX")local __a=self.get("scrollY")
local a_a=self.get("width")local b_a=self.get("height")
if bd-dd>a_a then
self.set("scrollX",bd-a_a)elseif bd-dd<1 then self.set("scrollX",bd-1)end;if cd-__a>b_a then self.set("scrollY",cd-b_a)elseif cd-__a<1 then self.set("scrollY",
cd-1)end;return
self end
function bc:char(bd)if
not self.get("editable")or not self.get("focused")then return false end;cc(self,bd)return true end
function bc:key(bd)if
not self.get("editable")or not self.get("focused")then return false end
local cd=self.get("lines")local dd=self.get("cursorX")local __a=self.get("cursorY")
if bd==
keys.enter then dc(self)elseif bd==keys.backspace then _d(self)elseif bd==keys.left then
if dd>1 then self.set("cursorX",
dd-1)elseif __a>1 then self.set("cursorY",__a-1)self.set("cursorX",
#cd[__a-1]+1)end elseif bd==keys.right then
if dd<=#cd[__a]then self.set("cursorX",dd+1)elseif
__a<#cd then self.set("cursorY",__a+1)self.set("cursorX",1)end elseif bd==keys.up and __a>1 then self.set("cursorY",__a-1)
self.set("cursorX",math.min(dd,
#cd[__a-1]+1))elseif bd==keys.down and __a<#cd then self.set("cursorY",__a+1)
self.set("cursorX",math.min(dd,
#cd[__a+1]+1))end;self:updateRender()self:updateViewport()return true end
function bc:mouse_scroll(bd,cd,dd)
if self:isInBounds(cd,dd)then local __a=self.get("scrollY")
local a_a=self.get("height")local b_a=self.get("lines")
local c_a=math.max(0,#b_a-a_a+2)local d_a=math.max(0,math.min(c_a,__a+bd))
self.set("scrollY",d_a)self:updateRender()return true end;return false end
function bc:mouse_click(bd,cd,dd)
if _c.mouse_click(self,bd,cd,dd)then
local __a,a_a=self:getRelativePosition(cd,dd)local b_a=self.get("scrollX")local c_a=self.get("scrollY")
local d_a=a_a+c_a;local _aa=self.get("lines")if d_a<=#_aa then
self.set("cursorY",d_a)
self.set("cursorX",math.min(__a+b_a,#_aa[d_a]+1))end
self:updateRender()return true end;return false end
function bc:paste(bd)if
not self.get("editable")or not self.get("focused")then return false end;for cd in bd:gmatch(".")do if cd=="\n"then
dc(self)else cc(self,cd)end end;return
true end
function bc:setText(bd)local cd={}
if bd==""then cd={""}else for dd in(bd.."\n"):gmatch("([^\n]*)\n")do
table.insert(cd,dd)end end;self.set("lines",cd)return self end
function bc:getText()return table.concat(self.get("lines"),"\n")end
local function ad(bd,cd)local dd=cd
local __a=string.rep(ac[bd.get("foreground")],#dd)local a_a=bd.get("syntaxPatterns")
for b_a,c_a in ipairs(a_a)do local d_a=1
while true do
local _aa,aaa=dd:find(c_a.pattern,d_a)if not _aa then break end
__a=__a:sub(1,_aa-1)..
string.rep(ac[c_a.color],aaa-_aa+1)..__a:sub(aaa+1)d_a=aaa+1 end end;return dd,__a end
function bc:render()_c.render(self)local bd=self.get("lines")
local cd=self.get("scrollX")local dd=self.get("scrollY")local __a=self.get("width")
local a_a=self.get("height")local b_a=ac[self.get("foreground")]
local c_a=ac[self.get("background")]
for y=1,a_a do local d_a=y+dd;local _aa=bd[d_a]or""local aaa=_aa:sub(cd+1,cd+__a)
if#
aaa<__a then aaa=aaa..string.rep(" ",__a-#aaa)end;local baa,caa=ad(self,aaa)
self:blit(1,y,baa,caa,string.rep(c_a,#aaa))end
if self.get("focused")then local d_a=self.get("cursorX")-cd;local _aa=
self.get("cursorY")-dd;if d_a>=1 and d_a<=__a and _aa>=1 and
_aa<=a_a then
self:setCursor(d_a,_aa,true,self.get("cursorColor")or
self.get("foreground"))end end end;return bc end
_b["elements/Table.lua"]=function(...)
local cb=require("elements/VisualElement")local db=require("libraries/colorHex")
local _c=setmetatable({},cb)_c.__index=_c
_c.defineProperty(_c,"columns",{default={},type="table",canTriggerRender=true,setter=function(ac,bc)local cc={}
for dc,_d in ipairs(bc)do
if type(_d)=="string"then cc[dc]={name=_d,width=
#_d+1}elseif type(_d)=="table"then cc[dc]={name=_d.name or"",width=_d.width or#
_d.name+1}end end;return cc end})
_c.defineProperty(_c,"data",{default={},type="table",canTriggerRender=true})
_c.defineProperty(_c,"selectedRow",{default=nil,type="number",canTriggerRender=true})
_c.defineProperty(_c,"headerColor",{default=colors.blue,type="color"})
_c.defineProperty(_c,"selectedColor",{default=colors.lightBlue,type="color"})
_c.defineProperty(_c,"gridColor",{default=colors.gray,type="color"})
_c.defineProperty(_c,"sortColumn",{default=nil,type="number"})
_c.defineProperty(_c,"sortDirection",{default="asc",type="string"})
_c.defineProperty(_c,"scrollOffset",{default=0,type="number",canTriggerRender=true})_c.defineEvent(_c,"mouse_click")
_c.defineEvent(_c,"mouse_scroll")function _c.new()local ac=setmetatable({},_c):__init()
ac.class=_c;ac.set("width",30)ac.set("height",10)ac.set("z",5)
return ac end
function _c:init(ac,bc)
cb.init(self,ac,bc)self.set("type","Table")return self end
function _c:addColumn(ac,bc)local cc=self.get("columns")
table.insert(cc,{name=ac,width=bc})self.set("columns",cc)return self end;function _c:addData(...)local ac=self.get("data")table.insert(ac,{...})
self.set("data",ac)return self end
function _c:sortData(ac,bc)
local cc=self.get("data")local dc=self.get("sortDirection")
if not bc then
table.sort(cc,function(_d,ad)if dc=="asc"then return
_d[ac]<ad[ac]else return _d[ac]>ad[ac]end end)else
table.sort(cc,function(_d,ad)return bc(_d[ac],ad[ac])end)end;return self end
function _c:mouse_click(ac,bc,cc)
if not cb.mouse_click(self,ac,bc,cc)then return false end;local dc,_d=self:getRelativePosition(bc,cc)
if _d==1 then local ad=1
for bd,cd in
ipairs(self.get("columns"))do
if dc>=ad and dc<ad+cd.width then
if self.get("sortColumn")==bd then
self.set("sortDirection",
self.get("sortDirection")=="asc"and"desc"or"asc")else self.set("sortColumn",bd)
self.set("sortDirection","asc")end;self:sortData(bd)break end;ad=ad+cd.width end end
if _d>1 then local ad=_d-2 +self.get("scrollOffset")if ad>=0 and ad<#
self.get("data")then local bd=ad+1
self.set("selectedRow",bd)
self:fireEvent("select",bd,self.get("data")[bd])end end;return true end
function _c:onSelect(ac)self:registerCallback("select",ac)return self end
function _c:mouse_scroll(ac,bc,cc)
if(cb.mouse_scroll(self,ac,bc,cc))then local dc=self.get("data")
local _d=self.get("height")local ad=_d-2;local bd=math.max(0,#dc-ad+1)
local cd=math.min(bd,math.max(0,
self.get("scrollOffset")+ac))self.set("scrollOffset",cd)return true end;return false end
function _c:render()cb.render(self)local ac=self.get("columns")
local bc=self.get("data")local cc=self.get("selectedRow")
local dc=self.get("sortColumn")local _d=self.get("scrollOffset")local ad=self.get("height")
local bd=self.get("width")local cd=1
for dd,__a in ipairs(ac)do local a_a=__a.name;if dd==dc then
a_a=a_a.. (
self.get("sortDirection")=="asc"and"\30"or"\31")end
self:textFg(cd,1,a_a:sub(1,__a.width),self.get("headerColor"))cd=cd+__a.width end
for y=2,ad do local dd=y-2 +_d;local __a=bc[dd+1]
if __a and(dd+1)<=#bc then cd=1
local a_a=(dd+1)==cc and
self.get("selectedColor")or self.get("background")
for b_a,c_a in ipairs(ac)do local d_a=tostring(__a[b_a]or"")local _aa=d_a..
string.rep(" ",c_a.width-#d_a)if b_a<#ac then _aa=
string.sub(_aa,1,c_a.width-1).." "end
local aaa=string.sub(_aa,1,c_a.width)
local baa=string.rep(db[self.get("foreground")],#aaa)local caa=string.rep(db[a_a],#aaa)
self:blit(cd,y,aaa,baa,caa)cd=cd+c_a.width end else
self:blit(1,y,string.rep(" ",self.get("width")),string.rep(db[self.get("foreground")],self.get("width")),string.rep(db[self.get("background")],self.get("width")))end end end;return _c end
_b["log.lua"]=function(...)local cb={}cb._logs={}cb._enabled=false;cb._logToFile=false
cb._logFile="basalt.log"fs.delete(cb._logFile)
cb.LEVEL={DEBUG=1,INFO=2,WARN=3,ERROR=4}
local db={[cb.LEVEL.DEBUG]="Debug",[cb.LEVEL.INFO]="Info",[cb.LEVEL.WARN]="Warn",[cb.LEVEL.ERROR]="Error"}
local _c={[cb.LEVEL.DEBUG]=colors.lightGray,[cb.LEVEL.INFO]=colors.white,[cb.LEVEL.WARN]=colors.yellow,[cb.LEVEL.ERROR]=colors.red}function cb.setLogToFile(cc)cb._logToFile=cc end
function cb.setEnabled(cc)cb._enabled=cc end;local function ac(cc)
if cb._logToFile then local dc=io.open(cb._logFile,"a")if dc then
dc:write(cc.."\n")dc:close()end end end
local function bc(cc,...)if
not cb._enabled then return end;local _d=os.date("%H:%M:%S")
local ad=debug.getinfo(3,"Sl")local bd=ad.source:match("@?(.*)")local cd=ad.currentline
local dd=string.format("[%s:%d]",bd:match("([^/\\]+)%.lua$"),cd)local __a="["..db[cc].."]"local a_a=""
for c_a,d_a in ipairs(table.pack(...))do if
c_a>1 then a_a=a_a.." "end;a_a=a_a..tostring(d_a)end;local b_a=string.format("%s %s%s %s",_d,dd,__a,a_a)
ac(b_a)
table.insert(cb._logs,{time=_d,level=cc,message=a_a})end;function cb.debug(...)bc(cb.LEVEL.DEBUG,...)end;function cb.info(...)
bc(cb.LEVEL.INFO,...)end
function cb.warn(...)bc(cb.LEVEL.WARN,...)end;function cb.error(...)bc(cb.LEVEL.ERROR,...)end;return cb end
_b["elementManager.lua"]=function(...)local ad=table.pack(...)
local bd=fs.getDir(ad[2]or"basalt")local cd=ad[1]if(bd==nil)then
error("Unable to find directory "..
ad[2].." please report this bug to our discord.")end
local dd=require("log")local __a=package.path;local a_a="path;/path/?.lua;/path/?/init.lua;"
local b_a=a_a:gsub("path",bd)local c_a={}c_a._elements={}c_a._plugins={}c_a._APIs={}
local d_a=fs.combine(bd,"elements")local _aa=fs.combine(bd,"plugins")
dd.info("Loading elements from "..d_a)
if fs.exists(d_a)then
for aaa,baa in ipairs(fs.list(d_a))do
local caa=baa:match("(.+).lua")
if caa then dd.debug("Found element: "..caa)c_a._elements[caa]={class=
nil,plugins={},loaded=false}end end end;dd.info("Loading plugins from ".._aa)
if
fs.exists(_aa)then
for aaa,baa in ipairs(fs.list(_aa))do local caa=baa:match("(.+).lua")
if caa then dd.debug(
"Found plugin: "..caa)
local daa=require(fs.combine("plugins",caa))
if type(daa)=="table"then
for _ba,aba in pairs(daa)do
if(_ba~="API")then if(c_a._plugins[_ba]==nil)then
c_a._plugins[_ba]={}end
table.insert(c_a._plugins[_ba],aba)else c_a._APIs[caa]=aba end end end end end end
if(ba)then if(ca==nil)then
error("Unable to find minified_elementDirectory please report this bug to our discord.")end
for aaa,baa in pairs(ca)do c_a._elements[aaa:gsub(".lua","")]={class=
nil,plugins={},loaded=false}end;if(da==nil)then
error("Unable to find minified_pluginDirectory please report this bug to our discord.")end
for aaa,baa in pairs(da)do
local caa=aaa:gsub(".lua","")local daa=require(fs.combine("plugins",caa))
if type(daa)==
"table"then
for _ba,aba in pairs(daa)do
if(_ba~="API")then if(c_a._plugins[_ba]==nil)then
c_a._plugins[_ba]={}end
table.insert(c_a._plugins[_ba],aba)else c_a._APIs[caa]=aba end end end end end
function c_a.loadElement(aaa)
if not c_a._elements[aaa].loaded then
package.path=b_a.."rom/?"local baa=require(fs.combine("elements",aaa))
package.path=__a
c_a._elements[aaa]={class=baa,plugins=baa.plugins,loaded=true}dd.debug("Loaded element: "..aaa)
if(
c_a._plugins[aaa]~=nil)then
for caa,daa in pairs(c_a._plugins[aaa])do
if(daa.setup)then daa.setup(baa)end
if(daa.hooks)then
for _ba,aba in pairs(daa.hooks)do local bba=baa[_ba]if(type(bba)~="function")then
error("Element "..aaa..
" does not have a method ".._ba)end
if(type(aba)=="function")then
baa[_ba]=function(cba,...)
local dba=bba(cba,...)local _ca=aba(cba,...)return _ca==nil and dba or _ca end elseif(type(aba)=="table")then
baa[_ba]=function(cba,...)if aba.pre then aba.pre(cba,...)end
local dba=bba(cba,...)if aba.post then aba.post(cba,...)end;return dba end end end end;for _ba,aba in pairs(daa)do
if _ba~="setup"and _ba~="hooks"then baa[_ba]=aba end end end end end end;function c_a.getElement(aaa)if not c_a._elements[aaa].loaded then
c_a.loadElement(aaa)end
return c_a._elements[aaa].class end;function c_a.getElementList()return
c_a._elements end
function c_a.getAPI(aaa)return c_a._APIs[aaa]end;return c_a end
_b["propertySystem.lua"]=function(...)
local cb=require("libraries/utils").deepCopy;local db=require("libraries/expect")
local _c=require("errorManager")local ac={}ac.__index=ac;ac._properties={}local bc={}ac._setterHooks={}function ac.addSetterHook(dc)
table.insert(ac._setterHooks,dc)end;local function cc(dc,_d,ad,bd)for cd,dd in ipairs(ac._setterHooks)do
local __a=dd(dc,_d,ad,bd)if __a~=nil then ad=__a end end
return ad end
function ac.defineProperty(dc,_d,ad)
if
not rawget(dc,'_properties')then dc._properties={}end
dc._properties[_d]={type=ad.type,default=ad.default,canTriggerRender=ad.canTriggerRender,getter=ad.getter,setter=ad.setter,allowNil=ad.allowNil}local bd=_d:sub(1,1):upper().._d:sub(2)
dc[
"get"..bd]=function(cd,...)db(1,cd,"element")local dd=cd._values[_d]
if type(dd)==
"function"and ad.type~="function"then dd=dd(cd)end
return ad.getter and ad.getter(cd,dd,...)or dd end
dc["set"..bd]=function(cd,dd,...)db(1,cd,"element")dd=cc(cd,_d,dd,ad)if
type(dd)~="function"then
if ad.type=="table"then if dd==nil then
if not ad.allowNil then db(2,dd,ad.type)end end else db(2,dd,ad.type)end end;if
ad.setter then dd=ad.setter(cd,dd,...)end
cd:_updateProperty(_d,dd)return cd end end
function ac.combineProperties(dc,_d,...)local ad={...}for cd,dd in pairs(ad)do
if not dc._properties[dd]then _c.error("Property not found: "..
dd)end end;local bd=
_d:sub(1,1):upper().._d:sub(2)
dc["get"..bd]=function(cd)
db(1,cd,"element")local dd={}
for __a,a_a in pairs(ad)do table.insert(dd,cd.get(a_a))end;return table.unpack(dd)end
dc["set"..bd]=function(cd,...)db(1,cd,"element")local dd={...}for __a,a_a in pairs(ad)do
cd.set(a_a,dd[__a])end;return cd end end
function ac.blueprint(dc,_d,ad,bd)
if not bc[dc]then
local dd={basalt=ad,__isBlueprint=true,_values=_d or{},_events={},render=function()end,dispatchEvent=function()end,init=function()end}
dd.loaded=function(a_a,b_a)a_a.loadedCallback=b_a;return dd end
dd.create=function(a_a)local b_a=dc.new()b_a:init({},a_a.basalt)for c_a,d_a in
pairs(a_a._values)do b_a._values[c_a]=d_a end
for c_a,d_a in
pairs(a_a._events)do for _aa,aaa in ipairs(d_a)do b_a[c_a](b_a,aaa)end end;if(bd~=nil)then bd:addChild(b_a)end
b_a:updateRender()a_a.loadedCallback(b_a)b_a:postInit()return b_a end;local __a=dc
while __a do
if rawget(__a,'_properties')then
for a_a,b_a in pairs(__a._properties)do if type(b_a.default)==
"table"then dd._values[a_a]=cb(b_a.default)else
dd._values[a_a]=b_a.default end end end
__a=getmetatable(__a)and rawget(getmetatable(__a),'__index')end;bc[dc]=dd end;local cd={_values={},_events={},loadedCallback=function()end}
cd.get=function(dd)
local __a=cd._values[dd]local a_a=dc._properties[dd]if type(__a)=="function"and
a_a.type~="function"then __a=__a(cd)end
return __a end
cd.set=function(dd,__a)cd._values[dd]=__a;return cd end
setmetatable(cd,{__index=function(dd,__a)
if __a:match("^on%u")then return
function(a_a,b_a)
dd._events[__a]=dd._events[__a]or{}table.insert(dd._events[__a],b_a)return dd end end
if __a:match("^get%u")then
local a_a=__a:sub(4,4):lower()..__a:sub(5)return function()return dd._values[a_a]end end;if __a:match("^set%u")then
local a_a=__a:sub(4,4):lower()..__a:sub(5)
return function(b_a,c_a)dd._values[a_a]=c_a;return dd end end;return
bc[dc][__a]end})return cd end
function ac.createFromBlueprint(dc,_d,ad)local bd=dc.new({},ad)
for cd,dd in pairs(_d._values)do if type(dd)=="table"then
bd._values[cd]=cb(dd)else bd._values[cd]=dd end end;return bd end
function ac:__init()self._values={}self._observers={}
self.set=function(cd,dd,...)
local __a=self._values[cd]local a_a=self._properties[cd]
if(a_a~=nil)then if(a_a.setter)then
dd=a_a.setter(self,dd,...)end
if a_a.canTriggerRender then self:updateRender()end;self._values[cd]=cc(self,cd,dd,a_a)if __a~=dd and
self._observers[cd]then
for b_a,c_a in ipairs(self._observers[cd])do c_a(self,dd,__a)end end end end
self.get=function(cd,...)local dd=self._values[cd]local __a=self._properties[cd]
if
(__a==nil)then _c.error("Property not found: "..cd)return end;if type(dd)=="function"and __a.type~="function"then
dd=dd(self)end;return
__a.getter and __a.getter(self,dd,...)or dd end;local dc={}local _d=getmetatable(self).__index
while _d do if
rawget(_d,'_properties')then
for cd,dd in pairs(_d._properties)do if not dc[cd]then dc[cd]=dd end end end;_d=getmetatable(_d)and
rawget(getmetatable(_d),'__index')end;self._properties=dc;local ad=getmetatable(self)local bd=ad.__index
setmetatable(self,{__index=function(cd,dd)
local __a=self._properties[dd]if __a then local a_a=self._values[dd]if type(a_a)=="function"and
__a.type~="function"then a_a=a_a(self)end
return a_a end;if
type(bd)=="function"then return bd(cd,dd)else return bd[dd]end end,__newindex=function(cd,dd,__a)
local a_a=self._properties[dd]
if a_a then if a_a.setter then __a=a_a.setter(self,__a)end
__a=cc(self,dd,__a,a_a)self:_updateProperty(dd,__a)else rawset(cd,dd,__a)end end,__tostring=function(cd)return
string.format("Object: %s (id: %s)",cd._values.type,cd.id)end})
for cd,dd in pairs(dc)do if self._values[cd]==nil then
if type(dd.default)=="table"then
self._values[cd]=cb(dd.default)else self._values[cd]=dd.default end end end;return self end
function ac:_updateProperty(dc,_d)local ad=self._values[dc]
if type(ad)=="function"then ad=ad(self)end;self._values[dc]=_d
local bd=type(_d)=="function"and _d(self)or _d
if ad~=bd then
if self._properties[dc].canTriggerRender then self:updateRender()end
if self._observers[dc]then for cd,dd in ipairs(self._observers[dc])do
dd(self,bd,ad)end end end;return self end
function ac:observe(dc,_d)
self._observers[dc]=self._observers[dc]or{}table.insert(self._observers[dc],_d)return self end
function ac:removeObserver(dc,_d)
if self._observers[dc]then
for ad,bd in ipairs(self._observers[dc])do if bd==_d then
table.remove(self._observers[dc],ad)
if#self._observers[dc]==0 then self._observers[dc]=nil end;break end end end;return self end;function ac:removeAllObservers(dc)
if dc then self._observers[dc]=nil else self._observers={}end;return self end
function ac:instanceProperty(dc,_d)
ac.defineProperty(self,dc,_d)self._values[dc]=_d.default;return self end
function ac:removeProperty(dc)self._values[dc]=nil;self._properties[dc]=nil;self._observers[dc]=
nil
local _d=dc:sub(1,1):upper()..dc:sub(2)self["get".._d]=nil;self["set".._d]=nil;return self end
function ac:getPropertyConfig(dc)return self._properties[dc]end;return ac end
_b["init.lua"]=function(...)local bc={...}local cc=fs.getDir(bc[2])local dc=package.path
local _d="path;/path/?.lua;/path/?/init.lua;"local ad=_d:gsub("path",cc)package.path=ad.."rom/?;"..dc
local function bd(__a)package.path=
ad.."rom/?"local a_a=require("errorManager")
package.path=dc;a_a.header="Basalt Loading Error"a_a.error(__a)end;local cd,dd=pcall(require,"main")package.loaded.log=nil
package.path=dc;if not cd then bd(dd)else return dd end end
_b["errorManager.lua"]=function(...)local cb=require("log")
local db={tracebackEnabled=true,header="Basalt Error"}local function _c(ac,bc)term.setTextColor(bc)print(ac)
term.setTextColor(colors.white)end
function db.error(ac)
if db.errorHandled then error()end;term.setBackgroundColor(colors.black)
term.clear()term.setCursorPos(1,1)
_c(db.header..":",colors.red)print()local bc=2;local cc;while true do local cd=debug.getinfo(bc,"Sl")
if not cd then break end;cc=cd;bc=bc+1 end;local dc=cc or
debug.getinfo(2,"Sl")local _d=dc.source:sub(2)
local ad=dc.currentline;local bd=ac
if(db.tracebackEnabled)then local cd=debug.traceback()
if cd then
for dd in cd:gmatch("[^\r\n]+")do
local __a,a_a=dd:match("([^:]+):(%d+):")
if __a and a_a then term.setTextColor(colors.lightGray)
term.write(__a)term.setTextColor(colors.gray)term.write(":")
term.setTextColor(colors.lightBlue)term.write(a_a)term.setTextColor(colors.gray)dd=dd:gsub(
__a..":"..a_a,"")end;_c(dd,colors.gray)end;print()end end
if _d and ad then term.setTextColor(colors.red)
term.write("Error in ")term.setTextColor(colors.white)term.write(_d)
term.setTextColor(colors.red)term.write(":")
term.setTextColor(colors.lightBlue)term.write(ad)term.setTextColor(colors.red)
term.write(": ")
if bd then bd=string.gsub(bd,"stack traceback:.*","")
if bd~=""then
_c(bd,colors.red)else _c("Error message not available",colors.gray)end else _c("Error message not available",colors.gray)end;local cd=fs.open(_d,"r")
if cd then local dd=""local __a=1
repeat dd=cd.readLine()if
__a==tonumber(ad)then _c("\149Line "..ad,colors.cyan)
_c(dd,colors.lightGray)break end;__a=__a+1 until not dd;cd.close()end end;term.setBackgroundColor(colors.black)
cb.error(ac)db.errorHandled=true;error()end;return db end;return _b["main.lua"]() end
modules["elements.TabView"] = function() local _a=require("libraries.basalt")local aa=_a.LOGGER
local ba={LEFT=1,RIGHT=2}local ca={}ca.__index=ca
function ca:new(da,_b,ab,bb,cb,db,_c,ac,bc)local cc=setmetatable({},ca)cc.frame=da;self.selectedTab=
nil;self.firstTab=nil;self.lastTab=nil;cc.leftIcon="\17"
cc.rightIcon="\16"cc.vSep="|"cc.tabs={}cc.vSepLabel={}cc.firstTabidx=1
cc.tabBg=db or colors.black;cc.tabFg=_c or colors.white
cc.bottomFrameBg=ac or colors.lightGray;cc.bottomFrameFg=bc or colors.white
cc.frame:setPosition(_b,ab):setSize(bb,cb):setBackground(cc.tabBg):setForeground(cc.tabFg)
cc.topFrame=cc.frame:addFrame():setPosition(1,1):setSize(da:getWidth(),1):setBackground(cc.tabBg):setForeground(cc.tabFg)
cc.leftIconLabel=cc.topFrame:addLabel():setText(cc.leftIcon):setPosition(1,1):setBackground(cc.tabBg):setForeground(cc.tabFg):setBackgroundEnabled(true):setAutoSize(true):onClick(function()
cc:updateTabBar(
cc.lastTab and cc.lastTab.idx or 0,ba.LEFT)end)
cc.rightIconLabel=cc.topFrame:addLabel():setText(cc.rightIcon):setPosition(cc.topFrame:getWidth(),1):setBackground(cc.tabBg):setForeground(cc.tabFg):setAutoSize(true):setBackgroundEnabled(true):onClick(function()
cc:updateTabBar(
cc.firstTab and cc.firstTab.idx or 0,ba.RIGHT)end)
cc.bottomFrame=cc.frame:addFrame():setPosition(1,2):setSize(da:getWidth(),
da:getHeight()-1):setBackground(cc.bottomFrameBg):setForeground(cc.bottomFrameFg)return cc end
function ca:selectTab(da)if da.selected then
aa.debug("Tab "..da.name.." is already selected.")return end
for _b,ab in ipairs(self.tabs)do
if ab.selected then
ab.selected=false;ab.label:setBackground(self.tabBg)
ab.label:setForeground(self.tabFg)ab.frame:setVisible(false)end end
if da then self.selectedTab=da;da.selected=true
da.label:setBackground(self.bottomFrameBg)da.label:setForeground(self.bottomFrameFg)
da.frame:setVisible(true)end;if da.onSelect~=nil then da:onSelect()end end
function ca:createTab(da)aa.debug("Creating tab: "..da)local _b={}
_b.name=da;_b.idx=#self.tabs+1;_b.selected=false
_b.label=self.topFrame:addLabel():setText(
" "..da.." "):setBackground(self.tabBg):setForeground(self.tabFg):setAutoSize(true):setBackgroundEnabled(true):setVisible(false):onClick(function()
self:selectTab(_b)end)
_b.frame=self.bottomFrame:addFrame():setPosition(1,1):setSize(self.bottomFrame:getWidth(),self.bottomFrame:getHeight()):setBackground(self.bottomFrameBg):setForeground(self.bottomFrameFg):setVisible(false)table.insert(self.tabs,_b)
return self.tabs[#self.tabs]end
function ca:getVSepLabel(da)
if not self.vSepLabel[da]then
self.vSepLabel[da]=self.topFrame:addLabel():setText(self.vSep):setBackground(self.tabBg):setForeground(self.tabFg):setAutoSize(true):setBackgroundEnabled(true)end;return self.vSepLabel[da]end;function ca:nextTab(da)local _b=da+1;if _b>#self.tabs then _b=1 end
return self.tabs[_b]end
function ca:prevTab(da)local _b=da-1;if _b<1 then
_b=#self.tabs end;return self.tabs[_b]end
function ca:displayTopFrameLabel(da,_b,ab)local bb
if ab==ba.LEFT then bb=da:getX()-_b:getWidth()else bb=
da:getX()+da:getWidth()end;local cb=da:getY()
aa.debug("Setting label position to: "..bb..", "..cb)_b:setPosition(bb,cb)_b:setVisible(true)end
function ca:updateTabBar(da,_b)
aa.debug("==================================================")if#self.tabs==0 then return end;for dc,_d in ipairs(self.tabs)do
_d.label:setVisible(false)end;for dc,_d in pairs(self.vSepLabel)do
_d:setVisible(false)end;local ab=1;local bb=self:getVSepLabel(ab)
local cb=(_b==
ba.LEFT)and self.rightIconLabel or self.leftIconLabel;self:displayTopFrameLabel(cb,bb,_b)local db=0;local _c=da;local ac=
self.topFrame:getWidth()-2;local bc={}
for i=1,#self.tabs do
local dc=(_b==ba.LEFT)and
self:prevTab(_c)or self:nextTab(_c)if i==1 then
if _b==ba.RIGHT then self.firstTab=dc else self.lastTab=dc end end;local _d=dc.label:getWidth()+
bb:getWidth()
if db+_d<=ac then
table.insert(bc,dc)db=db+_d
if _b==ba.LEFT then self.firstTab=dc else self.lastTab=dc end else
aa.debug("Tab bar is full, hiding tab: "..dc.name)dc.label:setVisible(false)end;_c=dc.idx end;ab=1;bb=self:getVSepLabel(ab)local cc=cb
for dc,_d in ipairs(bc)do
_d.label:setVisible(true)self:displayTopFrameLabel(cc,bb,_b)
self:displayTopFrameLabel(bb,_d.label,_b)ab=ab+1;cc=_d.label;bb=self:getVSepLabel(ab)end;self:displayTopFrameLabel(cc,bb,_b)
self:displayTopFrameLabel(bb,
(_b==ba.LEFT)and self.leftIconLabel or self.rightIconLabel,_b)
aa.debug("firstTab: "..
(self.firstTab and self.firstTab.name or"nil")..
" LastTab: ".. (self.lastTab and self.lastTab.name or"nil"))end
function ca:init()self:updateTabBar(0,ba.RIGHT)if#self.tabs>0 then
self:selectTab(self.tabs[1])end end;function ca:getTabByName(da)
for _b,ab in ipairs(self.tabs)do if ab.name==da then return ab end end;return nil end;function ca:getTabByIndex(da)if
da<1 or da>#self.tabs then return nil end
return self.tabs[da]end;return ca end
modules["programs.transfer.TransferTab"] = function() local bc=require("utils.StringUtils")
local cc=require("wrapper.PeripheralWrapper")local dc=require("utils.OSUtils")
local _d=require("utils.Logger")local ad=require("elements.TabView")
local bd=require("elements.ItemSelectedListBox")local cd=require("utils.TableUtils")
local dd=require("programs.transfer.TransferJobManager")local __a=require("elements.MessageBox")
local a_a=require("elements.ConfirmMessageBox")local b_a=require("programs.transfer.Triggers")local c_a=colors
local d_a=textutils
local _aa=function(caa,daa)local _ba={}local aba={}for bba,cba in pairs(daa)do _ba[bba]=true
table.insert(aba,{text=bba,name=bba,selected=true})end
for bba,cba in pairs(caa)do
if
cc.isInventory(cba)or cc.isTank(cba)then if not _ba[bba]then _ba[bba]=true
table.insert(aba,{text=bba,name=bba,selected=false})end end end;return aba end
local aaa=function(caa,daa)local _ba={}local aba={}for bba,cba in pairs(daa)do _ba[bba]=true
table.insert(aba,{text=bba,name=bba,type=cba,selected=true})end
for bba,cba in pairs(caa)do
_d.debug("Peripheral: "..bba)
if cba.isInventory()then local dba=cba.getItems()
for _ca,aca in pairs(dba)do
if aca.name and
not _ba[aca.name]then _ba[aca.name]=true
table.insert(aba,{text=aca.displayName or aca.name,name=aca.name,type="item",selected=false})end end end
if cba.isTank()then local dba=cba.tanks()
for _ca,aca in pairs(dba)do
if
aca.name and not _ba[aca.name]then _ba[aca.name]=true
table.insert(aba,{text=aca.displayName or aca.name,name=aca.name,type="fluid",selected=false})end end end end;return aba end;local baa={}baa.__index=baa
function baa:new(caa)local daa=setmetatable({},baa)
daa.pframe=caa
daa.frame=caa:addFrame():setPosition(1,1):setSize(caa:getWidth(),caa:getHeight()):setBackground(c_a.lightGray):setForeground(c_a.white)
daa.list=daa.frame:addList():setPosition(2,2):setSize(18,
daa.frame:getHeight()-4):setBackground(c_a.gray):setForeground(c_a.white)
daa.addButton=daa.frame:addButton():setPosition(2,daa.list:getY()+
daa.list:getHeight()+1):setSize(5,1):setText(" New "):setBackground(c_a.green):setForeground(c_a.black):onClick(function()daa:openDetail(
nil)end)
daa.editBtn=daa.frame:addButton():setPosition(
daa.addButton:getX()+daa.addButton:getWidth()+1,daa.addButton:getY()):setSize(6,1):setText(" Edit "):setBackground(c_a.yellow):setForeground(c_a.black):onClick(function()
local _ba=daa.list:getSelectedItem()if not _ba then
daa.messageBox:open("Warning","No transfer selected")return end
daa:openDetail(dd.getTransfer(_ba.id))end)
daa.delBtn=daa.frame:addButton():setPosition(daa.editBtn:getX()+
daa.editBtn:getWidth()+1,daa.editBtn:getY()):setSize(5,1):setText(" Del "):setBackground(c_a.red):setForeground(c_a.black):onClick(function()
local _ba=daa.list:getSelectedItem()if not _ba then
daa.messageBox:open("Warning","No transfer selected")return end
daa.confirmMessageBox:open("Confirm Delete","Are you sure you want to delete this transfer?",function()
dd.removeTransfer(_ba.id)daa:openDetail(nil)daa:updateTransferList()end)end)
daa.tabView=ad:new(daa.frame:addFrame(),daa.list:getX()+
daa.list:getWidth()+1,2,daa.frame:getWidth()-
daa.list:getWidth()-3,daa.frame:getHeight()-2,c_a.lightGray,c_a.white,c_a.gray,c_a.white)daa.detailsTab=daa.tabView:createTab("Detail")
daa.detailsTabFrame=daa.detailsTab.frame
daa.nameInput=daa.detailsTabFrame:addInput():setPosition(2,2):setSize(
daa.detailsTabFrame:getWidth()-2,1):setBackground(c_a.lightGray):setForeground(c_a.white):setPlaceholderColor(c_a.gray):setPlaceholder("Transfer Name")
daa.idLabel=daa.detailsTabFrame:addLabel():setText(bc.ellipsisMiddle("ID: nil",
daa.detailsTabFrame:getWidth()-4)):setSize(
daa.detailsTabFrame:getWidth()-4,1):setPosition(2,
daa.nameInput:getY()+daa.nameInput:getHeight()+1):setAutoSize(false):setForeground(c_a.white)
daa.newIdBtn=daa.detailsTabFrame:addButton():setPosition(
daa.idLabel:getX()+daa.idLabel:getWidth()+1,daa.idLabel:getY()):setSize(1,1):setText("N"):setBackground(c_a.lightGray):setForeground(c_a.white):onClick(function()
if
daa.selectedTransfer then
daa.selectedTransfer.id=dc.timestampBaseIdGenerate()
daa.idLabel:setText(bc.ellipsisMiddle(string.format("ID: %s",daa.selectedTransfer.id),daa.idLabel:getWidth()))end end)
daa.inputInvLabel=daa.detailsTabFrame:addLabel():setText("Input: 0"):setPosition(2,
daa.idLabel:getY()+daa.idLabel:getHeight()+1):setForeground(c_a.white)
daa.editInputSlots=daa.detailsTabFrame:addButton():setPosition(
daa.detailsTabFrame:getWidth()-9,daa.inputInvLabel:getY()):setSize(5,1):setText("Slots"):setBackground(c_a.lightGray):setForeground(c_a.white):onClick(function()
daa:openSlotSelector("input")end)
daa.editinputInv=daa.detailsTabFrame:addButton():setPosition(
daa.detailsTabFrame:getWidth()-3,daa.inputInvLabel:getY()):setSize(3,1):setText("..."):setBackground(c_a.blue):setForeground(c_a.white):onClick(function()
cc.reloadAll()local _ba=cc.getAll()_d.debug("Peripherals: ")
local aba=_aa(_ba,daa.selectedTransfer and
daa.selectedTransfer.inputInv or{})
daa.itemListBox:open(aba,true,{confirm=function(bba)local cba={}
for dba,_ca in pairs(bba)do cba[_ca.name]=true end;daa.selectedTransfer.inputInv=cba
daa.inputInvLabel:setText(string.format("Input: %d",cd.getLength(cba)))end})end)
daa.outputInvLabel=daa.detailsTabFrame:addLabel():setText("Output: 0"):setPosition(2,
daa.inputInvLabel:getY()+daa.inputInvLabel:getHeight()):setForeground(c_a.white)
daa.editOutputSlots=daa.detailsTabFrame:addButton():setPosition(
daa.detailsTabFrame:getWidth()-9,daa.outputInvLabel:getY()):setSize(5,1):setText("Slots"):setBackground(c_a.lightGray):setForeground(c_a.white):onClick(function()
daa:openSlotSelector("output")end)
daa.editoutputInv=daa.detailsTabFrame:addButton():setPosition(
daa.detailsTabFrame:getWidth()-3,daa.outputInvLabel:getY()):setSize(3,1):setText("..."):setBackground(c_a.blue):setForeground(c_a.white):onClick(function()
cc.reloadAll()local _ba=cc.getAll()
local aba=_aa(_ba,
daa.selectedTransfer and daa.selectedTransfer.outputInv or{})
daa.itemListBox:open(aba,true,{confirm=function(bba)local cba={}
for dba,_ca in pairs(bba)do cba[_ca.name]=true end;daa.selectedTransfer.outputInv=cba
daa.outputInvLabel:setText(string.format("Output: %d",cd.getLength(cba)))end})end)
daa.itemLabel=daa.detailsTabFrame:addLabel():setText("Item Filter: 0"):setPosition(2,
daa.outputInvLabel:getY()+daa.outputInvLabel:getHeight()):setForeground(c_a.white):setAutoSize(false)
daa.editItemBtn=daa.detailsTabFrame:addButton():setPosition(
daa.detailsTabFrame:getWidth()-3,daa.itemLabel:getY()):setSize(3,1):setText("..."):setBackground(c_a.blue):setForeground(c_a.white):onClick(function()
local _ba=cc.getAll()
local aba=aaa(_ba,daa.selectedTransfer and daa.selectedTransfer.itemFilter or{})
daa.itemListBox:open(aba,true,{confirm=function(bba)local cba={}
for dba,_ca in pairs(bba)do cba[_ca.name]=_ca.type end;daa.selectedTransfer.itemFilter=cba
daa.itemLabel:setText(string.format("Item Filter: %d",cd.getLength(cba)))end})end)
daa.itemRateLabel=daa.detailsTabFrame:addLabel():setText("I-R:"):setPosition(2,
daa.itemLabel:getY()+daa.itemLabel:getHeight()):setForeground(c_a.white)
daa.itemRateInput=daa.detailsTabFrame:addInput():setPosition(
daa.itemRateLabel:getX()+daa.itemRateLabel:getWidth()+1,daa.itemRateLabel:getY()):setSize(8,1):setBackground(c_a.lightGray):setForeground(c_a.white):setText("-1"):setPlaceholder("-1")
daa.fluidRateLabel=daa.detailsTabFrame:addLabel():setText("F-R:"):setPosition(
daa.itemRateInput:getX()+daa.itemRateInput:getWidth()+2,daa.itemRateLabel:getY()):setForeground(c_a.white)
daa.fluidRateInput=daa.detailsTabFrame:addInput():setPosition(
daa.fluidRateLabel:getX()+daa.fluidRateLabel:getWidth()+1,daa.fluidRateLabel:getY()):setSize(8,1):setBackground(c_a.lightGray):setForeground(c_a.white):setText("-1"):setPlaceholder("-1")
daa.isBlackListCheckBox=daa.detailsTabFrame:addCheckbox():setSize(1,1):setBackground(c_a.gray):setForeground(c_a.white):setText("[ ] BlackList"):setCheckedText("[x] BlackList"):setChecked(false):setPosition(2,
daa.itemRateLabel:getY()+daa.itemRateLabel:getHeight())
daa.isDisabledCheckBox=daa.detailsTabFrame:addCheckbox():setSize(1,1):setBackground(c_a.gray):setForeground(c_a.white):setText("[ ] Disabled"):setCheckedText("[x] Disabled"):setChecked(false):setPosition(

daa.isBlackListCheckBox:getX()+daa.isBlackListCheckBox:getWidth()+3,daa.isBlackListCheckBox:getY())
daa.setTriggerBtn=daa.detailsTabFrame:addButton():setPosition(2,

daa.isBlackListCheckBox:getY()+daa.isBlackListCheckBox:getHeight()+1):setSize(10,1):setText("SetTrigger"):setBackground(c_a.blue):setForeground(c_a.white):onClick(function()
daa:openTriggerInterface()end)
daa.clearTriggerBtn=daa.detailsTabFrame:addButton():setPosition(
daa.setTriggerBtn:getX()+daa.setTriggerBtn:getWidth()+1,daa.setTriggerBtn:getY()):setSize(11,1):setText("ClearTrigger"):setBackground(c_a.red):setForeground(c_a.white):onClick(function()
daa:clearTriggerWithConfirm()end)
daa.saveBtn=daa.detailsTabFrame:addButton():setPosition(
daa.detailsTabFrame:getWidth()-6,daa.detailsTabFrame:getHeight()-1):setSize(6,1):setText(" Save "):setBackground(c_a.green):setForeground(c_a.black):onClick(function()if
daa.selectedTransfer==nil then
daa.messageBox:open("Error","No transfer to save")return end;daa.selectedTransfer.name=
daa.nameInput:getText()or"unnamed"
daa.selectedTransfer.isBlackList=daa.isBlackListCheckBox:getChecked()
daa.selectedTransfer.isDisabled=daa.isDisabledCheckBox:getChecked()daa.selectedTransfer.itemRate=
tonumber(daa.itemRateInput:getText())or-1;daa.selectedTransfer.fluidRate=
tonumber(daa.fluidRateInput:getText())or-1
dd.addTransfer(daa.selectedTransfer)daa:updateTransferList()end)daa.srcTab=daa.tabView:createTab("Source")
daa.srcTextBox=daa.srcTab.frame:addTextBox():setPosition(2,2):setSize(
daa.srcTab.frame:getWidth()-2,daa.srcTab.frame:getHeight()-2):setBackground(c_a.lightGray):setForeground(c_a.white):setText("")
daa.srcTab.onSelect=function()daa:updateSrcText()end;daa.trigger=b_a:new(daa.pframe)
daa.itemListBox=bd:new(daa.pframe)daa.messageBox=__a:new(daa.pframe,40,15)
daa.confirmMessageBox=a_a:new(daa.pframe,40,10)return daa end;function baa:init()self.tabView:init()self:openDetail(nil)
self:updateTransferList()return self end
function baa:updateSrcText()self.selectedTransfer.name=
self.nameInput:getText()or"unnamed"
self.selectedTransfer.isBlackList=self.isBlackListCheckBox:getChecked()
self.selectedTransfer.isDisabled=self.isDisabledCheckBox:getChecked()
self.srcTextBox:setText(d_a.serialize(self.selectedTransfer or{}))end
function baa:updateTransferList()local caa=dd.getAllTransfers()local daa={}for _ba,aba in pairs(caa)do
table.insert(daa,{text=
aba.name or"unnamed",id=aba.id})end
self.list:setItems(daa)end
function baa:openDetail(caa)
if(caa==nil)then
self.selectedTransfer={id=dc.timestampBaseIdGenerate(),name="unnamed",inputInv={},outputInv={},inputSlots={},outputSlots={},itemFilter={},itemRate=-1,fluidRate=-1,isBlackList=false,isDisabled=false,triggerStatement={id="root"}}
self.nameInput:setText(self.selectedTransfer.name)self.inputInvLabel:setText("Input: 0")
self.outputInvLabel:setText("Output: 0")self.itemLabel:setText("Item Filter: 0")
self.itemRateInput:setText("-1")self.fluidRateInput:setText("-1")
self.isBlackListCheckBox:setChecked(false)
self.idLabel:setText(bc.ellipsisMiddle(string.format("ID: %s",self.selectedTransfer.id),self.idLabel:getWidth()))self.isDisabledCheckBox:setChecked(false)else
self.selectedTransfer=caa;if not self.selectedTransfer.inputSlots then
self.selectedTransfer.inputSlots={}end
if
not self.selectedTransfer.outputSlots then self.selectedTransfer.outputSlots={}end;if not self.selectedTransfer.itemRate then
self.selectedTransfer.itemRate=-1 end
if
not self.selectedTransfer.fluidRate then self.selectedTransfer.fluidRate=-1 end;if not self.selectedTransfer.triggerStatement then
self.selectedTransfer.triggerStatement={id="root"}end
self.nameInput:setText(
self.selectedTransfer.name or"unnamed")
self.inputInvLabel:setText(string.format("Input: %d",cd.getLength(self.selectedTransfer.inputInv)))
self.outputInvLabel:setText(string.format("Output: %d",cd.getLength(self.selectedTransfer.outputInv)))
self.itemLabel:setText(string.format("Item Filter: %d",cd.getLength(self.selectedTransfer.itemFilter)))
self.itemRateInput:setText(tostring(self.selectedTransfer.itemRate))
self.fluidRateInput:setText(tostring(self.selectedTransfer.fluidRate))
self.isBlackListCheckBox:setChecked(self.selectedTransfer.isBlackList or false)
self.idLabel:setText(bc.ellipsisMiddle(string.format("ID: %s",self.selectedTransfer.id),self.idLabel:getWidth()))
self.isDisabledCheckBox:setChecked(self.selectedTransfer.isDisabled or false)end;return self.frame end
function baa:openSlotSelector(caa)cc.reloadAll()local daa=cc.getAll()local _ba=
caa=="input"and"inputInv"or"outputInv"local aba=
caa=="input"and"inputSlots"or"outputSlots"
local bba=caa=="input"and
"No DEFAULT_INVENTORY found in input peripherals"or"No DEFAULT_INVENTORY found in output peripherals"local cba=0
for bca,cca in pairs(daa)do
if

self.selectedTransfer and self.selectedTransfer[_ba]and self.selectedTransfer[_ba][bca]then local dca=cca.getTypes()
for _da,ada in ipairs(dca)do if ada==1 then local bda=cca.size()
if bda>cba then cba=bda end;break end end end end
if cba==0 then self.messageBox:open("Warning",bba)return end;local dba={}
local _ca=self.selectedTransfer and self.selectedTransfer[aba]or{}local aca={}if type(_ca)=="table"then
for bca,cca in ipairs(_ca)do aca[tostring(cca)]=true end end;for i=1,cba do
table.insert(dba,{text="Slot "..i,slotId=i,selected=
aca[tostring(i)]or false})end
self.itemListBox:open(dba,true,{confirm=function(bca)
local cca={}
for dca,_da in pairs(bca)do table.insert(cca,_da.slotId)end;self.selectedTransfer[aba]=cca end})end
function baa:openTriggerInterface()if not self.selectedTransfer then
self.messageBox:open("Error","No transfer selected")return end;local caa=
self.selectedTransfer.triggerStatement or{id="root"}
self.trigger:open(caa,function(daa)
self.selectedTransfer.triggerStatement=daa end)end
function baa:clearTriggerWithConfirm()if not self.selectedTransfer then
self.messageBox:open("Error","No transfer selected")return end
self.confirmMessageBox:open("Confirm Clear Trigger","Are you sure you want to clear the trigger statement?",function()
self.selectedTransfer.triggerStatement={id="root"}end)end;return baa end
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
_a.isUnlimitedPeripheralInventory=function()return d._isUnlimitedPeripheralInventory end end
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
if ab~=nil and ab.name==ba then
local bb=_a.pushItems(aa.getName(),slot,ca)if bb==0 then return _b end;_b=_b+bb;ca=ca-bb end;if ca<=0 then return _b end end;return _b elseif aa.isUnlimitedPeripheralInventory()then local da=0
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
_a.transferItemFrom=function(aa,ba,ca)local da=0
while da<ca do
local _b=_a.pushItem(aa.getName(),ba,ca-da)if _b==0 then return da end;da=da+_b end;return da end
_a.transferItemTo=function(aa,ba,ca)local da=0
while da<ca do
local _b=_a.pullItem(aa.getName(),ba,ca-da)if _b==0 then return da end;da=da+_b end;return da end else error("Peripheral is not an inventory")end end
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
modules["programs.transfer.TransferJobManager"] = function() local da=require("utils.OSUtils")
local _b=require("wrapper.PeripheralWrapper")local ab={}local bb=require("utils.Logger")
ab.TRIGGER_TYPES={FLUID_COUNT="fluid_count",ITEM_COUNT="item_count",ITEM_COUNT_AT_SLOTS="item_count_at_slot",REDSTONE_SIGNAL="redstone_signal"}
ab.TRIGGER_CONDITION_TYPES={COUNT_GREATER="count_greater",COUNT_LESS="count_less",COUNT_EQUAL="count_equal"}ab.transfers={}
ab.load=function()local bc=da.loadTable("transfers")if bc~=nil then
ab.transfers=bc end end
ab.save=function()da.saveTable("transfers",ab.transfers)end
ab.addTransfer=function(bc)ab.transfers[bc.id]=bc;ab.save()end
ab.removeTransfer=function(bc)ab.transfers[bc]=nil;ab.save()end
ab.getTransfer=function(bc)return
textutils.unserialize(textutils.serialize(ab.transfers[bc]))end
ab.getAllTransfers=function()return
textutils.unserialize(textutils.serialize(ab.transfers))end
ab.exec=function()local bc=ab.buildJobsFns()
if#bc>0 then
local cc,dc=pcall(function()
parallel.waitForAll(table.unpack(bc))end)if not cc then
bb.error("Error executing transfer jobs: {}",dc)end end end
ab.buildJobsFns=function()local bc={}
for cc,dc in pairs(ab.transfers)do
if not dc.isDisabled then
local _d=ab.evalTrigger(dc.triggerStatement)
if _d then
table.insert(bc,function()
local ad,bd=pcall(function()
bb.info("Starting transfer job: {} (ID: {})",dc.name,dc.id)
for cd,dd in pairs(dc.inputInv)do
local __a=ab.transferItem(cd,dc.outputInv,dc.itemFilter,dc.isBlackList,dc.inputSlots,dc.outputSlots,dc.itemRate,dc.fluidRate)
if __a.itemCount>0 or __a.fluidCount>0 then
bb.info("Transfer job '{}' transferred {} items and {} fluid units from {}",dc.name,__a.itemCount,__a.fluidCount,cd)end end;bb.info("Completed transfer job: {}",dc.name)end)if not ad then
bb.error("Error executing transfer job '{}' (ID: {}): {}",dc.name,dc.id,bd)end end)else
bb.debug("Transfer job '{}' skipped: trigger conditions not met",dc.name)end end end;return bc end;local function cb(bc,cc,dc)
if cc==nil or#cc==0 then local _d=bc.size()for slot=1,_d do dc(slot)end else for _d,ad in ipairs(cc)do
dc(ad)end end end;local function db(bc,cc,dc)
if cc==
nil or next(cc)==nil then return dc else local _d=cc[bc]~=nil;return dc and(not _d)or(
not dc and _d)end end
local function _c(bc,cc,dc,_d,ad,bd)
local cd=0;local dd=_d;if bd and bd>=0 then dd=math.min(_d,bd)end
for __a,a_a in pairs(cc)do
local b_a=_b.getByName(__a)if b_a==nil then
error("Output inventory '"..__a.."' not found")end
while dd>cd do local c_a
if ad then
c_a=bc.transferFluidTo(b_a,dc,dd-cd)else c_a=bc.transferItemTo(b_a,dc,dd-cd)end;if c_a==0 then break end;cd=cd+c_a end;if cd>=dd then break end end;return cd end
local function ac(bc,cc,dc,_d,ad,bd,cd)local dd=0;local __a=cd;if not bc.isDefaultInventory()then
bb.warn("Slot-specific transfer requires DEFAULT_INVENTORY type for input: {}",bc.getName())return 0 end
cb(bc,ad,function(a_a)if
cd>=0 and __a<=0 then return end;local b_a=bc.getItemDetail(a_a)
if
b_a and db(b_a.name,dc,_d)then local c_a=b_a.count;if cd>=0 then
c_a=math.min(c_a,__a)end
for d_a,_aa in pairs(cc)do if c_a<=0 then break end
local aaa=_b.getByName(d_a)
if aaa and aaa.isDefaultInventory()then
if bd and next(bd)~=nil then
for baa,caa in
ipairs(bd)do if c_a<=0 then break end;local daa=bc.pushItems(d_a,a_a,c_a,caa)
if daa>0 then
dd=dd+daa;c_a=c_a-daa;if cd>=0 then __a=__a-daa end end end else local baa=bc.pushItems(d_a,a_a,c_a)if baa>0 then dd=dd+baa;c_a=c_a-baa;if cd>=0 then __a=
__a-baa end end end else
if not aaa then bb.warn("Output inventory not found: {}",d_a)else
bb.warn("Slot-specific transfer requires DEFAULT_INVENTORY type for output: {}",d_a)end end end end end)return dd end
ab.transferItem=function(bc,cc,dc,_d,ad,bd,cd,dd)local __a=_b.getByName(bc)if __a==nil then
error("Input inventory '"..bc.."' not found")end;local a_a=0;local b_a=0;local c_a=cd or-1;local d_a=dd or-1
if
__a.isTank()then local _aa=__a.getFluids()or{}
for aaa,baa in pairs(_aa)do if
dd and dd>=0 and d_a<=0 then break end
if db(baa.name,dc,_d)then local caa=baa.amount;if dd and dd>=0 then
caa=math.min(baa.amount,d_a)end
local daa=_c(__a,cc,baa.name,caa,true,dd and dd>=0 and d_a or nil)
if daa>0 then b_a=b_a+daa;if dd and dd>=0 then d_a=d_a-daa end end end end end
if __a.isInventory()then
if
(ad and next(ad)~=nil)or(bd and next(bd)~=nil)then local _aa=ac(__a,cc,dc,_d,ad,bd,c_a)a_a=a_a+_aa else
local _aa=__a:getItems()
if _aa~=nil and#_aa>0 then
for aaa,baa in ipairs(_aa)do
if cd and cd>=0 and c_a<=0 then break end
if db(baa.name,dc,_d)then local caa=baa.count;if cd and cd>=0 then
caa=math.min(baa.count,c_a)end
local daa=_c(__a,cc,baa.name,caa,false,cd and cd>=0 and c_a or nil)
if daa>0 then a_a=a_a+daa;if cd and cd>=0 then c_a=c_a-daa end end end end end end end;return{itemCount=a_a,fluidCount=b_a}end
ab.evalTrigger=function(bc)if not bc or not bc.children then return true end
for cc,dc in
ipairs(bc.children)do
bb.debug("Evaluating child node: {}",dc.data and dc.data.name or"Unnamed")if ab.evalTriggerNode(dc)then return true end end;return false end
ab.evalTriggerNode=function(bc)if not bc or not bc.data then return true end
local cc=bc.data;local dc=false
if cc.triggerType==ab.TRIGGER_TYPES.ITEM_COUNT then
dc=ab.evalItemCountTrigger(cc)elseif cc.triggerType==ab.TRIGGER_TYPES.FLUID_COUNT then
dc=ab.evalFluidCountTrigger(cc)elseif cc.triggerType==ab.TRIGGER_TYPES.ITEM_COUNT_AT_SLOTS then
dc=ab.evalItemCountAtSlotsTrigger(cc)elseif cc.triggerType==ab.TRIGGER_TYPES.REDSTONE_SIGNAL then
dc=ab.evalRedstoneSignalTrigger(cc)else
bb.warn("Unknown trigger type: {}",cc.triggerType)return true end;local _d=true
if bc.children and#bc.children>0 then _d=false
for ad,bd in
ipairs(bc.children)do if ab.evalTriggerNode(bd)then _d=true
bb.debug("Child node passed: {}",bd.data.name)break end end end;return dc and _d end
ab.evalItemCountTrigger=function(bc)
if not bc.targetPeripheralId or not bc.itemName then
bb.warn("Invalid ITEM_COUNT trigger data: missing targetPeripheralId or itemName")return false end;local cc=_b.getByName(bc.targetPeripheralId)if not cc or not
cc.isInventory()then
bb.warn("Peripheral not found or not an inventory: {}",bc.targetPeripheralId)return false end
local dc,_d=cc.getItems()local ad=0
if _d and _d[bc.itemName]then ad=_d[bc.itemName].count end
return ab.evalCondition(ad,bc.amount,bc.triggerConditionType)end
ab.evalFluidCountTrigger=function(bc)
if not bc.targetPeripheralId or not bc.itemName then
bb.warn("Invalid FLUID_COUNT trigger data: missing targetPeripheralId or itemName")return false end;local cc=_b.getByName(bc.targetPeripheralId)if not cc or
not cc.isTank()then
bb.warn("Peripheral not found or not a tank: {}",bc.targetPeripheralId)return false end
local dc=cc.getFluids()local _d=0
if dc then for ad,bd in pairs(dc)do
if bd.name==bc.itemName then _d=_d+bd.amount end end end
return ab.evalCondition(_d,bc.amount,bc.triggerConditionType)end
ab.evalItemCountAtSlotsTrigger=function(bc)
if
not bc.targetPeripheralId or not bc.itemName or not bc.selectedSlot then
bb.warn("Invalid ITEM_COUNT_AT_SLOTS trigger data: missing required fields")return false end;local cc=_b.getByName(bc.targetPeripheralId)if not cc then
bb.warn("Peripheral not found: {}",bc.targetPeripheralId)return false end
if not
cc.isDefaultInventory()then
bb.warn("ITEM_COUNT_AT_SLOTS trigger requires DEFAULT_INVENTORY type peripheral: {}",bc.targetPeripheralId)return false end;local dc=cc.getItemDetail(bc.selectedSlot)local _d=0;if dc and
dc.name==bc.itemName then _d=dc.count end;return
ab.evalCondition(_d,bc.amount,bc.triggerConditionType)end
ab.evalRedstoneSignalTrigger=function(bc)
bb.warn("REDSTONE_SIGNAL trigger not implemented yet")return true end
ab.evalCondition=function(bc,cc,dc)
if dc==ab.TRIGGER_CONDITION_TYPES.COUNT_GREATER then
return bc>cc elseif dc==ab.TRIGGER_CONDITION_TYPES.COUNT_LESS then return bc<cc elseif dc==
ab.TRIGGER_CONDITION_TYPES.COUNT_EQUAL then return bc==cc else
bb.warn("Unknown condition type: {}",dc)return false end end;return ab end
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
modules["elements.LogBox"] = function() local _a=require("libraries.basalt")
local aa=require("utils.StringUtils")local ba={}ba.__index=ba;local function ca(da)if not da or da==""then return 0 end
local _b,ab=da:gsub("\n","")return ab end
function ba:new(da,_b,ab,bb,cb,db,_c)
local ac=setmetatable({},ba)ac.frame=da;ac.text=""ac.logs={}ac.needUpdate=false;ac.maxLines=30
ac.textBox=ac.frame:addTextBox():setPosition(_b,ab):setSize(bb,cb):setBackground(
_c or colors.gray):setForeground(
db or colors.white):setText("")return ac end
function ba:addLog(da)
local _b=aa.wrapText(da,self.textBox:getWidth())self.text=self.text.._b.."\n"local ab=ca(self.text)
if ab>
self.maxLines then local db=ab-self.maxLines;local _c=1
for i=1,db do
local ac=self.text:find("\n",_c)
if ac then _c=ac+1 else local bc={}for _d in self.text:gmatch("([^\n]*)\n?")do if _d~=""then
table.insert(bc,_d)end end;local cc=math.max(1,#bc-
self.maxLines+1)local dc={}for i=cc,#bc do
table.insert(dc,bc[i])end
self.text=table.concat(dc,"\n").."\n"self.textBox:setText(self.text)return end end
if _c and _c<=#self.text then self.text=self.text:sub(_c)end end;self.textBox:setText(self.text)
local bb=ca(self.text)local cb=self.textBox:getHeight()if bb>cb then self.textBox:setScrollY(
bb-cb+1)end end;function ba:setMaxLines(da)self.maxLines=da or 30 end;function ba:getLineCount()return
ca(self.text)end;function ba:clear()self.text=""self.logs={}
self.textBox:setText("")end;return ba end
modules["utils.StringUtils"] = function() local b={}
b.split=function(c,d)local _a={}for aa in(c..d):gmatch("(.-)"..d)do
table.insert(_a,aa)end;return _a end
b.formatNumber=function(c)
if c>=1000 then return math.floor(c/1000).."k"elseif c>=1000000 then return math.floor(
c/1000000).."m"elseif c>=100000000 then return
math.floor(c/1000000000).."b"elseif c>=1000000000000 then return
math.floor(c/1000000000000).."t"end;return tostring(c)end
b.stringContainsIgnoreCase=function(c,d)if c==nil or d==nil then return false end;return
string.find(string.lower(c),string.lower(d),1,true)~=nil end
b.wrapText=function(c,d)local _a={}local aa=""for ba in string.gmatch(c,"%S+")do
if#aa+#ba+1 >d then
table.insert(_a,aa)aa=ba else if aa~=""then aa=aa.." "end;aa=aa..ba end end;if aa~=""then
table.insert(_a,aa)end;return table.concat(_a,"\n")end
b.ellipsisMiddle=function(c,d)if#c<=d then return c end
if d<=3 then return string.sub(c,1,d)end;local _a=math.floor((d-3)/2)local aa=d-3 -_a;return string.sub(c,1,_a).."..."..string.sub(c,
-aa)end
b.getAbbreviation=function(c)local d=""for _a in string.gmatch(c,"%a+")do
d=d.._a:sub(1,1):upper()end;return d end;return b end
modules["utils.OSUtils"] = function() local c=require("utils.Logger")local d={}
d.timestampBaseIdGenerate=function()
local _a=os.epoch("utc")local aa=math.random(1000,9999)return
tostring(_a).."-"..tostring(aa)end
d.loadTable=function(_a)local aa={}local ba=fs.open(_a,"r")if ba then
aa=textutils.unserialize(ba.readAll())ba.close()else return nil end;return aa end
d.saveTable=function(_a,aa)local ba=fs.open(_a,"w")
if ba then
xpcall(function()
local ca=textutils.serialize(aa)ba.write(ca)end,function(ca)
c.error("Failed to save table to {}, error: {}",_a,ca)end)ba.close()end end;return d end
modules["elements.ItemSelectedListBox"] = function() local c=require("libraries.basalt")local d={}d.__index=d
function d:new(_a,aa,ba,ca,da)
local _b=setmetatable({},d)aa=aa or colors.lightGray;ba=ba or colors.gray;ca=ca or
colors.white;da=da or colors.lightGray
_b.frame=_a:addFrame():setPosition(1,1):setSize(_a:getWidth(),_a:getHeight()):setBackground(aa):setForeground(ca):setVisible(false)_b.items={}_b.callbacks={}
_b.searchInput=_b.frame:addInput():setPosition(2,2):setSize(
_b.frame:getWidth()-6,1):setBackground(ba):setForeground(ca):setPlaceholderColor(da):setPlaceholder("Search...")
_b.searchBtn=_b.frame:addButton():setPosition(_b.searchInput:getX()+
_b.searchInput:getWidth()+1,_b.searchInput:getY()):setSize(1,1):setText("S"):setBackground(ba):setForeground(ca):onClick(function()
local ab=_b.searchInput:getText()
if ab==nil or ab==""then _b.list:setItems(_b.items)else local bb={}for cb,db in
pairs(_b.items)do
if db.name:find(ab)or
(db.displayName and db.displayName:find(ab))then table.insert(bb,db)end end
_b.list:setItems(bb)end end)
_b.cleanInputBtn=_b.frame:addButton():setPosition(_b.searchBtn:getX()+
_b.searchBtn:getWidth()+1,_b.searchBtn:getY()):setSize(1,1):setText("C"):setBackground(ba):setForeground(ca):onClick(function()
_b.searchInput:setText("")_b.list:setItems(_b.items)end)
_b.list=_b.frame:addList():setPosition(2,_b.searchInput:getY()+
_b.searchInput:getHeight()+1):setSize(
_b.frame:getWidth()-2,
_b.frame:getHeight()-_b.searchInput:getHeight()-5):setBackground(ba):setForeground(ca)
_b.confirmBtn=_b.frame:addButton():setText("Confirm"):setSize(9,1):setPosition(
_b.frame:getWidth()-18,_b.list:getY()+_b.list:getHeight()+1):setBackground(ba):setForeground(ca):onClick(function()
local ab=_b.list:getSelectedItems()
if _b.callbacks.confirm~=nil then _b.callbacks.confirm(ab)end;_b:close()end)
_b.cancelBtn=_b.frame:addButton():setText("Cancel"):setSize(8,1):setPosition(
_b.confirmBtn:getX()+_b.confirmBtn:getWidth()+1,_b.confirmBtn:getY()):setBackground(ba):setForeground(ca):onClick(function()
if
_b.callbacks.cancel~=nil then _b.callbacks.cancel()end;_b:close()end)return _b end
function d:open(_a,aa,ba)self.items=_a or{}
self.list:setItems(self.items)self.list:setMultiSelection(aa or false)self.callbacks=
ba or{}self.frame:setVisible(true)end
function d:close()self.frame:setVisible(false)end;return d end
modules["utils.TableUtils"] = function() local b={}
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
modules["elements.MessageBox"] = function() local _a=require("libraries.basalt")
local aa=require("utils.StringUtils")local ba=colors;local ca={}ca.__index=ca
function ca:new(da,_b,ab)local bb=setmetatable({},ca)
bb.frame=da;bb.title="Message"bb.message="No message provided."
bb.coverFrame=da:addFrame():setPosition(1,1):setSize(da:getWidth(),da:getHeight()):setBackground(ba.black):setForeground(ba.white):setVisible(false)local cb=da:getWidth()-2;local db=da:getHeight()-2;local _c=math.min(_b or
cb,cb)local ac=math.min(ab or db,db)
local bc=math.floor((
da:getWidth()-_c)/2)+1
local cc=math.floor((da:getHeight()-ac)/2)+1
bb.boxFrame=bb.coverFrame:addFrame():setPosition(bc,cc):setSize(_c,ac):setBackground(ba.lightGray):setForeground(ba.white)
bb.titleLabel=bb.boxFrame:addLabel():setText(bb.title):setPosition(2,2):setBackgroundEnabled(true):setBackground(ba.lightGray):setForeground(ba.white)
bb.textBox=bb.boxFrame:addTextBox():setText(bb.message):setSize(
bb.boxFrame:getWidth()-2,bb.boxFrame:getHeight()-6):setPosition(2,4):setBackground(ba.lightGray):setForeground(ba.white)
bb.closeBtn=bb.boxFrame:addButton():setText("Close"):setPosition(
bb.boxFrame:getWidth()-7,bb.boxFrame:getHeight()-1):setSize(7,1):setBackground(ba.gray):setForeground(ba.white):onClick(function()
bb:close()end)return bb end
function ca:open(da,_b)
if da then self.title=da;self.titleLabel:setText(da)end;if _b then self.message=_b
self.textBox:setText(aa.wrapText(_b,self.textBox:getWidth()))end
self.coverFrame:setVisible(true)end
function ca:close()self.coverFrame:setVisible(false)end;return ca end
modules["elements.ConfirmMessageBox"] = function() local aa=require("libraries.basalt")
local ba=require("utils.StringUtils")local ca=require("utils.Logger")local da=colors;local _b={}_b.__index=_b
function _b:new(ab,bb,cb)
local db=setmetatable({},_b)db.frame=ab;db.title="Confirm"db.message="No message provided."
db.onConfirm=nil;db.onCancel=nil
db.coverFrame=ab:addFrame():setPosition(1,1):setSize(ab:getWidth(),ab:getHeight()):setBackground(da.black):setForeground(da.white):setVisible(false)local _c=ab:getWidth()-2;local ac=ab:getHeight()-2;local bc=math.min(bb or
_c,_c)local cc=math.min(cb or ac,ac)
local dc=math.floor((
ab:getWidth()-bc)/2)+1
local _d=math.floor((ab:getHeight()-cc)/2)+1
db.boxFrame=db.coverFrame:addFrame():setPosition(dc,_d):setSize(bc,cc):setBackground(da.lightGray):setForeground(da.white)
db.titleLabel=db.boxFrame:addLabel():setText(db.title):setPosition(2,2):setBackgroundEnabled(true):setBackground(da.lightGray):setForeground(da.white)
db.textBox=db.boxFrame:addTextBox():setText(db.message):setSize(
db.boxFrame:getWidth()-2,db.boxFrame:getHeight()-6):setPosition(2,4):setBackground(da.lightGray):setForeground(da.white)
db.yesBtn=db.boxFrame:addButton():setText("Yes"):setPosition(
db.boxFrame:getWidth()-15,db.boxFrame:getHeight()-1):setSize(6,1):setBackground(da.green):setForeground(da.white):onClick(function()
db:confirm()end)
db.noBtn=db.boxFrame:addButton():setText("No"):setPosition(
db.boxFrame:getWidth()-7,db.boxFrame:getHeight()-1):setSize(6,1):setBackground(da.red):setForeground(da.white):onClick(function()
db:cancel()end)return db end
function _b:open(ab,bb,cb,db)
if ab then self.title=ab;self.titleLabel:setText(ab)end;if bb then self.message=bb
self.textBox:setText(ba.wrapText(bb,self.textBox:getWidth()))end;self.onConfirm=cb
self.onCancel=db;self.coverFrame:setVisible(true)end
function _b:confirm()
if self.onConfirm then local ab,bb=pcall(self.onConfirm)if not ab then end end;self:close()end;function _b:cancel()if self.onCancel then self.onCancel()end
self:close()end
function _b:close()
self.coverFrame:setVisible(false)self.onConfirm=nil;self.onCancel=nil end;return _b end
modules["programs.transfer.Triggers"] = function() local ac=require("utils.StringUtils")
local bc=require("wrapper.PeripheralWrapper")local cc=require("utils.OSUtils")
local dc=require("utils.Logger")local _d=require("elements.TabView")
local ad=require("elements.ItemSelectedListBox")local bd=require("utils.TableUtils")
local cd=require("programs.transfer.TransferJobManager")local dd=require("elements.MessageBox")
local __a=require("elements.ConfirmMessageBox")local a_a=textutils;local b_a=colors;local c_a={}c_a.__index=c_a;local d_a=cd.TRIGGER_TYPES
local _aa=cd.TRIGGER_CONDITION_TYPES
function c_a:new(aaa)local baa=setmetatable({},c_a)baa.selectNodeData={}
baa.pframe=aaa
baa.frame=aaa:addFrame():setPosition(1,1):setSize(aaa:getWidth(),aaa:getHeight()):setBackground(b_a.lightGray):setForeground(b_a.white):setVisible(false)local caa=baa.frame:getWidth()
local daa=baa.frame:getHeight()local _ba=math.floor(caa*2 /5)-1;local aba=caa-_ba-3
baa.conditionTree=baa.frame:addTree():setPosition(2,2):setSize(_ba,
daa-4):setBackground(b_a.gray):setForeground(b_a.white):setSelectedColor(b_a.lightBlue):onSelect(function(bba,cba)if
cba and cba.data then baa:updateDetails(cba.data)
baa.selectedTreeNode=cba end end)
baa.nodeDetailsFrame=baa.frame:addFrame():setPosition(_ba+3,2):setSize(aba,
daa-2):setBackground(b_a.gray):setForeground(b_a.white)
baa.parentNodeLabel=baa.nodeDetailsFrame:addLabel():setPosition(2,2):setBackground(b_a.gray):setForeground(b_a.white):setText("Parent:")
baa.displayedParentNodelabel=baa.nodeDetailsFrame:addLabel():setPosition(
baa.parentNodeLabel:getX()+baa.parentNodeLabel:getWidth()+1,2):setAutoSize(false):setSize(
aba-baa.parentNodeLabel:getWidth()-9,1):setBackground(b_a.lightGray):setForeground(b_a.white):setText("root")
baa.changedParentNodeBtn=baa.nodeDetailsFrame:addButton():setPosition(
baa.nodeDetailsFrame:getWidth()-5,2):setSize(5,1):setBackground(b_a.lightGray):setForeground(b_a.white):setText("..."):onClick(function()
baa:openParentNodeSelector()end)
baa.nodeNameLabel=baa.nodeDetailsFrame:addLabel():setPosition(2,4):setBackground(b_a.gray):setForeground(b_a.white):setText("Name:")
baa.nodeNameInput=baa.nodeDetailsFrame:addInput():setPosition(
baa.nodeNameLabel:getX()+baa.nodeNameLabel:getWidth()+1,baa.nodeNameLabel:getY()):setSize(
baa.nodeDetailsFrame:getWidth()-baa.nodeNameLabel:getWidth()-3,1):setBackground(b_a.lightGray):setForeground(b_a.white):setText("unnamed"):setPlaceholder("")
baa.triggerTypeDropdown=baa.nodeDetailsFrame:addDropdown():setPosition(2,
baa.nodeNameInput:getY()+2):setSize(
baa.nodeDetailsFrame:getWidth()-2,1):setBackground(b_a.lightGray):setForeground(b_a.white):setItems({{text="Item Count",value=d_a.ITEM_COUNT,selected=true,callback=function(bba)
baa:updateUIForTriggerType()end},{text="Fluid Count",value=d_a.FLUID_COUNT,callback=function(bba)
baa:updateUIForTriggerType()end},{text="Item Count at Slots",value=d_a.ITEM_COUNT_AT_SLOTS,callback=function(bba)
baa:updateUIForTriggerType()end}})
baa.targetLabel=baa.nodeDetailsFrame:addLabel():setPosition(2,
baa.triggerTypeDropdown:getY()+2):setBackground(b_a.gray):setForeground(b_a.white):setText("Target:")
baa.selectedTargetLabel=baa.nodeDetailsFrame:addLabel():setPosition(
baa.targetLabel:getX()+baa.targetLabel:getWidth()+1,baa.targetLabel:getY()):setAutoSize(false):setSize(
baa.nodeDetailsFrame:getWidth()-baa.targetLabel:getWidth()-9,1):setBackground(b_a.black):setForeground(b_a.white):setText("")
baa.selectTargetBtn=baa.nodeDetailsFrame:addButton():setPosition(
baa.nodeDetailsFrame:getWidth()-5,baa.targetLabel:getY()):setSize(5,1):setBackground(b_a.lightGray):setForeground(b_a.white):setText("..."):onClick(function()
baa:openTargetSelector()end)
baa.itemLabel=baa.nodeDetailsFrame:addLabel():setPosition(2,
baa.selectedTargetLabel:getY()+1):setBackground(b_a.gray):setForeground(b_a.white):setText("Item:")
baa.selectedItemLabel=baa.nodeDetailsFrame:addLabel():setPosition(
baa.itemLabel:getX()+baa.itemLabel:getWidth()+1,baa.itemLabel:getY()):setAutoSize(false):setSize(
baa.nodeDetailsFrame:getWidth()-baa.itemLabel:getWidth()-9,1):setBackground(b_a.black):setForeground(b_a.white):setText("")
baa.selectItemBtn=baa.nodeDetailsFrame:addButton():setPosition(
baa.nodeDetailsFrame:getWidth()-5,baa.itemLabel:getY()):setSize(5,1):setBackground(b_a.lightGray):setForeground(b_a.white):setText("..."):onClick(function()
baa:openItemSelector()end)
baa.conditionTypeDropdown=baa.nodeDetailsFrame:addDropdown():setPosition(2,
baa.selectedItemLabel:getY()+2):setSize(
baa.nodeDetailsFrame:getWidth()-2,1):setBackground(b_a.lightGray):setForeground(b_a.white):setItems({{text="Count Greater",value=_aa.COUNT_GREATER,selected=true,callback=function(bba)
end},{text="Count Less",value=_aa.COUNT_LESS,callback=function(bba)end},{text="Count Equal",value=_aa.COUNT_EQUAL,callback=function(bba)
end}})
baa.amountLabel=baa.nodeDetailsFrame:addLabel():setPosition(2,
baa.conditionTypeDropdown:getY()+2):setBackground(b_a.gray):setForeground(b_a.white):setText("Amt:")
baa.amountInput=baa.nodeDetailsFrame:addInput():setPosition(
baa.amountLabel:getX()+baa.amountLabel:getWidth()+1,baa.amountLabel:getY()):setSize(12,1):setBackground(b_a.lightGray):setForeground(b_a.white):setText("0"):setPlaceholder("0"):setPattern("[0-9]")
baa.slotButton=baa.nodeDetailsFrame:addButton():setPosition(
baa.amountInput:getX()+baa.amountInput:getWidth()+2,baa.amountInput:getY()):setSize(8,1):setBackground(b_a.lightGray):setForeground(b_a.white):setText("Slot"):setVisible(false):onClick(function()
baa:openSlotSelector()end)
baa.modifyNodeBtn=baa.nodeDetailsFrame:addButton():setPosition(
baa.nodeDetailsFrame:getWidth()-27,baa.amountInput:getY()+2):setSize(8,1):setBackground(b_a.blue):setForeground(b_a.white):setText("Modify"):setVisible(false):onClick(function()
baa:modifySelectedNode()end)
baa.addNodeBtn=baa.nodeDetailsFrame:addButton():setPosition(
baa.nodeDetailsFrame:getWidth()-16,baa.amountInput:getY()+2):setSize(6,1):setBackground(b_a.green):setForeground(b_a.white):setText("Add"):onClick(function()
baa:addNodeToTree()end)
baa.deleteNodeBtn=baa.nodeDetailsFrame:addButton():setPosition(
baa.nodeDetailsFrame:getWidth()-8,baa.addNodeBtn:getY()):setSize(8,1):setBackground(b_a.red):setForeground(b_a.white):setVisible(false):setText("Delete"):onClick(function()
baa:deleteSelectedNode()end)
baa.NewTriggerBtn=baa.frame:addButton():setPosition(2,
baa.conditionTree:getY()+baa.conditionTree:getHeight()+1):setSize(5,1):setBackground(b_a.red):setForeground(b_a.white):setText("New"):onClick(function()
baa:updateDetails()end)
baa.saveTriggerBtn=baa.frame:addButton():setPosition(
baa.NewTriggerBtn:getX()+baa.NewTriggerBtn:getWidth()+1,
baa.conditionTree:getY()+baa.conditionTree:getHeight()+1):setSize(6,1):setBackground(b_a.green):setForeground(b_a.white):setText("Save"):onClick(function()
baa:saveTriggerStatement()end)
baa.cancelBtn=baa.frame:addButton():setPosition(
baa.saveTriggerBtn:getX()+baa.saveTriggerBtn:getWidth()+1,
baa.conditionTree:getY()+baa.conditionTree:getHeight()+1):setSize(6,1):setBackground(b_a.gray):setForeground(b_a.white):setText("Back"):onClick(function()
baa:close()end)baa.itemListBox=ad:new(baa.pframe)
baa.messageBox=dd:new(baa.frame,30,10)baa.confirmMessageBox=__a:new(baa.frame,30,10)
baa:updateUIForTriggerType()return baa end
function c_a:open(aaa,baa)self.tree=aaa or{id="root"}
dc.debug("Opening Triggers with tree: "..
a_a.serialize(self.tree))self.saveCallback=baa;self.frame:setVisible(true)local caa=
self.tree.children or{}
self.conditionTree:setNodes(caa)self:updateDetails()end
function c_a:addNode(aaa,baa,caa,daa)caa.data=daa or{}
if baa then
if not baa.children then baa.children={}end;table.insert(baa.children,caa)self.conditionTree:setNodes(
self.tree.children or{})
self.conditionTree.get("expandedNodes")[caa]=true end;return caa end
function c_a:getSelectedTriggerType()
local aaa=self.triggerTypeDropdown:getSelectedItems()if#aaa>0 then return aaa[1].value end;return nil end
function c_a:setTriggerType(aaa)
local baa=self.triggerTypeDropdown.get("items")
for caa,daa in ipairs(baa)do
if daa.value==aaa then for _ba,aba in ipairs(baa)do
if type(aba)=="table"then aba.selected=false end end;daa.selected=true
self.triggerTypeDropdown:updateRender()self:updateUIForTriggerType()return true end end;return false end
function c_a:setConditionType(aaa)
local baa=self.conditionTypeDropdown.get("items")
for caa,daa in ipairs(baa)do
if daa.value==aaa then for _ba,aba in ipairs(baa)do
if type(aba)=="table"then aba.selected=false end end;daa.selected=true
self.conditionTypeDropdown:updateRender()return true end end;return false end
function c_a:getSelectedConditionType()
local aaa=self.conditionTypeDropdown:getSelectedItems()if#aaa>0 then return aaa[1].value end;return nil end;function c_a:getAmountValue()local aaa=self.amountInput.get("text")
local baa=tonumber(aaa)return baa or 0 end
function c_a:setAmountValue(aaa)if
type(aaa)=="number"and aaa>=0 then
self.amountInput.set("text",tostring(math.floor(aaa)))return true end;return false end
function c_a:flattenTreeNodes(aaa,baa,caa,daa)daa=daa or{}caa=caa or 0
for _ba,aba in ipairs(aaa or{})do
table.insert(daa,{node=aba,level=caa})if baa and baa[aba]and aba.children then
self:flattenTreeNodes(aba.children,baa,caa+1,daa)end end;return daa end
function c_a:openParentNodeSelector()
local aaa=self.conditionTree.get("nodes")local baa=self.conditionTree.get("expandedNodes")
local caa=self:flattenTreeNodes(aaa,baa)local daa={}
table.insert(daa,1,{text="root",data={id="root",text="root"}})for aba,bba in ipairs(caa)do local cba=bba.node
table.insert(daa,{text=cba.text or"Unnamed Node",data=cba})end
local _ba=self.selectNodeData and
self.selectNodeData.parentNodeId or"root"for aba,bba in ipairs(daa)do
if(bba.data.id==_ba)or
(_ba=="root"and bba.data.id=="root")then bba.selected=true;break end end
self.itemListBox:open(daa,false,{confirm=function(aba)
if
not self.selectNodeData then self.selectNodeData={}end;local bba=aba[1].data
if bba.id=="root"then
self.selectNodeData.parentNodeId="root"self.selectNodeData.parentNodeName="root"
self.displayedParentNodelabel:setText("root")else
self.selectNodeData.parentNodeId=bba.data and bba.data.id or bba.id
self.selectNodeData.parentNodeName=bba.text or"Unnamed Node"
self.displayedParentNodelabel:setText(ac.ellipsisMiddle(self.selectNodeData.parentNodeName,self.displayedParentNodelabel:getWidth()))end end})end
function c_a:openTargetSelector()local aaa=self:getSelectedTriggerType()local baa={}
local caa={}bc.reloadAll()
if aaa==d_a.ITEM_COUNT then baa=bc.getByTypes({1,2})elseif
aaa==d_a.FLUID_COUNT then baa=bc.getByTypes({3})elseif
aaa==d_a.ITEM_COUNT_AT_SLOTS then baa=bc.getByTypes({1})else baa={}end
local daa=self.selectNodeData and self.selectNodeData.targetPeripheralId or nil
for _ba,aba in pairs(baa)do
if aba.getId()==daa then
table.insert(caa,{text=aba.getId()or"Unknown",selected=true,data=aba})else
table.insert(caa,{text=aba.getId()or"Unknown",data=aba})end end
self.itemListBox:open(caa,false,{confirm=function(_ba)
if self.selectNodeData==nil then self.selectNodeData={}end
self.selectNodeData.targetPeripheralId=_ba[1].data.getId()
self.selectedTargetLabel:setText(ac.ellipsisMiddle(self.selectNodeData.targetPeripheralId,self.selectedTargetLabel:getWidth()))self:updateSlotButton()end})end
function c_a:openItemSelector()local aaa=self:getSelectedTriggerType()local baa={}
if aaa==
d_a.ITEM_COUNT or aaa==d_a.ITEM_COUNT_AT_SLOTS then local daa=
bc.getByTypes({1,2})or{}local _ba={}
for aba,bba in pairs(daa)do
if bba.getItems then
local cba=bba.getItems()
for dba,_ca in ipairs(cba)do if not _ba[_ca.name]then _ba[_ca.name]=true
table.insert(baa,{text=_ca.name,data={type="item",name=_ca.name}})end end end end elseif aaa==d_a.FLUID_COUNT then local daa=bc.getByTypes({3})or{}local _ba={}
for aba,bba in
pairs(daa)do
if bba.getFluids then local cba=bba.getFluids()
for dba,_ca in ipairs(cba)do if not _ba[_ca.name]then
_ba[_ca.name]=true
table.insert(baa,{text=_ca.name,data={type="fluid",name=_ca.name}})end end end end end
if#baa==0 then if aaa==d_a.FLUID_COUNT then
table.insert(baa,{text="No fluids found",data=nil})else
table.insert(baa,{text="No items found",data=nil})end end
local caa=self.selectNodeData and self.selectNodeData.itemName or nil;for daa,_ba in ipairs(baa)do
if _ba.data and _ba.data.name==caa then _ba.selected=true;break end end
self.itemListBox:open(baa,false,{confirm=function(daa)
if
daa[1].data then
if self.selectNodeData==nil then self.selectNodeData={}end;self.selectNodeData.itemName=daa[1].data.name
self.selectNodeData.itemType=daa[1].data.type
self.selectedItemLabel:setText(ac.ellipsisMiddle(self.selectNodeData.itemName,self.selectedItemLabel:getWidth()))end end})end
function c_a:openSlotSelector()local aaa=self:getSelectedTriggerType()if aaa~=
d_a.ITEM_COUNT_AT_SLOTS then return end;local baa={}
if self.selectNodeData and
self.selectNodeData.targetPeripheralId then bc.reloadAll()
local caa=bc.getByName(self.selectNodeData.targetPeripheralId)
if caa and caa.size then local daa=caa.size()for i=1,daa do
local _ba=(self.selectNodeData.selectedSlot==i)
table.insert(baa,{text="Slot "..i,data={slotId=i},selected=_ba})end else
table.insert(baa,{text="Slot 1",data={slotId=1},selected=true})end else
table.insert(baa,{text="Select Target First",data=nil})end
self.itemListBox:open(baa,false,{confirm=function(caa)
if caa[1].data then if self.selectNodeData==nil then
self.selectNodeData={}end
self.selectNodeData.selectedSlot=caa[1].data.slotId
self.slotButton:setText("Slot "..self.selectNodeData.selectedSlot)end end})end
function c_a:updateSlotButton()local aaa=self:getSelectedTriggerType()
if aaa==
d_a.ITEM_COUNT_AT_SLOTS then self.slotButton:setVisible(true)
if
self.selectNodeData and self.selectNodeData.selectedSlot then
self.slotButton:setText(
"Slot "..self.selectNodeData.selectedSlot)else
if self.selectNodeData and self.selectNodeData.targetPeripheralId then
self.slotButton:setText("Select Slot")else self.slotButton:setText("Select Target")end end else self.slotButton:setVisible(false)end end
function c_a:getSelectedSlot()
if
self.selectNodeData and self.selectNodeData.selectedSlot then return self.selectNodeData.selectedSlot end;return nil end
function c_a:updateUIForTriggerType()local aaa=self:getSelectedTriggerType()if
aaa==d_a.FLUID_COUNT then self.itemLabel:setText("Fluid:")else
self.itemLabel:setText("Item:")end
self:updateSlotButton()end
function c_a:updateDetails(aaa)
if aaa==nil then self.selectNodeData={}
self.nodeNameInput:setText("unnamed")
self.displayedParentNodelabel:setText("root")self.selectedTargetLabel:setText("")
self.selectedItemLabel:setText("")self.amountInput:setText("0")
self:setTriggerType(d_a.ITEM_COUNT)self:setConditionType(_aa.COUNT_GREATER)
self.slotButton:setText("Slot")self:updateUIForTriggerType()
self.modifyNodeBtn:setVisible(false)self.deleteNodeBtn:setVisible(false)else
self.selectNodeData={parentNodeId=
aaa.parentNodeId or"",parentNodeName=aaa.parentNodeName or"root",targetPeripheralId=aaa.targetPeripheralId or"",name=aaa.name or
"unnamed",id=aaa.id or cc.timestampBaseIdGenerate(),triggerType=aaa.triggerType or
d_a.ITEM_COUNT,triggerConditionType=aaa.triggerConditionType or _aa.COUNT_GREATER,itemName=aaa.itemName or"",itemType=
aaa.itemType or"item",amount=aaa.amount or 0,selectedSlot=aaa.selectedSlot}
self.nodeNameInput:setText(self.selectNodeData.name)
self.displayedParentNodelabel:setText(self.selectNodeData.parentNodeName)
self.selectedTargetLabel:setText(ac.ellipsisMiddle(self.selectNodeData.targetPeripheralId or"",self.selectedTargetLabel:getWidth()))
self.selectedItemLabel:setText(ac.ellipsisMiddle(self.selectNodeData.itemName or"",self.selectedItemLabel:getWidth()))
self.amountInput:setText(tostring(self.selectNodeData.amount))
self:setTriggerType(self.selectNodeData.triggerType)
self:setConditionType(self.selectNodeData.triggerConditionType)
if self.selectNodeData.selectedSlot then
self.slotButton:setText("Slot "..
self.selectNodeData.selectedSlot)else self.slotButton:setText("Slot")end;self:updateUIForTriggerType()
self.modifyNodeBtn:setVisible(true)self.deleteNodeBtn:setVisible(true)end end
function c_a:addNodeToTree()self.selectNodeData.name=self.nodeNameInput:getText()or
"unnamed"self.selectNodeData.triggerType=
self:getSelectedTriggerType()or d_a.ITEM_COUNT
self.selectNodeData.triggerConditionType=
self:getSelectedConditionType()or _aa.COUNT_GREATER
self.selectNodeData.amount=self:getAmountValue()or 0
self.selectNodeData.id=cc.timestampBaseIdGenerate()local aaa=self:validateSelectNodeData()if#aaa>0 then
self.messageBox:open("Validation Errors",table.concat(aaa,"\n"))return end
local baa={text=self.selectNodeData.name,data=a_a.unserialize(a_a.serialize(self.selectNodeData)),children={}}
dc.debug("Adding node with data: "..a_a.serialize(baa.data))local caa=self.selectNodeData.parentNodeId;local daa=nil
if
not caa or caa==""or caa=="root"then if not self.tree.children then
self.tree.children={}end
table.insert(self.tree.children,baa)
self.conditionTree:setNodes(self.tree.children or{})else daa=self:findNodeById(self.tree,caa)
if daa then if not daa.children then
daa.children={}end;table.insert(daa.children,baa)
self.conditionTree:expandNode(daa)
self.conditionTree:setNodes(self.tree.children or{})else
if not self.tree.children then self.tree.children={}end;table.insert(self.tree.children,baa)self.conditionTree:setNodes(
self.tree.children or{})end end;self:updateDetails(nil)end
function c_a:modifySelectedNode()if not self.selectedTreeNode or
not self.selectedTreeNode.data then return end;self.selectNodeData.name=
self.nodeNameInput:getText()or"unnamed"self.selectNodeData.triggerType=
self:getSelectedTriggerType()or d_a.ITEM_COUNT
self.selectNodeData.triggerConditionType=
self:getSelectedConditionType()or _aa.COUNT_GREATER
self.selectNodeData.amount=self:getAmountValue()or 0
self.selectNodeData.id=self.selectedTreeNode.data.id;local aaa=self:validateSelectNodeData()if#aaa>0 then
self.messageBox:open("Validation Errors",table.concat(aaa,"\n"))return end;local baa=
self.selectedTreeNode.data.parentNodeId or""local caa=
self.selectNodeData.parentNodeId or""if baa~=caa then
self:moveNodeToNewParent(self.selectedTreeNode,caa)end
self.selectedTreeNode.data=a_a.unserialize(a_a.serialize(self.selectNodeData))self.selectedTreeNode.text=self.selectNodeData.name
dc.debug(
"Modified node with data: "..a_a.serialize(self.selectedTreeNode.data))
self.conditionTree:setNodes(self.tree.children or{})end
function c_a:moveNodeToNewParent(aaa,baa)if not aaa then return end
self:removeNodeFromParent(aaa)local caa=nil
if not baa or baa==""or baa=="root"then if
not self.tree.children then self.tree.children={}end
table.insert(self.tree.children,aaa)else caa=self:findNodeById(self.tree,baa)
if caa then if not caa.children then
caa.children={}end;table.insert(caa.children,aaa)
self.conditionTree:expandNode(caa)else
if not self.tree.children then self.tree.children={}end;table.insert(self.tree.children,aaa)end end end
function c_a:removeNodeFromParent(aaa)if not aaa then return false end;return
self:removeNodeRecursive(self.tree,aaa)end
function c_a:removeNodeRecursive(aaa,baa)
if not aaa or not aaa.children then return false end
for caa,daa in ipairs(aaa.children)do if daa==baa then table.remove(aaa.children,caa)return
true end end;for caa,daa in ipairs(aaa.children)do
if self:removeNodeRecursive(daa,baa)then return true end end;return false end
function c_a:findNodeById(aaa,baa)if not aaa then return nil end;if
aaa.data and aaa.data.id==baa then return aaa end
if aaa.children then for caa,daa in ipairs(aaa.children)do
local _ba=self:findNodeById(daa,baa)if _ba then return _ba end end end;return nil end
function c_a:validateSelectNodeData()local aaa={}if not self.selectNodeData.name or
self.selectNodeData.name==""or
self.selectNodeData.name=="unnamed"then
table.insert(aaa,"Name cannot be empty")end;if not
self.selectNodeData.triggerType then
table.insert(aaa,"Trigger type is required")return aaa end
if
self.selectNodeData.triggerType==d_a.ITEM_COUNT then
if

not self.selectNodeData.targetPeripheralId or self.selectNodeData.targetPeripheralId==""then
table.insert(aaa,"Target peripheral is required for Item Count trigger")else bc.reloadAll()
local baa=bc.getByName(self.selectNodeData.targetPeripheralId)
if baa then local caa=baa.getTypes()local daa=false;for _ba,aba in ipairs(caa)do if aba==1 or aba==2 then daa=true
break end end;if not daa then
table.insert(aaa,"Target peripheral must be inventory type (type 1 or 2) for Item Count trigger")end else
table.insert(aaa,"Target peripheral not found")end end;if not self.selectNodeData.itemType or
self.selectNodeData.itemType~="item"then
table.insert(aaa,"Item type must be 'item' for Item Count trigger")end;if
not
self.selectNodeData.itemName or self.selectNodeData.itemName==""then
table.insert(aaa,"Item name is required for Item Count trigger")end elseif
self.selectNodeData.triggerType==d_a.FLUID_COUNT then
if

not self.selectNodeData.targetPeripheralId or self.selectNodeData.targetPeripheralId==""then
table.insert(aaa,"Target peripheral is required for Fluid Count trigger")else bc.reloadAll()
local baa=bc.getByName(self.selectNodeData.targetPeripheralId)
if baa then local caa=baa.getTypes()local daa=false;for _ba,aba in ipairs(caa)do
if aba==3 then daa=true;break end end;if not daa then
table.insert(aaa,"Target peripheral must be tank type (type 3) for Fluid Count trigger")end else
table.insert(aaa,"Target peripheral not found")end end
if not self.selectNodeData.itemType or
self.selectNodeData.itemType~="fluid"then
table.insert(aaa,"Item type must be 'fluid' for Fluid Count trigger")end;if not self.selectNodeData.itemName or
self.selectNodeData.itemName==""then
table.insert(aaa,"Fluid name is required for Fluid Count trigger")end elseif
self.selectNodeData.triggerType==d_a.ITEM_COUNT_AT_SLOTS then
if

not self.selectNodeData.targetPeripheralId or self.selectNodeData.targetPeripheralId==""then
table.insert(aaa,"Target peripheral is required for Item Count at Slots trigger")else bc.reloadAll()
local baa=bc.getByName(self.selectNodeData.targetPeripheralId)
if baa then local caa=baa.getTypes()local daa=false;for _ba,aba in ipairs(caa)do
if aba==1 then daa=true;break end end;if not daa then
table.insert(aaa,"Target peripheral must be inventory type (type 1) for Item Count at Slots trigger")end else
table.insert(aaa,"Target peripheral not found")end end
if not self.selectNodeData.itemType or
self.selectNodeData.itemType~="item"then
table.insert(aaa,"Item type must be 'item' for Item Count at Slots trigger")end
if not self.selectNodeData.itemName or
self.selectNodeData.itemName==""then
table.insert(aaa,"Item name is required for Item Count at Slots trigger")end
if not self.selectNodeData.selectedSlot or
self.selectNodeData.selectedSlot<=0 then
table.insert(aaa,"Valid slot selection is required for Item Count at Slots trigger")end else
table.insert(aaa,"Unknown trigger type: "..tostring(self.selectNodeData.triggerType))end;if not self.selectNodeData.amount or
self.selectNodeData.amount<0 then
table.insert(aaa,"Amount must be a non-negative number")end;if not
self.selectNodeData.triggerConditionType then
table.insert(aaa,"Trigger condition type is required")end;return aaa end
function c_a:deleteSelectedNode()if not self.selectedTreeNode or
not self.selectedTreeNode.data then return end
local aaa=self.selectedTreeNode.data.id
local baa=self.selectedTreeNode.data.name or"Unnamed Node"
self.confirmMessageBox:open("Confirm Delete","Are you sure you want to delete node '"..baa.."'?",function()
self:deleteNodeById(aaa)end,function()end)end
function c_a:deleteNodeById(aaa)if not aaa then return false end
local baa=self:findNodeById(self.tree,aaa)if not baa then return false end
self:removeNodeFromParent(baa)self.selectedTreeNode=nil
self.conditionTree:setNodes(self.tree.children or{})self:updateDetails(nil)return true end;function c_a:saveTriggerStatement()
if self.saveCallback then self.saveCallback(self.tree)end;self:close()end;function c_a:close()
self.frame:setVisible(false)self.saveCallback=nil end;return c_a end
return modules["programs.Transfer"]()