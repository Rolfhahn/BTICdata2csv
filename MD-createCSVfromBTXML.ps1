#Define $CFGFILE Variable from from the StartCommand Params
param ([string]$CFGFile)

#Declare Crator, Version, ProgramTitle

Write-Host --------------------------------------------------------------------------------
Write-Host MICRODYN AG RH - Create CSVList.csv                            ScriptVersion 1.1
Write-Host --------------------------------------------------------------------------------
Write-Host Description of this Script:
Write-Host Changes the Date and Time of the BT Session Log and Session Capture File to 
Write-Host Start-Time Value from [BT SESSION.XML] and creates a CSV List with all Sessions
Write-Host

#Declare Variables
$ScriptRootPath = (Split-Path -Parent $MyInvocation.MyCommand.Path)+'\'
$ConfigFilePath = $ScriptRootPath+'Configs\'+$CFGFile
$SriptDateTime  = Get-Date -UFormat "%Y-%m-%d_%H-%m-%S"
$LogsPath       = $ScriptRootPath+'Logs\'
$LogFilePath    = $LogsPath+$SriptDateTime+'.log'
$amountoffiles  = 0

#Check if $CFGFile Param exists
if (-not (Test-Path variable:$CFGFile)) {
  Write-Host ScriptRootPath...... : $ScriptRootPath
  Write-Host CFGFilePath......... : $ConfigFilePath
  
  #Check if $LogsPath exists - if it does not exist create Logs Folder under ScriptRootPath
  if (!(Test-Path $LogsPath)) {
    $CreateLogsPathResult=New-Item -ItemType Directory -Path $LogsPath
    if ($CreateLogsPathResult.Exists) {
      Write-Host LogsPath............ : was created
      
      } else {
      Write-Host LogsPath............ : was created
    }
  }

  Write-Host LogsPath............ : $LogsPath 
  Write-Host LogFilePath......... : $LogFilePath

  #Check if $ConfigFilePath - File exists
  if (test-path $ConfigFilePath) {
    $paramsfromconfigfile = Get-Content -Raw -Path $ConfigFilePath | ConvertFrom-Json 
    $CFGFileScriptVersion =$paramsfromconfigfile.properties.ScriptVersion
    $BTXMLPath            =$paramsfromconfigfile.properties.BTXMLPath+'\'
    $BTM4VPath            =$paramsfromconfigfile.properties.BTM4VPath+'\'
    $MDCSVPath            =$paramsfromconfigfile.properties.MDCSVPath+'\'
    if ($paramsfromconfigfile.properties.AjustFileDT -eq 1) {$ModFileCreTime=$True} else {$ModFileCreTime=$False}
    $MDCSVFilePath        =$MDCSVPath+$SriptDateTime+'.csv'
    Write-Host
    Write-Host [CFGFile.json-Content]
    Write-Host CFGFileScriptVersion : $CFGFileScriptVersion
    Write-Host BTXMLPath........... : $BTXMLPath
    Write-Host BTM4VPath........... : $BTM4VPath
    Write-Host MDCSVPath........... : $MDCSVPath
    Write-Host MDCSVFilePath....... : $MDCSVFilePath
    Write-Host AjustFileDateTime... : $ModFileCreTime

    Write-Host
    #pause 

    if ((test-path $BTXMLPath) -and (test-path $BTM4VPath) -and (test-path $MDCSVPath)) {
      Write-Host                        'XMLSessionID,XMLSessionStartTime,XMLSessionDuration,XMLSessionRep,XMLSessionEndpoint,XMLSumOfTouchedFiles,XMLSessionXML,XMLSessionM4V'
      Add-content $MDCSVFilePath -value 'XMLSessionID,XMLSessionStartTime,XMLSessionDuration,XMLSessionRep,XMLSessionEndpoint,XMLSumOfTouchedFiles,XMLSessionXML,XMLSessionM4V'
      
      get-childitem -Path $BTXMLPath -Name -Filter '*.xml' | Sort-Object -Descending | ForEach-Object {
        $Target=$BTXMLPath+$_
        $amountoffiles ++
        $BeforeTimeStamp = [System.IO.File]::GetCreationTime($Target);
     
        $xml = [xml](Get-Content $Target)
        $SessionLSIDXML=($xml.session.lsid)
        $SessionLSeqXML=($xml.session.lseq)
        $StartTimeXML=(Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($xml.session.start_time.timestamp))
        $EndTimeXML=(Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($xml.session.end_time.timestamp))
        $SessionHostNameXML=($xml.session.customer_list.customer.Hostname)
        $SessionRepNameXML=($xml.session.rep_list.representative.username)
        [int]$SessionFileTransferCountXML=($xml.session.file_transfer_count)
        [int]$SessionFileMoveCountXML=($xml.session.file_move_count) 
        [int]$SessionFileDeleteCountXML=($xml.session.file_delete_count) 
        [int]$FileTouchedCount=$SessionFileTransferCountXML+$SessionFileMoveCountXML+$SessionFileDeleteCountXML

        $SessionDuration= New-TimeSpan -Start $StartTimeXML -End $EndTimeXML
        $VideoFileTarget=$BTM4VPath+$SessionLSeqXML+'-'+$SessionLSIDXML+'.m4v'
        if ($ModFileCreTime -eq $true)
        {
          [System.IO.File]::SetCreationTime($Target,$StartTimeXML)
          [System.IO.File]::SetLastAccessTime($Target,$StartTimeXML)
          [System.IO.File]::SetLastWriteTime($Target,$StartTimeXML)
        }
        $VideoFileExists = Test-Path -Path $VideoFileTarget -PathType Leaf
        if ($VideoFileExists)
        {
          if ($ModFileCreTime -eq $true) 
          {
          [System.IO.File]::SetCreationTime($VideoFileTarget,$StartTimeXML)
          [System.IO.File]::SetLastAccessTime($VideoFileTarget,$StartTimeXML)
          [System.IO.File]::SetLastWriteTime($VideoFileTarget,$StartTimeXML)
          }
        } else {
          $VideoFileTarget=''
        }
        $Target='file://'+$Target
        if ($VideoFileTarget -ne'') {$VideoFileTarget='file://'+$VideoFileTarget}
        write-host                        $SessionLSeqXML'-'$SessionLSIDXML' '$StartTimeXML' '$SessionDuration' '$SessionRepNameXML' '$SessionHostNameXML' '$FileTouchedCount' '$Target' '$VideoFileTarget' '$Amountoffiles
        Add-content $MDCSVFilePath -value $SessionLSeqXML'-'$SessionLSIDXML','$StartTimeXML','$SessionDuration','$SessionRepNameXML','$SessionHostNameXML','$FileTouchedCount','$Target','$VideoFileTarget
        
      }

    } else {
      Write-Host
      Write-Host ERROR .............. : script does not run because one of the Folders or Files specified in [CONFIG.JSON] does not exist -ForeGroundColor Red
      Write-Host .................... : or because there is a formatting error in [CONFIG.JSON] -ForegroundColor Red
      Write-Host
    }

  } else {
    Write-Host
    Write-Host ERROR .............. : script does not run because the [CFGFile.json] - file specified in ConfigFilePath does not exist -ForeGroundColor Red
    Write-Host
  }

} else {
  Write-Host
  Write-Host ERROR .............. : script does not run because the -CFGFile param was not set  -ForeGroundColor Red
  Write-Host
}
Write-Host
