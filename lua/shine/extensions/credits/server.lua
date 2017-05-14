/*Kyle 'Avoca' Abent Credits Season 3
KyleAbent@gmail.com 
*/
local Shine = Shine
local Plugin = Plugin
local HTTPRequest = Shared.SendHTTPRequest


Plugin.HasConfig = true
Plugin.ConfigName = "CreditsConfig.json"

Plugin.DefaultConfig  = { kCreditMultiplier = 1, kCreditsCapPerRound = 200 }

Shine.CreditData = {}
Shine.LinkFile = {}
Shine.BadgeFile = {}
Plugin.Version = "11.16"

local CreditsPath = "config://shine/plugins/credits.json"
local URLPath = "config://shine/CreditsLink.json"
--local BadgeURLPath = "config://shine/BadgesLink.json"
--local BadgesPath = "config://shine/UserConfig.json"


Shine.Hook.SetupClassHook( "ScoringMixin", "AddScore", "OnScore", "PassivePost" )

Shine.Hook.SetupClassHook( "OnoGrow", "OnoEggFilled", "OnOnEggFilled", "PassivePost" )

Shine.Hook.SetupClassHook( "NS2Gamerules", "ResetGame", "OnReset", "PassivePost" )

Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyMist", "BecauseFuckSpammingCommanders", "Replace" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyMed", "SeriouslyFuckIt", "Replace" )
Shine.Hook.SetupClassHook( "Player", "HookWithShineToBuyAmmo", "InTheButt", "Replace" )


Shine.Hook.SetupClassHook( "DoConcedeSequence", "OnConcede", "SaveAllCredits", "pre" )

function Plugin:OnoEggFilled(player)
  self:NotifySalt( player:GetClient(), "You farted.", true )
end

function Plugin:Initialise()
self:CreateCommands()
self.Enabled = true
self.GameStarted = false
self.CreditAmount = 0
self.CreditUsers = {}
self.BuyUsersTimer = {}
self.marinecredits = 0
self.aliencredits = 0
self.marinebonus = 0
self.alienbonus = 0

self.UserStartOfRoundCredits = {}
self.MarineTotalSpent = 0
self.AlienTotalSpent = 0
self.Refunded = false

self.PlayerSpentAmount = {}

self.ShadeInkCoolDown = 0

return true
end


