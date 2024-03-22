Param(
    [string] [Parameter(Mandatory=$true)] $Tag,
    [string] [Parameter(Mandatory=$true)] $PAT
)

$ErrorActionPreference="Stop";

If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent() ).IsInRole( [Security.Principal.WindowsBuiltInRole] "Administrator")){
	throw "Run command in an administrator PowerShell prompt"
};

If($PSVersionTable.PSVersion -lt (New-Object System.Version("3.0"))){ throw "The minimum version of Windows PowerShell that is required by the script (3.0) does not match the currently running version of Windows PowerShell." };

If(-NOT (Test-Path $env:SystemDrive\'azagent')){mkdir $env:SystemDrive\'azagent'};

 cd $env:SystemDrive\'azagent';

 for($i=1; $i -lt 100; $i++){
	 $destFolder="A"+$i.ToString();

if(-NOT (Test-Path ($destFolder))){mkdir $destFolder;

cd $destFolder;

break;

}};

 $agentZip="$PWD\agent.zip";

$DefaultProxy=[System.Net.WebRequest]::DefaultWebProxy;

$securityProtocol=@();

$securityProtocol+=[Net.ServicePointManager]::SecurityProtocol;

$securityProtocol+=[Net.SecurityProtocolType]::Tls12;

[Net.ServicePointManager]::SecurityProtocol=$securityProtocol;

$WebClient=New-Object Net.WebClient;

 $Uri='https://vstsagentpackage.azureedge.net/agent/3.236.1/vsts-agent-win-x64-3.236.1.zip';

if($DefaultProxy -and (-not $DefaultProxy.IsBypassed($Uri))){
	$WebClient.Proxy= New-Object Net.WebProxy($DefaultProxy.GetProxy($Uri).OriginalString, $True);

};

 $WebClient.DownloadFile($Uri, $agentZip);

Add-Type -AssemblyName System.IO.Compression.FileSystem;

[System.IO.Compression.ZipFile]::ExtractToDirectory( $agentZip, "$PWD");

.\config.cmd --unattended --environment --environmentname "SIT2" --agent $env:COMPUTERNAME --runasservice --work '_work' --url 'https://dev.azure.com/microportcrm/' --projectname 'ASW-RMS' --addvirtualmachineresourcetags --virtualmachineresourcetags "$Tag" --auth PAT --token $PAT ;

 Remove-Item $agentZip;

