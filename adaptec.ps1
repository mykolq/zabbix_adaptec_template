Param (
[switch]$version = $false,
[ValidateSet("lld","info")][Parameter(Position=0, Mandatory=$True)][string]$action,
[ValidateSet("pd","ld","ad")][Parameter(Position=1, Mandatory=$True)][string]$part
)
$arcconf="C:\zabbix_agent\diskutils\adaptec\arcconf.exe"
function makeobj ($count,$array)
{
$obj=for ($i = 0; $i -lt ($array | measure -Line).Lines; $i += $count)
{
   $strings = $array | select -First $count -Skip $i
   $table = @{}
   foreach ($string in $strings){ $fstring = $string -split "\s:" ; $table.add($fstring[0].trim(),$fstring[1].trim())}
   New-Object psobject -Property $table
 }
 return $obj
}
function adinfo
{
$nad=4
$adprejson=@{}
$addatapattern='(Controller Status.*|Controller Model.*|Status.*ZMM.*|Controller Serial Number.*)'
$addata=(& $arcconf getconfig 1 ad).split("`n")
$addata=(($addata | Select-String -Pattern $addatapattern) -split '`n')
$adinfo=(makeobj($nad)($addata))
$adinfo | ForEach-Object{
$ID="adapter1"
$adprejson[$ID]=@{
"State"=$_."Controller Status"
"Model"=$_."Controller Model"
"Battery state"=$_."Status"
"SN"=$_."Controller Serial Number"
}
}
$adjson=($adprejson | ConvertTo-Json -Compress) -ireplace '"Battery state":null','"Battery state": "no battery installed"'
return $adjson
}
function pdinfo
{
$npd=6
$pdprejson=@{}
#$pddatapattern='(State.*|Reported Channel.*|Array.*|Model.*|Serial number.*|S.M.A.R.T..*|Last Failure Reason.*|Aborted Commands.*|Bad Target Errors.*|Ecc Recovered Read Errors.*|Failed Read Recovers.*|Failed Write Recovers .*|Format Errors.*|Hardware Errors.*|Hard Read Errors.*|Hard Write Errors.*|Hot Plug Count.*|Media Failures.*|Not Ready Errors.*|Other Time Out Errors.*|Predictive Failures.*|Retry Recovered Read Errors.*|Retry Recovered Write Errors.*)'
$pddatapattern='(State.*|Reported Channel.*|Array.*|Model.*|Serial number.*|S.M.A.R.T..*)'
$pddata=((& $arcconf getconfig 1 pd | select-string -Pattern "Device is a Hard drive" -Context 0,20) -replace ">", "").split("`n")
$pddata=(($pddata | Select-String -Pattern $pddatapattern) -split '`n')
$pdinfo=(makeobj($npd)($pddata))
$pdinfo | ForEach-Object{
$ID=$_."Reported Channel,Device(T:L)"
$pdprejson[$ID]=@{
"State"=$_."State"
"Serial number"=$_."Serial number"
"Model"=$_."Model"
"SMART warnings"=$_."S.M.A.R.T. warnings"
}
}
$pdjson=($pdprejson | ConvertTo-Json -Compress)
return $pdjson
}
function pdlld
{
$npd=2
$pdprejson=@{}
$pddatapattern='(Reported Channel.*|Serial number.*)'
$pddata=((& $arcconf getconfig 1 pd | select-string -Pattern "Device is a Hard drive" -Context 0,12) -replace ">", "").split("`n")
$pddata=(($pddata | Select-String -Pattern $pddatapattern) -split '`n')
$pdinfo=(makeobj($npd)($pddata))
$pds=(($pdinfo | Select-Object -Property 'Reported Channel,Device(T:L)','Serial number') | convertto-json)
$pds = "{"+'"data"'+":"+((($pds -ireplace '("Reported Channel,Device\(T:L\)")','"{#SLOT}"') -ireplace 'Serial number','{#SN}'))+"}"
return $pds
}
function ldinfo
{ 
$nld=3
$ldprejson=@{}
$lddatapattern='(Logical Device name.*|RAID level.*|Status of Logical Device.*)'
$lddata=(& $arcconf getconfig 1 ld).split("`n")
$lddata=(($lddata | Select-String -Pattern $lddatapattern) -split '`n')
$ldinfo=(makeobj($nld)($lddata))
$ldinfo | ForEach-Object{
$ID=$_."Logical Device name"
$ldprejson[$ID]=@{
"State"=$_."Status of Logical Device"
"Raid Level"=$_."RAID level"
}
}
$ldjson=($ldprejson | ConvertTo-Json -Compress)
return $ldjson
}
function ldlld
{ 
$nld=1
$ldprejson=@{}
$lddatapattern='(Logical Device name.*)'
$lddata=(& $arcconf getconfig 1 ld).split("`n")
$lddata=(($lddata | Select-String -Pattern $lddatapattern) -split '`n')
$ldinfo=(makeobj($nld)($lddata))
$lds=(($ldinfo | Select-Object -Property 'Logical Device name') | convertto-json)
$lds = "{"+'"data"'+":"+ "["+(($lds -ireplace 'Logical Device name','{#LDNAME}'))+"]}"
return $lds
}
switch($action){
    "lld" {
        switch($part){
            "ld" { write-host $(ldlld)}
            "pd" { write-host $(pdlld)}
        }
    }
    "info" {
        switch($part) {
           "ad" { write-host $(adinfo) }
           "ld" { write-host $(ldinfo) }
           "pd" { write-host $(pdinfo) }
        }
    }
    default {Write-Host "ERROR: Wrong argument: use 'lld' or 'health'"}
}