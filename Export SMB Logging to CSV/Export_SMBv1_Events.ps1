$exportlist=@()
$Server = $env:computername
$Logzeit = Get-Date -Format "yyyyMMdd_HHmmss"
$Eventinputs =  Get-WinEvent -LogName "Microsoft-Windows-SMBServer/Audit" | Select-Object -First 500

foreach ( $Eventinput in $Eventinputs)

    {

    [xml]$Event = $Eventinput.ToXml()

    $Zeitpunkt =  $Eventinput.timecreated
    $Clientname = $event.event.eventdata.data.'#text'
    # $event.event.eventdata.data.'#text'
    
    $export = New-Object psobject 
    $export | Add-Member -MemberType NoteProperty -Name "Zeitpunkt" -Value $Zeitpunkt
    $export | Add-Member -MemberType NoteProperty -Name "Clientname" -Value $Clientname

    $exportlist += $export

    }

$exportlist | Select-Object "Zeitpunkt", "Clientname" | Export-Csv -Path "C:\install\$Server-$Logzeit-Uhr-SMBv1_Zugriffe.csv" -Delimiter ";" -NoTypeInformation -Encoding UTF8