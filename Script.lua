

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local SETTINGS_FILE = "ServerHopConfig.json"
local HISTORY_FILE = "ServerHistory.json"

-- Configuration
local Config = { Enabled = false, WaitTime = 10 }
local VisitedServers = {}

-- Load/Save Logic
local function loadFiles()
    if isfile(SETTINGS_FILE) then
        pcall(function() Config = HttpService:JSONDecode(readfile(SETTINGS_FILE)) end)
    end
    if isfile(HISTORY_FILE) then
        pcall(function() VisitedServers = HttpService:JSONDecode(readfile(HISTORY_FILE)) end)
    end
end

local function saveConfig()
    writefile(SETTINGS_FILE, HttpService:JSONEncode(Config))
end

local function saveHistory(newId)
    table.insert(VisitedServers, newId)
    if #VisitedServers > 100 then table.remove(VisitedServers, 1) end -- Keep last 100
    writefile(HISTORY_FILE, HttpService:JSONEncode(VisitedServers))
end

loadFiles()

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 160)
Main.Position = UDim2.new(0.5, -110, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "Anti-Rejoin Hopper"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local ToggleBtn = Instance.new("TextButton", Main)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleBtn.Text = Config.Enabled and "Hopper: ON" or "Hopper: OFF"
ToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)

local TimeInput = Instance.new("TextBox", Main)
TimeInput.Size = UDim2.new(0.9, 0, 0, 35)
TimeInput.Position = UDim2.new(0.05, 0, 0.6, 0)
TimeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TimeInput.Text = tostring(Config.WaitTime)
TimeInput.PlaceholderText = "Seconds (e.g. 15)"
TimeInput.TextColor3 = Color3.new(1, 1, 1)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0.85, 0)
Status.BackgroundTransparency = 1
Status.Text = "Ready"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextSize = 12

-- Server Hopping Logic
local function hop()
    if not Config.Enabled then return end
    Status.Text = "Searching for new server..."
    
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local cursor = ""
    
    while true do
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url .. "&cursor=" .. cursor))
        end)

        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    -- CRITICAL CHECK: Is this server in our history?
                    local alreadyVisited = false
                    for _, id in ipairs(VisitedServers) do
                        if id == server.id then alreadyVisited = true break end
                    end

                    if not alreadyVisited then
                        Status.Text = "New server found! Teleporting..."
                        saveHistory(game.JobId) -- Add current server to history before leaving
                        
                        local queue = syn and syn.queue_on_teleport or queue_on_teleport
                        if queue then
                            queue([[loadstring(game:HttpGet("YOUR_SCRIPT_URL_HERE"))()]])
                        end
                        
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
                        return
                    end
                end
            end
            
            if result.nextPageCursor then
                cursor = result.nextPageCursor
            else
                -- If we checked all pages and found nothing, clear history and try again
                Status.Text = "All servers visited. Clearing history..."
                VisitedServers = {}
                writefile(HISTORY_FILE, "[]")
                break
            end
        else
            break
        end
        task.wait(0.1)
    end
end

-- UI Events
ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "Hopper: ON" or "Hopper: OFF"
    ToggleBtn.BackgroundColor3 = Config.Enabled and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(150, 40, 40)
    saveConfig()
end)

TimeInput.FocusLost:Connect(function()
    local num = tonumber(TimeInput.Text)
    if num then
        Config.WaitTime = num
        saveConfig()
    else
        TimeInput.Text = tostring(Config.WaitTime)
    end
end)