function Plugin:BecauseFuckSpammingCommanders(player)
if not GetGamerules():GetGameStarted() then return end
local CreditCost = 10
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
if self:GetPlayerSaltInfo(Client) < CreditCost then
self:NotifySalt( Client, "%s costs %s salt, you have %s salt. Purchase invalid.", true, String, CreditCost, self:GetPlayerSaltInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerSaltInfo(Client) - CreditCost
//self:NotifySalt( nil, "%s purchased a %s with %s credit(s)", true, Player:GetName(), String, CreditCost)
player:GiveItem(NutrientMist.kMapName)
   Shine.ScreenText.SetText("Salt", string.format( "%s Salt", self:GetPlayerSaltInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 3 
     self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
return
end
function Plugin:SeriouslyFuckIt(player)
if not GetGamerules():GetGameStarted() then return end
 self:SimpleTimer(4, function() self:SpawnIt(player, MedPack.kMapName)  end)

end
 function Plugin:SpawnIt(player, entity)
 if not player or not player:GetIsAlive() then return end
 local CreditCost = 10
 local client = player:GetClient()
local controlling = client:GetControllingPlayer()
local Client = controlling:GetClient()
if Client:GetIsVirtual() then return end
if self:GetPlayerSaltInfo(Client) < CreditCost then
self:NotifySalt( Client, "%s costs %s salt, you have %s salt. Purchase invalid.", true, String, CreditCost, self:GetPlayerSaltInfo(Client))
return
end
self.CreditUsers[ Client ] = self:GetPlayerSaltInfo(Client) - CreditCost
   Shine.ScreenText.SetText("Salt", string.format( "%s Salt", self:GetPlayerSaltInfo(Client) ), Client) 
   self.BuyUsersTimer[Client] = Shared.GetTime() + 3 
     self.PlayerSpentAmount[Client] = self.PlayerSpentAmount[Client]  + CreditCost
return
    CreateEntity( entity, FindFreeSpace(player:GetOrigin(), 1, 4), 1) 
end
function Plugin:InTheButt(player)
if not player or not player:GetIsAlive() then return end
if not GetGamerules():GetGameStarted() then return end
 self:SimpleTimer(4, function() self:SpawnIt(player, AmmoPack.kMapName)    end)
end
 

 --self.CreditData.Users[Client:GetUserId() ] = {credits = self:GetPlayerSaltInfo(Client), name = Client:GetControllingPlayer():GetName() }
            
function Plugin:GenereateTotalCreditAmount()
local salt = 0


    for variant, data in pairs(self.CreditData.Users) do
       salt = salt + self.CreditData.Users[variant].credits
    end
    local count = table.Count(self.CreditData.Users)

   self:NotifyGeneric( nil, "Salt Stats: %s users and %s salt", true, count, salt )
   
end

function Plugin:AdjustSalt()
local credits = 0
Print("%s users", table.Count(self.CreditData.Users))

    for variant, data in pairs(self.CreditData.Users) do
       self.CreditData.Users[variant].credits = self.CreditData.Users[variant].credits * 10
       credits = credits + self.CreditData.Users[variant].credits
    end
    self:SaveAllCredits(false)
Print("%s salt",credits)
end


local function GetPathingRequirementsMet(position, extents)

    local noBuild = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, extents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
    
end

function Plugin:HasLimitOfCragInHive(Player, mapname, teamnumbber, limit, Client)
--3 crag outside of hive and 5 inside hive
local entitycount = 0
local entities = {}
if limitMod == true then limit = 8 end
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", teamnumbber)) do
        if entity:GetMapName() == mapname and entity:GetOwner() == Player and GetIsOriginInHiveRoom( entity:GetOrigin() ) then entitycount = entitycount + 1 table.insert(entities, entity) end 
    end
    
     //             <
    if entitycount ~= limit then return false end
     return true
end
function Plugin:HasLimitOfCragOutHive(Player, mapname, teamnumbber, limit, Client)
local entitycount = 0
local entities = {}
if limitMod == true then limit = 8 end
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", teamnumbber)) do
        if entity:GetMapName() == mapname and entity:GetOwner() == Player and not GetIsOriginInHiveRoom( entity:GetOrigin() )  then entitycount = entitycount + 1 table.insert(entities, entity) end 
    end
    
     //             <
    if entitycount ~= limit then return false end
     return true
end

function Plugin:HasLimitOf(Player, mapname, teamnumbber, limit, Client)
local entitycount = 0
local entities = {}
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", teamnumbber)) do
        if entity:GetMapName() == mapname and entity:GetOwner() == Player then entitycount = entitycount + 1 table.insert(entities, entity) end 
    end
    
     //             <
    if entitycount ~= limit then return false end
   local delete = GetSetupConcluded()
      if delete then
            if #entities > 0 then
            local entity = table.random(entities)
             if entity:GetMapName() == Sentry.kMapName or entity:GetMapName() == Wall.kMapName or entity:GetMapName() == Observatory.kMapName or entity:GetMapName() == ARCCredit.kMapName  then return true end
                DestroyEntity(entity)
                 self:NotifySalt( Client, "(Logic Fallacy):Deleted your old %s so you can spawn a new one.", true, mapname)
                 return false  
            end
      end
     return true
end
function Plugin:PregameLimit(teamnum)
local entitycount = 0
local entities = {}
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", teamnum)) do
       entitycount = entitycount + 1  
    end
       if entitycount <= 99 then return false end
       return false --EH?
end
 /*
function Plugin:LoadBadges()
     local function UsersResponse( Response )
		local UserData = json.decode( Response )
		self.UserData = UserData
		 Shine.SaveJSONFile( self.UserData, BadgesPath  )
		 
		         self:SimpleTimer(4, function ()
        Shared.ConsoleCommand("sh_reloadusers" ) 
        end)
        
      end
       local BadgeFiley = Shine.LoadJSONFile( BadgeURLPath )
        self.BadgeFile = BadgeFiley
        HTTPRequest( self.BadgeFile.LinkToBadges, "GET", UsersResponse)
end
*/
local function AddOneScore(Player,Points,Res, WasKill)
            local points = Points
            local wasKill = WasKill
            local displayRes = ConditionalValue(type(res) == "number", res, 0)
            Server.SendNetworkMessage(Server.GetOwner(Player), "ScoreUpdate", { points = points, res = displayRes, wasKill = wasKill == true }, true)
            Player.score = Clamp(Player.score + points, 0, 100)

            if not Player.scoreGainedCurrentLife then
                Player.scoreGainedCurrentLife = 0
            end

            Player.scoreGainedCurrentLife = Player.scoreGainedCurrentLife + points   

end
function Plugin:PrimalScreamPointBonus(who, Points)
  local lerk = Shared.GetEntity( who.primaledID ) 
  if lerk ~= nil then
      local client = lerk.getClient and lerk:GetClient()
      if client then 
        local player = client:GetControllingPlayer()
         if player then
          player:AddScore(Points * 0.3)
          end
      end
  end
end
function Plugin:OnScore( Player, Points, Res, WasKill )
if Points ~= nil and Points ~= 0 and Player and not Shared.GetCheatsEnabled() then
   if not self.GameStarted then Points = 1  AddOneScore(Player,Points,Res, WasKill) end
  if WasKill and Player:isa("Alien") then self:PrimalScreamPointBonus(Player, Points) end
 local client = Player:GetClient()
 if not client then return end
         
    local addamount = Points * self.Config.kCreditMultiplier     
 local controlling = client:GetControllingPlayer()
 
         if Player:GetTeamNumber() == 1 then
         self.marinecredits = self.marinecredits + addamount
        elseif Player:GetTeamNumber() == 2 then
         self.aliencredits = self.aliencredits + addamount
         end
         
self.CreditUsers[ controlling:GetClient() ] = self:GetPlayerSaltInfo(controlling:GetClient()) + addamount
Shine.ScreenText.SetText("Salt", string.format( "%s Salt", self:GetPlayerSaltInfo(controlling:GetClient()) ), controlling:GetClient()) 
end
end
function Plugin:NotifySiege( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Siege]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end




function Plugin:OnReset()
  if self.GameStarted and not self.Refunded then
       self:NotifySalt( nil, "Did you spend any credits only for the round to reset? If so, then no worries! - You have just been refunded!", true )
       
              Shine.ScreenText.End("Salt")  
              Shine.ScreenText.End(80)
              Shine.ScreenText.End(81)  
              Shine.ScreenText.End(82)  
              Shine.ScreenText.End(83)  
              Shine.ScreenText.End(84)  
              Shine.ScreenText.End(85)  
              Shine.ScreenText.End(86)   
              Shine.ScreenText.End(87)  
              self.marinecredits = 0
              self.aliencredits = 0
              self.marinebonus = 0
              self.alienbonus = 0
              self.MarineTotalSpent = 0 
              self.AlienTotalSpent = 0
              self.CreditUsers = {}
              self.PlayerSpentAmount = {}
          
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  Shine.ScreenText.Add( "Salt", {X = 0.20, Y = 0.95,Text = string.format( "%s Salt", self:GetPlayerSaltInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
    self.Refunded = true
   end     
end

function Plugin:OnFirstThink() 
local CreditsFile = Shine.LoadJSONFile( CreditsPath )
self.CreditData = CreditsFile

// for double credit weekend change 1 to 2 :P

     //   local date = os.date("*t", Shared.GetSystemTime())
     //   local day = date.day
     //   if string.find(day, "Friday") or string.find(day, "Saturday") or day == string.find(day, "Sunday") then
       // kCreditMultiplier = 1
     //   else
        //kCreditMultiplier = 1
      //  end
        

/*
     local function UsersResponse( Response )
		local UserData = json.decode( Response )
		self.UserData = UserData
		 Shine.SaveJSONFile( self.UserData, BadgesPath  )
		 
		         self:SimpleTimer(4, function ()
        Shared.ConsoleCommand("sh_reloadusers" ) 
        end)
        
      end
       local BadgeFiley = Shine.LoadJSONFile( BadgeURLPath )
        self.BadgeFile = BadgeFiley
        HTTPRequest( self.BadgeFile.LinkToBadges, "GET", UsersResponse)
        */
//end

        if not Shine.Timer.Exists("CommTimer") then
        	Shine.Timer.Create( "CommTimer", 300, -1, function() self:CommCredits() end )
      end

end
 function Plugin:CommCredits()
             
 self:GiveCommCredits() 
 
 end
 function Plugin:GiveCommCredits()
   self:GenereateTotalCreditAmount()
 local salt = 100 * self.Config.kCreditMultiplier
   if self.Config.kCreditMultiplier == 1 then
 self:NotifySalt( nil, "%s Salt for each commander", true, salt)
 elseif self.Config.kCreditMultiplier == 2 then
  self:NotifySaltDC( nil, "%s Salt for each commander", true, salt)
 end
 
  local Players = Shine.GetAllPlayers()
   for i = 1, #Players do
    local player = Players[ i ]
     if player and player:isa("Commander") then
      self.CreditUsers[ player:GetClient() ] = self:GetPlayerSaltInfo(player:GetClient()) + salt
          if self.GameStarted then
          Shine.ScreenText.SetText("Salt", string.format( "%s Salt", self:GetPlayerSaltInfo(player:GetClient()) ), player:GetClient()) 
          end
      end
   end
 end
 local function GetCreditsToSave(self, Client, savedamount)
            local cap = self.Config.kCreditsCapPerRound 
          local creditstosave = self:GetPlayerSaltInfo(Client)
          local earnedamount = creditstosave - savedamount
          if earnedamount > cap then 
          creditstosave = savedamount + cap
          self:NotifySalt( Client, "%s Salt cap per round exceeded. You earned %s salt this round. Only %s are saved. So your new total is %s", true, self.Config.kCreditsCapPerRound, earnedamount, self.Config.kCreditsCapPerRound, creditstosave )
          Shine.ScreenText.SetText("Salt", string.format( "%s Salt", creditstosave ), Client) 
           end
    return creditstosave
 end
function Plugin:SaveCredits(Client, disconnected)
       local Data = self:GetCreditData( Client )
       if Data and Data.credits then 
         if not Data.name or Data.name ~= Client:GetControllingPlayer():GetName() then
           Data.name = Client:GetControllingPlayer():GetName()
           end        
       Data.credits = GetCreditsToSave(self, Client, Data.credits)
       else 
      self.CreditData.Users[Client:GetUserId() ] = {credits = self:GetPlayerSaltInfo(Client), name = Client:GetControllingPlayer():GetName() }
       end
     if disconnected == true then Shine.SaveJSONFile( self.CreditData, CreditsPath  ) end
end

function Plugin:JoinTeam( Gamerules, Player, NewTeam, Force ) 

    if not Player:isa("Commander") and Gamerules:GetGameStarted() and NewTeam == 0 then
     self:DestroyAllSaltStructFor(Player:GetClient())
    end

end

function Plugin:DestroyAllSaltStructFor(Client)
//Intention: Kill Salt Structures if client f4s, otherwise 'limit' becomes nil and infinite 
local Player = Client:GetControllingPlayer()
        for index, entity in ipairs(GetEntitiesWithMixinForTeam("Live", Player:GetTeamNumber())) do
        if not entity:isa("Commander") and not entity:isa("AdvancedArmory") and entity:GetOwner() == Player then entity:Kill() end 
      end
    
end
function Plugin:ClientDisconnect(Client)
self:SaveCredits(Client, true)
self:DestroyAllSaltStructFor(Client)
end
function Plugin:GetPlayerSaltInfo(Client)
   local Credits = 0
       if self.CreditUsers[ Client ] then
          Credits = self.CreditUsers[ Client ]
       elseif not self.CreditUsers[ Client ] then 
          local Data = self:GetCreditData( Client )
           if Data and Data.credits then 
           Credits = Data.credits 
           end
       end
return math.round(Credits, 2)
end
local function GetIDFromClient( Client )
	return Shine.IsType( Client, "number" ) and Client or ( Client.GetUserId and Client:GetUserId() ) // or nil //or nil was blocked but im testin
 end
function Plugin:GetCreditData(Client)
  if not self.CreditData then return nil end
  if not self.CreditData.Users then return nil end
  local ID = GetIDFromClient( Client )
  if not ID then return nil end
  local User = self.CreditData.Users[ tostring( ID ) ] 
  if not User then 
     local SteamID = Shine.NS2ToSteamID( ID )
     User = self.CreditData.Users[ SteamID ]
     if User then
     return User, SteamID
     end
     local Steam3ID = Shine.NS2ToSteam3ID( ID )
     User = self.CreditData.Users[ ID ]
     if User then
     return User, Steam3ID
     end
     return nil, ID
   end
return User, ID
end

 function Plugin:ClientConfirmConnect(Client)
 
 if Client:GetIsVirtual() then return end
 
  Shine.ScreenText.Add( "Salt", {X = 0.20, Y = 0.85,Text = string.format( "%s Salt", self:GetPlayerSaltInfo(Client) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Client )
    self.PlayerSpentAmount[Client] = 0
    
    
 end
function Plugin:SaveAllCredits()
               local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self:SaveCredits(Player:GetClient(), false)
                  end
             end
                     
            local LinkFiley = Shine.LoadJSONFile( URLPath )
            self.LinkFile = LinkFiley                
                 self:SimpleTimer( 2, function() 
                 Shine.SaveJSONFile( self.CreditData, CreditsPath  )
                 end)
                             
                 self:SimpleTimer( 4, function() 
                 HTTPRequest( self.LinkFile.LinkToUpload, "POST", {data = json.encode(self.CreditData)})
                 end)
                 
               --  self:SimpleTimer( 12, function() 
               --  self:LoadBadges()
               --  end)
                 
                 self:SimpleTimer( 14, function() 
                 self:NotifySalt( nil, "http://credits.ns2siege.com - credit ranking updated", true)
                 end)        
                 

end
function Plugin:DeductSaltIfNotPregame(self, who, amount, delayafter)
        --Print("DeductSaltIfNotPregame, amount is %s", amount)
 if ( GetGamerules():GetGameStarted() and not GetGamerules():GetCountingDown() )  then
    self.CreditUsers[ who:GetClient() ] = self:GetPlayerSaltInfo(who:GetClient()) - amount
     self.PlayerSpentAmount[who:GetClient()] = self.PlayerSpentAmount[who:GetClient()]  + amount
   self.BuyUsersTimer[who:GetClient()] = Shared.GetTime() + delayafter
   Shine.ScreenText.SetText("Salt", string.format( "%s Salt", self:GetPlayerSaltInfo(who:GetClient()) ), who) 
 else
 self:NotifySalt(who, "Pregame purchase free of charge", true) 
 end
 
end
function Plugin:SetGameState( Gamerules, State, OldState )
       if State == kGameState.Countdown then
      
          
        self.GameStarted = true
        self.Refunded = false
              Shine.ScreenText.End(80)
              Shine.ScreenText.End(81)  
              Shine.ScreenText.End(82)  
              Shine.ScreenText.End(83)  
              Shine.ScreenText.End(84)  
              Shine.ScreenText.End(85)  
              Shine.ScreenText.End(86)
              Shine.ScreenText.End(87)  
          Shine.ScreenText.End("Salt")    
              self.marinecredits = 0
              self.aliencredits = 0
              self.marinebonus = 0
              self.alienbonus = 0
              self.MarineTotalSpent = 0
              self.AlienTotalSpent = 0
              self.PlayerSpentAmount = {}
              
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                  self.PlayerSpentAmount[Player:GetClient()] = 0
                  //Shine.ScreenText.Add( "Credits", {X = 0.20, Y = 0.95,Text = "Loading Credits...",Duration = 1800,R = 255, G = 0, B = 0,Alignment = 0,Size = 3,FadeIn = 0,}, Player )
                  Shine.ScreenText.Add( "Salt", {X = 0.20, Y = 0.95,Text = string.format( "%s Salt", self:GetPlayerSaltInfo(Player:GetClient()) ),Duration = 1800,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 3,FadeIn = 0,}, Player:GetClient() )
                  end
              end
              
      end        
              
     if State == kGameState.Team1Won or State == kGameState.Team2Won or State == kGameState.Draw then
     
      self.GameStarted = false
          
                 self:SimpleTimer(4, function ()
       
              local Players = Shine.GetAllPlayers()
              for i = 1, #Players do
              local Player = Players[ i ]
                  if Player then
                 // self:SaveCredits(Player:GetClient())
                     if Player:GetTeamNumber() == 1 or Player:GetTeamNumber() == 2 then
                    Shine.ScreenText.Add( 80, {X = 0.40, Y = 0.15,Text = "Total Salt Mined:".. math.round((Player:GetScore()  + ConditionalValue(Player:GetTeamNumber() == 1, self.marinebonus, self.alienbonus)), 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                    Shine.ScreenText.Add( 81, {X = 0.40, Y = 0.20,Text = "Total Salt Spent:".. self.PlayerSpentAmount[Player:GetClient()], Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,}, Player )
                     end
                  end
             end
      end)
      
      
            self:SimpleTimer( 8, function() 
       local LinkFiley = Shine.LoadJSONFile( URLPath )
        self.LinkFile = LinkFiley
            self:SaveAllCredits()
            end)
            
            
           //   local Time = Shared.GetTime()
          //   if not Time > kMaxServerAgeBeforeMapChange then
                 self:SimpleTimer( 25, function() 
               --  self:LoadBadges()
                 end)
       

    //  self:SimpleTimer(3, function ()    
    //  Shine.ScreenText.Add( 82, {X = 0.40, Y = 0.10,Text = "End of round Stats:",Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    // Shine.ScreenText.Add( 83, {X = 0.40, Y = 0.25,Text = "(Server Wide)Total Credits Earned:".. math.round((self.marinecredits + self.aliencredits), 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 84, {X = 0.40, Y = 0.25,Text = "(Marine)Total Credits Earned:".. math.round(self.marinecredits, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 85, {X = 0.40, Y = 0.30,Text = "(Alien)Total Credits Earned:".. math.round(self.aliencredits, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 86, {X = 0.40, Y = 0.35,Text = "(Marine)Total Credits Spent:".. math.round(self.MarineTotalSpent, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
    //  Shine.ScreenText.Add( 87, {X = 0.40, Y = 0.40,Text = "(Alien)Total Credits Spent:".. math.round(self.AlienTotalSpent, 2), Duration = 120,R = math.random(0,255), G = math.random(0,255), B = math.random(0,255),Alignment = 0,Size = 4,FadeIn = 0,} )
  //    end)
  end
     
end

function Plugin:NotifyGeneric( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Admin Abuse]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifySalt( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Salt]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
function Plugin:NotifySaltDC( Player, String, Format, ... )
Shine:NotifyDualColour( Player, 255, 165, 0,  "[Double Salt Weekend]",  math.random(0,255), math.random(0,255), math.random(0,255), String, Format, ... )
end
 function Plugin:TunnelExistsNearHiveFor(who)
  self:NotifySalt( who:GetClient(), "You already have a tunnelentrance at hive, you derp! YOU MADE ME TYPE THIS STATEMENT 4 U!", true)
end
function Plugin:Cleanup()
	self:Disable()
	self.BaseClass.Cleanup( self )    
	self.Enabled = false
end
local function GetIsAlienInSiege(Player)
   if  Player.GetLocationName and 
   string.find(Player:GetLocationName(), "siege") or string.find(Player:GetLocationName(), "Siege") then
   return true
    end
    return false
 end
local function PerformBuy(self, who, String, whoagain, cost, reqlimit, reqground,reqpathing, setowner, delayafter, mapname,limitof, techid)
   local autobuild = false 
   local success = false

if whoagain:GetHasLayStructure() then 
self:NotifySalt(who, "Empty laystructure before buying structure, newb. You're such a newb.", true)
return
end

 
if whoagain:isa("Alien") and mapname == Crag.kMapName then 


   if  GetIsOriginInHiveRoom( whoagain:GetOrigin() ) then
     limitof = 5 
if self:HasLimitOfCragInHive(whoagain, mapname, whoagain:GetTeamNumber(), limitof, who) then 
self:NotifySalt(who, "Limit of %s %s inside hive room.", true, limitof, mapname)
return
end
    end
limitof = 8

if self:HasLimitOfCragOutHive(whoagain, mapname, whoagain:GetTeamNumber(), limitof, who) then 
self:NotifySalt(who, "Limit of %s %s outside hive room.", true, limitof, mapname)
return
end

else

if self:HasLimitOf(whoagain, mapname, whoagain:GetTeamNumber(), limitof, who) then 
self:NotifySalt(who, "Limit of %s per %s per player ya noob", true, limitof, mapname)
return
end

end

if reqground then

if not whoagain:GetIsOnGround() then
 self:NotifySalt( who, "You must be on the ground to purchase %s", true, mapname)
 return
 end
 
 end
 
 if reqpathing then 
 if not GetPathingRequirementsMet(Vector( whoagain:GetOrigin() ),  GetExtents(kTechId.MAC) ) then
self:NotifySalt( who, "Pathing does not exist in this placement. Purchase invalid.", true)
return 
end
 end
 

self:DeductSaltIfNotPregame(self, whoagain, cost, delayafter)


local entity = nil 

         if not whoagain:isa("Exo") and ( mapname ~= NutrientMist.kMapName and mapname ~= EnzymeCloud.kMapName 
         and mapname ~= HallucinationCloud.kMapName  ) then 
          whoagain:GiveLayStructure(techid, mapname)
        else
           entity = CreateEntity(mapname, FindFreeSpace(whoagain:GetOrigin(), 1, 4), whoagain:GetTeamNumber()) 
           if entity.SetOwner then entity:SetOwner(whoagain) end
          if entity.SetConstructionComplete then  entity:SetConstructionComplete() end
              if entity:isa("PoopEgg") or entity:isa("Whip") then ent:SetSalty() end
        end


if entity then 
local supply = LookupTechData(entity:GetTechId(), kTechDataSupply, nil) or 0
whoagain:GetTeam():RemoveSupplyUsed(supply)
end
   local delaytoadd = not GetSetupConcluded() and 4 or delayafter
   Shine.ScreenText.SetText("Salt", string.format( "%s Salt", self:GetPlayerSaltInfo(who) ), who) 
self.BuyUsersTimer[who] = Shared.GetTime() + delaytoadd
--Shared.ConsoleCommand(string.format("sh_addpool %s", cost)) 
  



end
local function FirstCheckRulesHere(self, Client, Player, String, cost, isastructure)
local Time = Shared.GetTime()
local NextUse = self.BuyUsersTimer[Client]
if NextUse and NextUse > Time and not Shared.GetCheatsEnabled() then
self:NotifySalt( Client, "Please wait %s seconds before purchasing %s. Thanks.", true, string.TimeToString( NextUse - Time ), String)
return true
end
   if isastructure then 
if ( not GetGamerules():GetGameStarted() and self:PregameLimit(Player:GetTeamNumber()) ) then
self:NotifySalt( Client, "live count reached for pregame", true)
return true
end

end

/*
local gameRules = GetGamerules()
if gameRules:GetGameStarted() and gameRules:GetIsSuddenDeath() then
self:NotifySalt( Client, "Buying in suddendeath is not supported right now.", true)
return
end
*/
if Player:isa("Commander") or not Player:GetIsAlive() then 
      self:NotifySalt( Client, "Either you're dead, or a commander... Really no difference between the two.. anyway, no credit spending for you.", true)
return true
end

/*
if Player then
 self:NotifySalt( Client, "Purchases currently disabled. ", true)
 return
end
*/

if ( GetGamerules():GetGameStarted() and not GetGamerules():GetCountingDown()  )  then 
local playeramt =  self:GetPlayerSaltInfo(Client)
 if playeramt < cost then 
   --Print("player has %s, cost is %s", playeramt,cost)
self:NotifySalt( Client, "%s costs %s salt, you have %s salt. Purchase invalid.", true, String, cost, self:GetPlayerSaltInfo(Client))
return true
end

end

end
local function TeamOneBuyRules(self, Client, Player, String)

local mapnameof = nil
local delay = 12
local reqpathing = false
local CreditCost = 10
local reqground = false
local limit = 3
local techid = nil

if String == "Scan" then
mapnameof = Scan.kMapName
techid = kTechId.Scan
delay = 10
elseif String == "Medpack" then
mapnameof = MedPack.kMapName
techid = kTechId.MedPack
delay = 10
elseif String == "Observatory"  then
mapnameof = Observatory.kMapName
techid = kTechId.Observatory
CreditCost = 100
elseif String == "Armory"  then
CreditCost = 120
mapnameof = Armory.kMapName
techid = kTechId.Armory
elseif String == "Wall"  then
CreditCost = 100
mapnameof = Wall.kMapName
techid = kTechId.Wall
elseif String == "Sentry"  then
mapnameof = Sentry.kMapName
techid = kTechId.Sentry
limit = 2
CreditCost = 80
elseif String == "BackupBattery"  then
mapnameof = SentryBattery.kMapName
techid = kTechId.SentryBattery
limit = 1
CreditCost = 60
elseif String == "BackupLight"  then
mapnameof = BackupLight.kMapName
techid = kTechId.BackupLight
limit = 2
CreditCost = 40
elseif String == "PhaseGate" then
CreditCost = 150
limit = 2
mapnameof = PhaseGate.kMapName
techid = kTechId.PhaseGate
elseif String == "InfantryPortal" then
mapnameof = InfantryPortal.kMapName
techid = kTechId.InfantryPortal
CreditCost = 150
elseif  String == "RoboticsFactory" then
mapnameof = RoboticsFactory.kMapName
techid = kTechId.RoboticsFactory
CreditCost = 100
elseif String == "Mac" then
techid = kTechId.MAC
CreditCost = 40
mapnameof = MACCredit.kMapName --can be networkvar instead
limit = 20
elseif String == "Arc" then 
techid = kTechId.ARC
CreditCost = 200
mapnameof = ARCCredit.kMapName --can be networkvar instead
limit = 1
elseif String == "Extractor" then 
techid = kTechId.Extractor
CreditCost = 5000
mapnameof = Extractor.kMapName
limit = 1
elseif string == nil then
end

return mapnameof, delay, reqground, reqpathing, CreditCost, limit, techid

end

local function TeamTwoBuyRules(self, Client, Player, String)

local mapnameof = nil
local delay = 12
local reqpathing = false
local reqground = false
local CreditCost = 20
local limit = 3
local techid = nil


if String == "NutrientMist" then 
CreditCost = 10
mapnameof = NutrientMist.kMapName
reqground = true
elseif String == "Contamination"  then
CreditCost = 10
mapnameof = Contamination.kMapName    
techid = kTechId.Contamination
elseif String == "EnzymeCloud" then
CreditCost = 15
mapnameof = EnzymeCloud.kMapName
elseif String == "Hallucination" then
CreditCost = 15
reqpathing = false
 mapnameof = HallucinationCloud.kMapName

elseif String == "Shade" then
CreditCost = 100
mapnameof = Shade.kMapName
techid = kTechId.Shade
elseif String == "Crag" then
CreditCost = 100
mapnameof = Crag.kMapName
techid = kTechId.Crag
elseif String == "Whip" then
CreditCost = 100
mapnameof = Whip.kMapName
techid = kTechId.Whip
elseif String == "Shift" then
CreditCost = 100
mapnameof = Shift.kMapName
techid = kTechId.Shift
elseif String == "Hydra" then
CreditCost = 25
mapnameof = HydraSiege.kMapName
techid = kTechId.Hydra
elseif String == "SaltyEgg" then
CreditCost = 75
mapnameof = PoopEgg.kMapName
techid = kTechId.Egg
limit = 5
elseif String == "Harvester" then
CreditCost = 5000
mapnameof = Harvester.kMapName
techid = kTechId.Harvester
limit = 1
end
       
return mapnameof, delay, reqground, reqpathing, CreditCost, limit, techid

end
local function DeductBuy(self, who, cost, delayafter)
  return self:DeductSaltIfNotPregame(self, who, cost, delayafter)
end
function Plugin:CreateCommands()


local function TBuy(Client, String)
local Player = Client:GetControllingPlayer()
local mapname = nil
local delayafter = 60
local cost = 1
if not Player then return end

 
local Time = Shared.GetTime()
local NextUse = self.ShadeInkCoolDown
if NextUse and NextUse > Time and not Shared.GetCheatsEnabled() then
self:NotifySalt( Client, "Team Cooldown on Ink: %s (thank Jon)", true, string.TimeToString( NextUse - Time ), String)
return true
end

   

 
    if String  == "Ink" then cost = 1.5 mapname = ShadeInk.kMapName
   end
   
    if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
   
      self:DeductSaltIfNotPregame(self, Player, cost, delayafter)


 
  Player:GiveItem(mapname)
   
   self.ShadeInkCoolDown = Shared.GetTime() + delayafter
   
end

local TBuyCommand = self:BindCommand("sh_tbuy", "tbuy", TBuy, true)
TBuyCommand:Help("sh_buywp <weapon name>")
TBuyCommand:AddParam{ Type = "string" }

local function BuyWP(Client, String)
local Player = Client:GetControllingPlayer()
local mapname = nil
local delayafter = 8 
local cost = 1
if not Player then return end

 

   

 
    if String  == "Mines" then cost = 15 mapname = LayMines.kMapName
   elseif String == "Welder" then cost = 10 mapname = Welder.kMapName
   elseif String == "HeavyMachineGun" then cost = 35 mapname = HeavyMachineGun.kMapName
    elseif String  == "Shotgun" then cost = 20 mapname = Shotgun.kMapName 
   elseif String == "FlameThrower" then  cost = 30 mapname = Flamethrower.kMapName 
   elseif String == "GrenadeLauncher" then cost = 30 mapname =   GrenadeLauncher.kMapName 
   elseif String == "ConcGrenade" then cost = 10 mapname = ConcGrenadeThrower.kMapName
   elseif String == "JediConcGrenade" then cost = 5 mapname = JediConcGrenadeThrower.kMapName
   end
   
    if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
    
    
     self:DeductSaltIfNotPregame(self, Player, cost, delayafter)

 
  Player:GiveItem(mapname)
   
end



local BuyWPCommand = self:BindCommand("sh_buywp", "buywp", BuyWP, true)
BuyWPCommand:Help("sh_buywp <weapon name>")
BuyWPCommand:AddParam{ Type = "string" }

local function BuyCustom(Client, String)
local Player = Client:GetControllingPlayer()
local cost = 40
local delayafter = 8
 if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
      local exit, nearhive, count = FindPlayerTunnels(Player)
              if not exit then
              --  Print("No Exit Found!")
             elseif nearhive or ( nearhive and count == 2) then
            -- Print("Tunnel nearhive already exists.")
               self:TunnelExistsNearHiveFor(Player)
             return
             end
     if String == "TunnelEntrance" and Player:isa("Gorge") then
       GorgeWantsEasyEntrance(Player, exit, nearhive)
       DeductBuy(self, Player, cost, delayafter)
     end
end

local BuyCustomCommand = self:BindCommand("sh_buycustom", "buycustom", BuyCustom, true)
BuyCustomCommand:Help("sh_buycustom <custom function> because I want these fine tuned accordingly")
BuyCustomCommand:AddParam{ Type = "string" }

local function BuyClass(Client, String)

local Player = Client:GetControllingPlayer()
local delayafter = 8 
local cost = 1
if not Player then return end

 if String == "JetPack" and not Player:isa("Exo") and not Player:isa("JetPack") then cost = 80 
  elseif String == "RailGun" and not Player:isa("Exo") then cost = 290 delayafter = 25   
  elseif String == "MiniGun" and not Player:isa("Exo") then  cost = 300  delayafter = 25 
  elseif String == "Welder" and not Player:isa("Exo") then  cost = 250  delayafter = 15 
   elseif String == "Flamer" and not Player:isa("Exo") then  cost = 270  delayafter = 15 
  elseif String == "Gorge" then cost = 90
  elseif String == "Lerk" then  cost = 120 
  elseif String == "Fade" then cost = 200
  elseif String == "Onos" then cost = 250
  end
  
 if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
 
            --Messy, could be re-written to only require activation once of string = X then call DeductBuy @ end
         if Player:GetTeamNumber() == 1 then
              if cost == 80 then DeductBuy(self, Player, cost, delayafter)   Player:GiveJetpack()
             elseif cost == 300 then DeductBuy(self, Player, cost, delayafter)  Player:GiveDualExo(Player:GetOrigin())
             elseif cost == 290 then DeductBuy(self, Player, cost, delayafter) Player:GiveDualRailgunExo(Player:GetOrigin())
             elseif cost == 250 then DeductBuy(self, Player, cost, delayafter) Player:GiveDualWelder(Player:GetOrigin())
             elseif cost == 270 then DeductBuy(self, Player, cost, delayafter) Player:GiveDualFlamer(Player:GetOrigin())
             end
         elseif Player:GetTeamNumber() == 2 then
              if cost == 90 then DeductBuy(self, Player, cost, delayafter) Player:CreditBuy(kTechId.Gorge)  
              elseif cost == 120  then   DeductBuy(self, Player, cost, delayafter)  Player:CreditBuy(kTechId.Lerk)
              elseif cost == 200 then  DeductBuy(self, Player, cost, delayafter)   Player:CreditBuy(kTechId.Fade)
              elseif cost == 250 then  DeductBuy(self, Player, cost, delayafter) Player:CreditBuy(kTechId.Onos) 
              end
         end
   

 
   
end


local BuyClassCommand = self:BindCommand("sh_buyclass", "buyclass", BuyClass, true)
BuyClassCommand:Help("sh_buyclass <class name>")
BuyClassCommand:AddParam{ Type = "string" }


local function BuyGlow(Client, String)

local Player = Client:GetControllingPlayer()
local delayafter = 8 
local cost = 5
local color = 1
if not Player then return end

if Player:GetIsGlowing() then
self:NotifySalt( Client, "You're already glowing. Wait until you cease to glow.", true)
 return
end

 if String == "Purple" then color = 1 
  elseif String == "Green" then color = 2
  elseif String == "Gold" then color = 3
  elseif String == "Red" then color = 4
  end
  
 if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
            --Messy, could be re-written to only require activation once of string = X then call DeductBuy @ end
         if Player:GetTeamNumber() == 1 then
              if color == 1 then DeductBuy(self, Player, cost, delayafter)    Player:GlowColor(color, 120)
             elseif color == 2 then DeductBuy(self, Player, cost, delayafter)  Player:GlowColor(color, 120)
             elseif color == 3 then DeductBuy(self, Player, cost, delayafter)  Player:GlowColor(color, 120)
             elseif color == 4 then DeductBuy(self, Player, cost, delayafter)  Player:GlowColor(color, 120)
             end
         elseif Player:GetTeamNumber() == 2 then
         end
   

 
   
end


local BuyGlowCommand = self:BindCommand("sh_buyglow", "buyglow", BuyGlow, true)
BuyGlowCommand:Help("sh_buyglow <color number> ")
BuyGlowCommand:AddParam{ Type = "string" }

local function BuyUpgrade(Client, String)

local Player = Client:GetControllingPlayer()
local delayafter = 8 
local cost = 10
local color = 1
if not Player then return end

 if FirstCheckRulesHere(self, Client, Player, String, cost, false ) == true then return end
  
 if String == "Resupply" then DeductBuy(self, Player, cost, delayafter)  Player.hasresupply = true
  elseif String == "HeavyArmor" then DeductBuy(self, Player, cost, delayafter) Player.heavyarmor = true
  elseif String == "FireBullets" then DeductBuy(self, Player, cost, delayafter) Player.hasfirebullets = true
  elseif String == "RegenArmor" then DeductBuy(self, Player, cost, delayafter) Player.nanoarmor = true
  end
  
   
end


local BuyUpgradeCommand = self:BindCommand("sh_buyupgrade", "buyupgrade", BuyUpgrade, true)
BuyUpgradeCommand:Help("sh_buyupgrade <string> ")
BuyUpgradeCommand:AddParam{ Type = "string" }


local function Buy(Client, String)

local Player = Client:GetControllingPlayer()
local mapnameof = nil
local Time = Shared.GetTime()
local NextUse = self.BuyUsersTimer[Client]
local reqpathing = true
local reqground = true
if not Player then return end
local CreditCost = 10
local techid = nil

if Player:GetTeamNumber() == 1 then 
  mapnameof, delay, reqground, reqpathing, CreditCost, limit, techid = TeamOneBuyRules(self, Client, Player, String)
elseif Player:GetTeamNumber() == 2 then
reqground = false
  mapnameof, delay, reqground, reqpathing, CreditCost, limit, techid  = TeamTwoBuyRules(self, Client, Player, String)
end // end of team numbers

if mapnameof and ( not FirstCheckRulesHere(self, Client, Player, String, CreditCost, true ) == true ) then
 PerformBuy(self, Client, String, Player, CreditCost, true, reqground,reqpathing, true, delay, mapnameof, limit, techid, String) 
end

end



local BuyCommand = self:BindCommand("sh_buy", "buy", Buy, true)
BuyCommand:Help("sh_buy <item name>")
BuyCommand:AddParam{ Type = "string" }

local function Salt(Client, Targets)
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self:NotifySalt( Client, "%s has a total of %s salt", true, Player:GetName(), self:GetPlayerSaltInfo(Player:GetClient()))
end
end

local CreditsCommand = self:BindCommand("sh_salt", "salt", Salt, true, false)
CreditsCommand:Help("sh_salt <name>")
CreditsCommand:AddParam{ Type = "clients" }

local function SetSalt(Client, Targets, Number, Display, Double) --TriggerHappyStoner




for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
self.CreditUsers[ Player:GetClient() ] = Number
Shine.ScreenText.SetText("Salt", string.format("%s Salt", self:GetPlayerSaltInfo(Player:GetClient()) ), Player:GetClient())
   if Display == true then
   self:NotifyGeneric( nil, "set %s's  salt to %s", true, Player:GetName(), Number )
   end
end

end


local SetSaltCommand = self:BindCommand("sh_setsalt", "setsalt", SetSalt)
SetSaltCommand:Help("sh_setsalt <player> <number> <display>")
SetSaltCommand:AddParam{ Type = "clients" }
SetSaltCommand:AddParam{ Type = "number" }
SetSaltCommand:AddParam{ Type = "boolean", Optional = true, Default = true }
SetSaltCommand:AddParam{ Type = "boolean", Optional = true, Default = false }


local function GetSalt(Client)

 self:GenereateTotalCreditAmount()
end


local GetSaltCommand = self:BindCommand("sh_getsalt", "getsalt", GetSalt)
GetSaltCommand:Help("sh_getsalt - pasts amount of users and salt.")

local function AddSalt(Client, Targets, Number, Display, Double)

  if Number > 911 then
      Number = 911
  end 
  
for i = 1, #Targets do
local Player = Targets[ i ]:GetControllingPlayer()
if Double == true then Number = Number * self.Config.kCreditMultiplier end
self.CreditUsers[ Player:GetClient() ] = self:GetPlayerSaltInfo(Player:GetClient()) + Number
Shine.ScreenText.SetText("Salt", string.format( "%s Salt", self:GetPlayerSaltInfo(Player:GetClient()) ), Player:GetClient()) 
   if Display == true then
   self:NotifyGeneric( nil, "gave %s salt to %s (who now has a total of %s)", true, Number, Player:GetName(), self:GetPlayerSaltInfo(Player:GetClient()))
   end
end
end

local AddCreditsCommand = self:BindCommand("sh_addsalt", "addsalt", AddSalt)
AddCreditsCommand:Help("sh_addsalt <player> <number> <display> <double> Choose not to display, or to double the amt if dbl crd is act.")
AddCreditsCommand:AddParam{ Type = "clients" }
AddCreditsCommand:AddParam{ Type = "number" }
AddCreditsCommand:AddParam{ Type = "boolean", Optional = true, Default = true }
AddCreditsCommand:AddParam{ Type = "boolean", Optional = true, Default = false }



local function SaveCreditsCmd(Client)
self:SaveAllCredits(false)
end

local SaveCreditsCommand = self:BindCommand("sh_savecredits", "savecredits", SaveCreditsCmd)
SaveCreditsCommand:Help("sh_savecredits saves all credits online")

end