function ShowSpec {
	function Add-ToStrArray {
		param (
			[Parameter(Mandatory = $true)]
			[string]$text
		)
		if (-not $global:strArray){
			$global:strArray = New-Object System.Collections.ArrayList
		}
		$global:strArray.Add($text) | Out-Null
	}

	function gb($bytes) {
		"$([Math]::Ceiling($bytes / 1GB))GB"
	}

	function mb($bytes) {
		"$([Math]::Ceiling($bytes / 1MB))MB"
	}

	function sysTypeEXstr([int]$sysTypeExNum) {
		@{
			0 = "Unspecified";
			1 = "Desktop";
			2 = "Mobile";
			3 = "Workstation";
			4 = "Enterprise Server";
			5 = "SOHO Server";
			6 = "Appliance PC";
			7 = "Performance Server";
			8 = "SLATE";
			9 = "Maximum";
		}[$sysTypeExNum]
	}

	function cpuArchStr([int]$cpuArchNum) {
		@{
			0 = "x86";
			1 = "MIPS";
			2 = "Alpha";
			3 = "PowerPC";
			5 = "ARM";
			6 = "ia64";
			9 = "x64";
			12 = "ARM64";
		}[$cpuArchNum]
	}

	$strArray = New-Object System.Collections.ArrayList
	Add-ToStrArray "``````"
	$comp = Get-CimInstance CIM_ComputerSystem
	$bios = Get-CimInstance CIM_BIOSElement
	Add-ToStrArray "* Model"
	Add-ToStrArray "  * $($comp.Model.trim())"
	Add-ToStrArray "  * Type : $(sysTypeEXstr $comp.PCSystemTypeEX)"
	Add-ToStrArray "  * BIOS : $($bios.Name.trim())"

	$os = Get-CimInstance CIM_OperatingSystem
	Add-ToStrArray "* OS"
	Add-ToStrArray "  * $($os.Caption.trim())"
	Add-ToStrArray "  * Version : $($os.Version.trim())"

	$cpu = Get-CimInstance CIM_Processor
	Add-ToStrArray "* CPU"
	Add-ToStrArray "  * $($cpu.Name.trim())"
	Add-ToStrArray "  * BaseClock : $($cpu.MaxClockSpeed / 1000) GHz"
	Add-ToStrArray "  * Cores : $($cpu.NumberOfCores) ($($cpu.ThreadCount) Threads)"

	Add-ToStrArray "* Graphics"
	Get-CimInstance CIM_VideoController | ForEach-Object {
		Add-ToStrArray "  * $($_.Name.trim())"
		Add-ToStrArray "    * RAM : $(gb $_.AdapterRAM)"
	}

	$mems = Get-CimInstance CIM_PhysicalMemory
	Add-ToStrArray "* Memories"

	Add-ToStrArray "  * Total : $(gb $comp.TotalPhysicalMemory) (count: $($mems.count))"
	$mems | ForEach-Object {
		Add-ToStrArray "    * $($_.PartNumber.trim())"
		Add-ToStrArray "      * Manufacturer : $($_.Manufacturer.trim())"
		Add-ToStrArray "      * Size : $(gb $_.Capacity)"
		Add-ToStrArray "      * Speed : $($_.Speed) MHz (data width: $($_.DataWidth) bits)"
	}

	Add-ToStrArray "* Storages"
	Get-CimInstance CIM_DiskDrive | ForEach-Object {
		Add-ToStrArray "  * $($_.Model.trim())"
		Add-ToStrArray "    * Size : $(gb $_.Size)"
	}
	Add-ToStrArray "``````" 
	Write-Output $global:strArray
	$global:strArray | Set-Clipboard
	Write-Output "クリップボードにコピーしました。`r`n「Ctrl」+「V」キーで貼り付けてください。"
}