-- Loop
task.spawn(function()
    while true do
        if Config.Enabled then
            for i = Config.WaitTime, 1, -1 do
                if not Config.Enabled then break end
                Status.Text = "Next hop in: " .. i .. "s"
                task.wait(1)
            end
            hop()
        end
        task.wait(1)
    end
end)
118\108\120\100\072\115\049","\103\078\107\078\117\088\077\088\081\057\113\070\112\049\120\108";"\052\084\113\106\052\104\090\050\083\072\077\061","\108\107\090\056\067\099\052\117\083\049\108\065\081\072\049\068\117\066\061\061";"\100\057\120\120\077\066\061\061";"\047\118\090\098\083\078\048\061","\118\088\113\050\083\072\108\049\112\122\061\061";"\081\088\090\055\052\104\111\074\077\104\107\106\077\117\107\106\081\051\061\061";"\118\088\113\053\047\118\108\120\052\084\097\074\083\084\117\061";"\083\057\051\057\052\084\088\084\079\043\097\117\083\084\120\085\083\068\061\061","\052\097\111\079\103\049\099\061","\047\057\097\053\047\051\061\061"}local function u(u)return A[u-(48998+13814)]end for u,G in ipairs({{505266+-505265;-792721-(-792768)};{-927481+927482;325868-325853},{523575-523559,935633-935586}})do while G[394736-394735]<G[407764-407762]do A[G[-751949-(-751950)]],A[G[-1047326-(-1047328)]],G[941019+-941018],G[-567859+567861]=A[G[794546+-794544]],A[G[-509184-(-509185)]],G[-625217+625218]+(-441748-(-441749)),G[-27934-(-27936)]-(952798-952797)end end do local u=table.concat local G=A local k=string.char local f={X=474484+-474431;w=-174246+174258,g=377891-377873,["\052"]=503332+-503303,["\051"]=-949683+949699,d=-776453-(-776477);P=242776-242717,J=24651+-24617,V=697814+-697751,M=909356-909328,p=-848882-(-848912),R=854095+-854093;H=-74682+74720,m=-805024-(-805034),S=-644868-(-644895),F=-38105-(-38120);b=283717-283667;n=725465+-725407,I=110557+-110556;G=919578+-919547;L=-165508+165554,e=-128874-(-128916),y=145838+-145835,["\054"]=-513857-(-513919),C=-250821-(-250847),Y=1048569+-1048534;["\053"]=747439-747394,a=-551222-(-551227),v=637255+-637232;N=444635+-444580,u=-484794+484814,["\048"]=143517-143509;U=468373-468316;c=-934462-(-934498);["\050"]=593499+-593458;Q=637440-637421,["\043"]=-45715+45737,s=756580+-756531,D=335267-335219,T=-136267+136273;["\047"]=202780+-202755,["\055"]=-951276-(-951328);["\049"]=665653-665616,["\056"]=-157301-(-157344);K=-218770-(-218814);h=902327-902320,E=-46086-(-46126),r=-794715+794775,i=585918-585907;f=322137-322098;O=-104192+104205,W=261255-261199;q=-533585-(-533646),o=324285-324264,l=2907-2890;k=-381409-(-381413),["\057"]=369973-369919;Z=218125+-218116,x=-87694-(-87727);B=1033996-1033964;j=-736165+736216,z=832604+-832604,A=-343303-(-343317),t=449857+-449810}local s=type local n=math.floor local d=string.len local W=string.sub local q=table.insert for A=-92030+92031,#G,-278844-(-278845)do local U=G[A]if s(U)=="\115\116\114\105\110\103"then local s=d(U)local X={}local J=-875768+875769 local H=-196356+196356 local M=132725+-132725 while J<=s do local A=W(U,J,J)local u=f[A]if u then H=H+u*(229247-229183)^((90000-89997)-M)M=M+(-999574+999575)if M==841801-841797 then M=923442-923442 local A=n(H/(-324166+389702))local u=n((H%(-1026803+1092339))/(-504211+504467))local G=H%(-733099+733355)q(X,k(A,u,G))H=379970-379970 end elseif A=="\061"then q(X,k(n(H/(142173+-76637))))if J>=s or W(U,J+(-329522-(-329523)),J+(313731-313730))~="\061"then q(X,k(n((H%(1042574-977038))/(-304317+304573))))end break end J=J+(459104+-459103)end G[A]=u(X)end end end return(function(A,k,f,s,n,d,W,M,T,H,e,y,i,R,G,D,X,q,I,U,J)y,J,U,e,q,M,i,R,G,X,H,D,I,T=function(A,u)local k=H(u)local f=function(f)return G(A,{f},u,k)end return f end,474847+-474847,{},function(A,u)local k=H(u)local f=function(f,s,n)return G(A,{f;s,n},u,k)end return f end,{},function(A)local u,G=588449-588448,A[967638+-967637]while G do U[G],u=U[G]-(-845774-(-845775)),(596891-596890)+u if 75572-75572==U[G]then U[G],q[G]=nil,nil end G=A[u]end end,function(A,u)local k=H(u)local f=function(f,s)return G(A,{f;s},u,k)end return f end,function(A,u)local k=H(u)local f=function(f,s,n,d)return G(A,{f;s,n,d},u,k)end return f end,function(G,f,s,n)local l,p,B,v,a,J,E,O,V,Y,F,M,N,S,j,D,z,t,W,g,r,w,c,h,K,C,b,U,P,o,H,Q,L,Z while G do if G<8694221-(-155100)then if G<-807000+5142640 then if G<-589701+2550725 then if G<-437239+1757832 then if G<-612834+1509879 then if G<721027+-26945 then if G<1207131-821237 then G=q[s[894337-894327]]J=q[s[-125237+125248]]U[G]=J G=q[s[805048-805036]]J={G(U)}G=A[u(-887319-(-950175))]W={k(J)}else U=f[722024+-722023]G=q[s[9102-9101]]J=f[-342822-(-342824)]H=G G=H[J]G=G and 3770689-(-579532)or 14820749-(-543152)end else l=G g=-513683+513684 V=Q[g]g=false t=V==g G=t and 3823478-696956 or-260345+7692010 Z=t end else if G<4761+980864 then p=u(-295468-(-358314))r=A[p]W=r G=6765675-858811 else W=r G=p G=r and-1036411+6943275 or-789233+1741549 end end else if G<1053523-(-786107)then if G<1377376-(-177011)then B=u(-70901+133733)O=W C=u(516219-453406)W=A[C]C=u(-224395-(-287234))G=W[C]a=u(-894099+956931)C=X()q[C]=G W=A[B]B=u(-56861-(-119720))G=W[B]p=G j=A[a]r=j B=G G=j and-447342+8482085 or 950511-(-364946)else G=true q[s[-240314-(-240315)]]=G G=A[u(-90761+153589)]W={}end else if G<1187813-(-747073)then r=i(14621062-341261,{})W=u(-267667-(-330517))B=u(-287825+350659)G=A[W]M=u(833356-770538)U=q[s[-131756+131760]]H=A[M]C=A[B]B={C(r)}O={k(B)}C=-730012-(-730014)D=O[C]M=H(D)H=u(-286005+348835)J=U(M,H)U={J()}W=G(k(U))J=q[s[786261+-786256]]U=W W=J G=J and 3605964-(-554669)or 900029+6922614 else o=#v S=748140+-748139 P=-815193-(-815194)h=M(P,o)P=O(v,h)G=9162646-348568 o=q[a]b=P-S L=C(b)h=nil o[P]=L P=nil end end end else if G<-407393+3648599 then if G<-747317+3173468 then if G<1510318-(-663293)then if G<482188+1626000 then H=I(H)v=nil D=I(D)p=I(p)H=nil J=I(J)a=nil j=nil M=I(M)O=nil a=X()h=nil J=nil B=nil r=I(r)C=I(C)O=u(1009059+-946246)j={}B=u(-313316+376148)P=I(P)D=A[O]O=u(-567036+629885)v={}G=11313124-(-833841)h=48356-48355 M=D[O]D=X()p=X()P=-398648+398904 r=u(414582-351738)C=u(697765-634952)q[D]=M O=A[C]C=u(1026887+-964048)M=O[C]C=A[B]B=u(-553424+616260)O=C[B]B=A[r]r=u(1038276+-975456)C=B[r]o=P B=640935+-640935 r=X()q[r]=B B=959955-959953 q[p]=B B={}q[a]=j P=197532+-197531 j=125727-125727 L=P P=-79564+79564 b=L<P P=h-L else F=q[J]G=F and-173643+14412198 or 2749499-(-580501)E=F end else U=u(-158908+221729)G=A[U]J=q[s[913980+-913972]]H=-232021+232021 U=G(J,H)G=-590590+17321063 end else if G<2241156-(-730596)then G=8566126-218685 H=-651718+651750 J=q[s[-697107-(-697110)]]U=J%H M=q[s[-288204+288208]]C=q[s[993693+-993691]]r=143383-143381 h=q[s[470221+-470218]]j=163291-163278 v=h-U h=402750+-402718 a=v/h p=j-a B=r^p O=C/B B=419636+-419635 D=M(O)M=4295160766-193470 H=D%M D=417822-417820 M=D^U J=H/M U=nil M=q[s[734904+-734900]]C=J%B B=4295523873-556577 O=C*B D=M(O)M=q[s[910650-910646]]O=M(J)H=D+O D=-185194-(-250730)C=-924001-(-989537)M=H%D j=83836+-83580 O=H-M D=O/C C=-673929+674185 r=946125-945869 O=M%C B=M-O C=B/r H=nil r=291815+-291559 B=D%r p=D-B D=nil r=p/j M=nil J=nil p={O;C,B;r}O=nil q[s[-922641-(-922642)]]=p C=nil B=nil r=nil else G=382974+7048691 g=974533-974531 V=Q[g]g=q[z]t=V==g Z=t end end else if G<3178575-(-809144)then if G<4108637-750442 then q[J]=E G=q[J]G=G and 4736804-(-819710)or 14142035-(-49776)else W=u(-324728+387549)U=u(625990-563147)G=A[W]W=G(U)G=A[u(505101+-442248)]W={}end else if G<4607466-348392 then H=q[s[-453516-(-453522)]]J=H==U G=7599036-(-223607)W=J else G=true G=G and 11880969-785619 or 14294673-(-939568)end end end end else if G<6561556-23058 then if G<-1022720+6594050 then if G<258542+4797356 then if G<3636706-(-882207)then if G<4397429-26158 then G=10607181-856068 else c=u(1036561+-973743)G=A[c]L=u(-299845-(-362700))o=A[L]c=G(o)G=u(124162+-61315)A[G]=c G=16245289-(-191116)end else C=not O H=H+D J=H<=M J=C and J C=H>=M C=O and C J=C or J C=609822+12527813 G=J and C J=-299737+464311 G=G or J end else if G<5702406-568550 then v=not a p=p+j B=p<=r B=v and B v=p>=r v=a and v B=v or B v=-911361+14271222 G=B and v B=15928663-(-333236)G=G or B else G=-709003+2689001 end end else if G<-381343+6136915 then if G<273525+5343541 then J=X()G=true H=u(254942+-192098)U=f M=X()q[J]=G W=A[H]C=u(-589262-(-652096))H=u(1004643+-941810)G=W[H]H=X()q[H]=G G=y(742120+3221770,{})q[M]=G G=false D=X()q[D]=G B=T(-177904+1739592,{D})O=A[C]C=O(B)G=C and-864565+7991761 or 1045596+454275 W=C else G=true G=G and-705310+11257539 or 6347443-(-652538)end else if G<6875787-908293 then h=R(12456757-(-499292),{})r=X()j=888455-888390 p=-601745-(-601748)q[r]=W G=q[C]W=G(p,j)p=X()q[p]=W G=-378620+378620 j=G G=784591-784591 v=u(167714-104880)a=G W=A[v]v={W(h)}G={k(v)}v=G W=235661+-235659 G=v[W]W=u(-780187+843037)c=u(-615456+678274)h=G G=A[W]P=q[H]F=A[c]c=F(h)F=u(-592193+655023)E=P(c,F)P={E()}W=G(k(P))P=X()q[P]=W W=-338144+338145 E=q[p]F=E E=-404200+404201 c=E E=341077-341077 G=-651807+15367085 o=c<E E=W-c else S={}C=nil L=X()h={}P=X()O=nil t=nil w=u(-263747-(-326569))Q=u(-694343-(-757167))q[P]=h b=u(806488+-743672)o=R(14755119-(-746393),{P,r;p;D})h=X()M=nil q[h]=o C=u(513240+-450413)o={}q[L]=o B=nil o=A[b]z=q[L]j=nil v=nil D=I(D)N={[w]=z;[Q]=t}b=o(S,N)o=R(1192670-631023,{L;P;a;r,p,h})J=b P=I(P)h=I(h)j=477310+5834388619806 p=I(p)D=u(-262409-(-325249))H=o r=I(r)G=A[u(690842-627997)]a=I(a)M=A[D]L=I(L)O=A[C]p=u(-786034-(-848872))r=H(p,j)B=J[r]J=nil r=u(-654582-(-717419))r=O[r]C={r(O,B)}W={}D=M(k(C))M=D()H=nil end end end else if G<-527912+8028535 then if G<7811426-739461 then if G<7590715-801868 then if G<513222+6187180 then G=-652609+10547201 J=q[s[69608-69605]]H=-615650+615867 U=J*H J=852375+-852118 W=U%J q[s[263427-263424]]=W else J=q[s[28216-28215]]M=-650897-(-650898)D=-261364-(-261366)H=J(M,D)J=753769+-753768 U=H==J G=U and 14029401-(-576891)or 15323761-790807 W=U end else G=i(10168391-(-1004398),{M})F={G()}W={k(F)}G=A[u(-177533+240352)]end else if G<410365+6820451 then O=q[D]G=-424057+1923928 W=O else G=l G=9851194-28461 W=Z end end else if G<9060694-774481 then if G<397168+7510413 then q[s[-312822+312827]]=W U=nil G=-908358+9902023 else v=u(-172678-(-235510))a=A[v]G=895989+419468 v=u(-130063-(-192909))j=a[v]r=j end else if G<389853+7983416 then H=u(-611347-(-674179))G=A[u(-929354-(-992179))]J=A[H]H=u(-825592-(-888428))U=J[H]H=q[s[-524129-(-524130)]]J={U(H)}W={k(J)}else P=#v o=-239387-(-239387)h=P==o G=h and 925751+5358443 or-38186+1973825 end end end end end else if G<541736+12576929 then if G<11511279-422708 then if G<547754+9387915 then if G<10150432-383340 then if G<246667+9389204 then if G<279725+8734323 then G=q[s[-58266-(-58273)]]G=G and 2302871-76358 or 348614+16381859 else W=u(-93697+156544)G=A[W]U=u(-673874-(-736729))W=A[U]U=u(646790+-583935)A[U]=G G=-277403+13378737 U=u(635213+-572366)A[U]=W U=q[s[996332+-996331]]J=U()end else W={J}G=A[u(-274109+336924)]end else if G<-173419+10052685 then q[J]=W G=-987382+13711392 else J=q[s[273781-273778]]H=812234-812233 U=J~=H G=U and 917617+1747958 or 7531758-846018 end end else if G<-110384+10405083 then if G<-600989+10775358 then o=u(-607031+669878)G=A[o]o=u(-86450+149305)A[o]=G G=16346215-(-90190)else l=q[J]Z=l G=l and 571628+15374955 or-254027+11188599 end else if G<9777804-(-1044326)then G=287494+3998068 else K=-299765-(-299766)q[J]=Z g=q[N]V=g+K t=Q[V]l=j+t t=-644186+644442 G=l%t j=G V=q[S]t=a+V V=-251545-(-251801)G=716982+12007028 l=t%V a=l end end end else if G<13451693-860122 then if G<995728+10516381 then if G<11113437-(-258040)then if G<893122+10260046 then o=443143-443137 c=334047+-334046 G=q[C]F=G(c,o)G=u(772983+-710136)A[G]=F o=u(501788+-438941)c=A[o]o=551845-551843 G=c>o G=G and 4117766-(-354877)or 132717+10041169 else G=13439942-338608 end else H=29435-29418 J=q[s[-126698-(-126700)]]U=J*H J=18753+11562194684870 W=U+J J=1011812-1011811 U=675709+35184371413123 G=W%U q[s[257494-257492]]=G G=6775258-89518 U=q[s[389796-389793]]W=U~=J end else if G<11258439-(-839242)then P=#v G=918695-(-1016944)o=-332441-(-332441)h=P==o else S=not b P=P+L h=P<=o h=S and h S=P>=o S=b and S h=S or h S=14985317-212140 G=h and S h=654887+11256790 G=G or h end end else if G<11853843-(-990796)then if G<-734852+13357228 then G=A[u(-685060-(-747877))]W={}else L=I(L)Q=nil G=276435+14438843 S=I(S)N=I(N)z=I(z)b=I(b)w=I(w)end else if G<452903+12630281 then J=u(705787-642935)W=5010403-(-500883)H=-668004+9319915 U=J^H G=W-U W=u(734719-671893)U=G G=W/U W={G}G=A[u(-1026705+1089528)]else G=true G=G and-383575+9415679 or 12913838-303087 end end end end else if G<42342+14738824 then if G<-572513+14885848 then if G<14113783-(-80865)then if G<-51904+14223741 then if G<12261742-(-941038)then B=534459+-534459 r=225993-225738 J=H G=q[s[-1008139-(-1008140)]]C=G(B,r)G=570631+4449352 U[J]=C J=nil else B=p c=u(748716-685872)F=A[c]c=u(-564545-(-627399))E=F[c]F=E(U,B)E=q[s[-300697+300703]]c=E()G=5852228-731367 P=F+c c=-499333+499334 h=P+O P=272172-271916 v=h%P P=H[J]O=v F=O+c B=nil E=M[F]h=P..E H[J]=h end else G=true G=-487717+7487698 end else if G<713285+13535048 then G=3586805-256805 F=j==a E=F else H=5913088-751045 J=u(396273+-333432)U=J^H W=-813335+5210679 G=W-U W=u(-626062-(-688919))U=G G=W/U W={G}G=A[u(218768+-155917)]end end else if G<13972213-(-693132)then if G<15539847-968384 then J=q[s[-584133-(-584135)]]H=q[s[946003-946000]]U=J==H G=14344632-(-261660)W=U else G=W and 1158349-(-776069)or 8629344-(-364321)end else if G<14024145-(-726433)then E=E+c L=not o W=E<=F W=L and W L=E>=F L=o and L W=L or W L=16534455-604415 G=W and L W=643569+1475887 G=G or W else h=P G=11692353-(-454612)S=h v[h]=S h=nil end end end else if G<789338+15155296 then if G<15945865-536651 then if G<73880+15161675 then if G<16095812-889661 then Z=q[J]W=Z G=Z and 315708+442659 or-1040602+10863335 else G=A[u(339349+-276507)]W={}end else G={}q[s[874941-874939]]=G W=q[s[-264789-(-264792)]]M=W D=35184371162063-(-926769)W=J%D B=u(621352+-558508)q[s[333241-333237]]=W C=1036973-1036718 O=J%C C=-970257-(-970259)D=O+C q[s[-272836-(-272841)]]=D C=A[B]B=u(-745341-(-808176))O=C[B]C=O(U)B=-595369-(-595370)O=u(-932926-(-995755))G=-447613+5568474 H[J]=O r=C O=-159403+159473 p=529367+-529366 j=p p=-411600-(-411600)a=j<p p=B-j end else if G<598449+15248751 then U=q[s[-507328-(-507329)]]W=#U U=-935348+935348 G=W==U G=G and-1021377+12458945 or 7726466-(-620975)else L=X()t=u(-614451-(-677269))b=u(-699621-(-762434))Y=240626-230626 q[L]=E N=27318+-27063 W=A[b]S=495173-495073 b=u(599246-536407)G=W[b]b=786874+-786873 Q=-632413+632415 W=G(b,S)S=-590564-(-590564)b=X()q[b]=W G=q[C]W=G(S,N)S=X()N=737492-737491 q[S]=W z=-670941+670942 G=q[C]w=q[b]K=556961+-556961 W=G(N,w)N=X()q[N]=W W=q[C]w=W(z,Q)W=891763-891762 G=w==W w=X()Q=u(906567-843709)q[w]=G l=A[t]G=u(251935+-189121)W=u(327475-264645)V=q[C]g={V(K,Y)}t=l(k(g))G=h[G]l=u(112774+-49916)Z=t..l z=Q..Z Q=u(201611+-138777)G=G(h,W,z)z=X()q[z]=G W=A[Q]Z=e(7092797-367710,{C,L;p;H,J,P,w;z;b,N;S,r})Q={W(Z)}G={k(Q)}Q=G G=q[w]G=G and 780888+14003836 or-145588+10332831 end end else if G<-410897+16841712 then if G<16010776-37522 then t=809260+-809259 l=Q[t]G=321416+10613156 Z=l else O=nil M=nil C=nil G=-150095+9901208 end else if G<16569930-124765 then G=-264679+4550241 else G={}U=G J=558419+-558418 H=q[s[758504+-758495]]M=H G=4281419-(-738564)H=523115-523114 D=H H=264708+-264708 O=D<H H=J-D end end end end end end end G=#n return k(W)end,function()J=J+(-937779+937780)U[J]=168348+-168347 return J end,function(A)for u=672576-672575,#A,-903015-(-903016)do U[A[u]]=(-985212-(-985213))+U[A[u]]end if f then local G=f(true)local k=n(G)k[u(902569-839747)],k[u(697236+-634388)],k[u(801002+-738171)]=A,M,function()return 255661-(-679420)end return G else return s({},{[u(708422-645574)]=M;[u(377063-314241)]=A;[u(-686646+749477)]=function()return 1375797-440716 end})end end,function(A,u)local k=H(u)local f=function(...)return G(A,{...},u,k)end return f end,function(A)U[A]=U[A]-(-959852+959853)if 608320+-608320==U[A]then U[A],q[A]=nil,nil end end,function(A,u)local k=H(u)local f=function(f,s,n,d,W)return G(A,{f,s;n;d;W},u,k)end return f end return(D(6245945-670177,{}))(k(W))end)(getfenv and getfenv()or _ENV,unpack or table[u(995713-932867)],newproxy,setmetatable,getmetatable,select,{...})end)(...)
