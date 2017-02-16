[CmdLetBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$ModulePath
)


$modCont = Get-Content -Path $ModulePath -ErrorAction Stop
$errs = $null
$funcNames=@()

$funcs = ([System.Management.Automation.PSParser]::Tokenize($modCont, [ref]$errs) | ? {$_.Content -eq "function"}).StartLine

if ($funcs.count -gt 0 -and $errs.count -eq 0) {

    foreach ($f in $funcs) {
        $name = $null
        $line = ($f-1)
        $end = $null
        if ($modCont[$line].IndexOf("{") -gt 0) {$end = ($modCont[$line].IndexOf("{"))-9}
        elseif ($modCont[$line].IndexOf("(") -gt 0) {$end = ($modCont[$line].IndexOf("("))-9}
        else {$end = $modCont[$line].Length-9}
        $funcNames += $modCont[$line].Substring(9,$end)
    }

    return $funcNames

}
else {return $false}
