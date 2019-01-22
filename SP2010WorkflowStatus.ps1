Add-PSSnapin microsoft.sharepoint.powershell -ErrorAction SilentlyContinue

#Change the File Path for Input and Output as needed.
#-------------------------------------------------------------------------
$CSVData = Import-CSV -path "C:\Users\Documents\InputData.csv"
$OutPutFile = "C:\Users\Documents\Output1.csv"
#-------------------------------------------------------------------------

$ListItemCollection = @()
$wfAssociations = @()
foreach ($Row in $CSVData) 
{

Write-Host $Row.SiteCollection

$Site= Get-SPSite $Row.SiteCollection 

  foreach($Web in $Site.AllWebs)
  {
     foreach($list in $Web.Lists)
     {
        foreach ($wf in $list.WorkflowAssociations)
        {
            $wfAssociations += $wf
            
        }
     if ($wfAssociations.count -ge 1)
     {          
		foreach($item in $list.items)
		{
		   foreach($workflow in $item.workflows)
          {
            $wfName = $wf.Name
            $wfStatus = $workflow.InternalState
            $wfListItem = $workflow.ItemName
            write-host "Workflow Title: $wfName Status: $wfStatus ListItem: $wfListItem"
            $ExportItem = New-Object PSObject
                    $ExportItem | Add-Member -MemberType NoteProperty -name "SiteURL" -value $Web.Url
                    $ExportItem | Add-Member -MemberType NoteProperty -name "ListName" -value $list.Title
                    $ExportItem | Add-Member -MemberType NoteProperty -name "ItemID" -value $workflow.ItemId
                    $ExportItem | Add-Member -MemberType NoteProperty -name "WorkflowName" -value $wfName
                    $ExportItem | Add-Member -MemberType NoteProperty -name "WorkflowStatus" -value $wfStatus
                    $ListItemCollection += $ExportItem
                    Write-Host $ListItemCollection
                    $ListItemCollection | Export-CSV $OutPutFile -NoTypeInformation
          }
		}

     }

     } 
  
  }

}  