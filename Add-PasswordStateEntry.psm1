<#
.Synopsis
   Generates entries for password state import CSV files
.DESCRIPTION
   Generates entries for password state import CSV files
.EXAMPLE
   Add-PasswordStateEntry
.EXAMPLE
   Add-PasswordStateEntry -FileSuffix $FileSuffix -SubjectName $Subject -Password $Password -Path $Path

.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   Certificate Management
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Add-PasswordStateEntry {
    [CmdletBinding(SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # FileName Suffix
        #[Parameter(Mandatory=$true)]
        #[string]$FileSuffix,

        #Internal, specifies if certificate is for internal use
        [Parameter(Mandatory=$false)]
        [switch]$Internal,
        
        # Certificate Subject Name
        [Parameter(Mandatory=$true)]
        [string]$SubjectName,

        # Password, securestring
        [Parameter(Mandatory=$true)]
        [securestring]$Password,
        
        # Path to CSV Output
        [Parameter()]
        [string]$Path = ".",
        
        # Date of expiration, optional
        [Parameter()]
        [datetime]$ExpiryDate

    )

    Begin
    {
        #$NetworkCSVPath = Join-Path -Path $Path -ChildPath "NetworkImport-$FileSuffix.csv"
        #$PlatformCSVPath = Join-Path -Path $Path -ChildPath "PlatformImport-$FileSuffix.csv"
        
        if($Internal){$Location = "$SubjectName-int" } else {$Location = "$SubjectName"}

<#        function HashToObject ([Hashtable]$Hash)
        {
            $Object = New-Object PSCustomObject
            foreach($k in $Hash.Keys){
                $object | Add-Member -MemberType NoteProperty -Name $k -Value $Hash[$k]

            }
            return $Object   
        }
        #>
    }
    Process
    {
<#        $Notes = @"
Certificate for $SubjectName
Locations 
G:\IT\Operations\Network\SSL Certificate Info\$Location
X:\CFS-CA\Departments\EIS - 20\Infrastructure\Certificates\$Location
"@
        $Description = "Certificate"
        $Expiration = ""
        if($ExpiryDate -ne $null) { $Expiration= $ExpiryDate.ToShortDateString()} 
        # Reference: https://stackoverflow.com/questions/28352141/convert-a-secure-string-to-plain-text
        $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
        
        # Build the CSV Hashes
        #$NetworkCSV = [ordered]@{Title=$SubjectName;UserName="";Description=$Description;Notes=$Notes;Password=$UnsecurePassword;ExpiryDate=$Expiration}
        #$PlatformCSV = [ordered]@{Title=$SubjectName;UserName="";Description=$Description;Notes=$Notes;URL="";Password=$UnsecurePassword;ExpiryDate=$Expiration}
        $CSV = [ordered]@{Title=$Location;UserName="";Description=$Description;Notes=$Notes;URL="";Password=$UnsecurePassword;ExpiryDate=$Expiration}

        # Output the CSV to File
        HashToObject -Hash $CSV | Select-Object -Property Title,UserName,Description,Notes,Password,ExpiryDate | Export-Csv -NoTypeInformation -Path $NetworkCSVPath -Append
        HashToObject -Hash $CSV | Select-Object -Property Title,UserName,Description,Notes,URL,Password,ExpiryDate | Export-Csv -NoTypeInformation -Path $PlatformCSVPath -Append
        
        if ($pscmdlet.ShouldProcess("Target", "Operation"))
        {
        }#>
		#PowerShell API to PasswordState
		$UserUploading = [Environment]::UserName
		$Notes = "Certficate for $SubjectName - Locations: G:\\IT\\Operations\\Network\\SSL Certificate Info\\$Location and X:\\CFS-CA\\Departments\\EIS - 20\\Infrastructure\\Certificates\\$Location - Entry Created By: $UserUploading"
		$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
		$Description = "Certificate"
		if($ExpiryDate -ne $null) { $Expiration= $ExpiryDate.ToShortDateString()}
		$jsonData = "
			{
				`"PasswordListID`":`"581`",
				`"Title`":`"$SubjectName`",
				`"UserName`":`"N/A`",
				`"password`":`"$UnsecurePassword`",
				`"Description`":`"$Description`",
				`"Notes`":`"$Notes`",
				`"ExpiryDate`":`"$Expiration`",
				`"AccountTypeID`": 103
			}
			"
			$PasswordstateUrl = 'https://pwd.coop.org/api/passwords'
			$result = Invoke-Restmethod -Method Post -Uri $PasswordstateUrl -ContentType "application/json" -Body $jsonData -Header @{ "APIKey" = "b628ac453d3ef97be268df57c4a3935b" }
    }
    End
    {
        
    }

}

