function Generate-RDCManFile
{

    param(
    
        [Parameter(Mandatory=$true )]
        [string]$SavePath
    
    )
    
    $AllVMs=@()
    $sub = (get-azurermcontext).Subscription.SubscriptionName
    $rgs = Get-AzureRMResourceGroup

    foreach ($rg in $rgs.ResourceGroupName) {
        
        $vms = Get-AzureRmVM -ResourceGroupName $rg
        Write-host "Gathering data from $($rg)."

        if ($vms.Count -gt 0) {

            foreach ($_vm in $vms) {

                $Name = $_vm.Name
                $NICID = $_vm.NetworkProfile | Select -ExpandProperty NetworkInterfaces | select -First 1 | select -ExpandProperty Id
                $IPAddress = ((Get-AzureRmNetworkInterface -ResourceGroupName $rg -Name $NICID.Split("/")[8] | select -expandproperty IpConfigurations | ? {$_.Name -eq "ipconfig1"}).PrivateIpAddress)

                $_properties=@{
                                'ResourceGroupName'=$rg;
                                'VMName'=$Name;
                                'IPAddress'=$IPAddress
                              }

                $_obj = New-Object -TypeName PSObject -Property $_properties
                $AllVMs += $_obj 
        
            }
        }
    }

    $groups = $AllVMs | select -ExpandProperty ResourceGroupName | Get-Unique

    If ($SavePath[$SavePath.Length-1] -eq "\") {}
    Else {$SavePath = "$($SavePath)\"}
    $Path = "$($SavePath)$($sub).rdg"

    # get an XMLTextWriter to create the XML
    $XmlWriter = New-Object System.XMl.XmlTextWriter($Path,([System.Text.Encoding]::UTF8))
 
    # choose a pretty formatting:
    $xmlWriter.Formatting = 'Indented'
    $xmlWriter.Indentation = 1
    $XmlWriter.IndentChar = "`t"
 
    # write the header
    $xmlWriter.WriteStartDocument()
 
    # create root element "machines" and add some attributes to it
    $xmlWriter.WriteStartElement('RDCMan')
    $XmlWriter.WriteAttributeString('programVersion', '2.7')
    $XmlWriter.WriteAttributeString('schemaVersion', '3')

        $xmlWriter.WriteStartElement('file')
        
            $xmlWriter.WriteStartElement('credentialsProfiles')
            $xmlWriter.WriteEndElement()

            $xmlWriter.WriteStartElement('properties')
            
                $xmlWriter.WriteElementString('expanded','True')
                $xmlWriter.WriteElementString('name',$sub)

            $xmlWriter.WriteEndElement()

            $xmlWriter.WriteStartElement('logonCredentials')
            $XmlWriter.WriteAttributeString('inherit', 'None')
            $xmlWriter.WriteEndElement()

            $xmlWriter.WriteStartElement('remoteDesktop')
            $XmlWriter.WriteAttributeString('inherit', 'None')

                $xmlWriter.WriteElementString('sameSizeAsClientArea','True')
                $xmlWriter.WriteElementString('fullscreen','False')
                $xmlWriter.WriteElementString('colorDepth','24')

            $xmlWriter.WriteEndElement()

            $xmlWriter.WriteStartElement('displaySettings')
            $XmlWriter.WriteAttributeString('inherit', 'None')

                $xmlWriter.WriteElementString('liveThumbnailUpdates','True')
                $xmlWriter.WriteElementString('allowThumbnailSessionInteraction','False')
                $xmlWriter.WriteElementString('showDisconnectedThumbnails','True')
                $xmlWriter.WriteElementString('thumbnailScale','1')
                $xmlWriter.WriteElementString('smartSizeDockedWindows','False')
                $xmlWriter.WriteElementString('smartSizeUndockedWindows','False')

            $xmlWriter.WriteEndElement()

        foreach ($_g in $groups) {

            $xmlWriter.WriteStartElement('group')
            
                $xmlWriter.WriteStartElement('properties')
            
                    $xmlWriter.WriteElementString('expanded','True')
                    $xmlWriter.WriteElementString('name',$_g)

                $xmlWriter.WriteEndElement()

                foreach ($_s in ($AllVMs | ? {$_.ResourceGroupName -eq $_g})) {

                    $xmlWriter.WriteStartElement('server')
            
                        $xmlWriter.WriteElementString('name',$_s.IPAddress)
                        $xmlWriter.WriteElementString('displayName',$_s.VMName)

                    $xmlWriter.WriteEndElement()

                }

            $xmlWriter.WriteEndElement()

        }

        $xmlWriter.WriteEndElement()

        $xmlWriter.WriteStartElement('connected')
        $xmlWriter.WriteEndElement()

        $xmlWriter.WriteStartElement('favorites')
        $xmlWriter.WriteEndElement()

        $xmlWriter.WriteStartElement('recentlyUsed')
        $xmlWriter.WriteEndElement()

    $xmlWriter.WriteEndElement()

    $xmlWriter.WriteEndDocument()
    $xmlWriter.Flush()
    $xmlWriter.Close()

  return "$($path)"

}
