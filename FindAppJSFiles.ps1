Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

Function ExportResults($FileURL)
{

                    Write-Host $FileURL
                    $ExportItem = New-Object PSObject
                    $ExportItem | Add-Member -MemberType NoteProperty -name "SiteURL" -value $Web.Url
                    $ExportItem | Add-Member -MemberType NoteProperty -name "FileURL" -value $docURL
                    $ListItemCollection += $ExportItem
                    Write-Host $ListItemCollection
                    $ListItemCollection | Export-CSV $OutPutFile -NoTypeInformation -Append
}




Function GetFiles($Folder)
{ 
   Write-Host "+"$Folder.Name

    foreach($file in $Folder.Files)
	{	
    Write-Host $file.Name.ToLower()     
        if($file.Name -eq "app.js" )
        { 
	        Write-Host "`t" $file.Name
            #Write-Host $file.Url         
            $docURL = $Web.Url+"/"+$file.Url
            ExportResults($docURL)
            #Write-Host $docURL
        }

	}

           

	 #Loop through all subfolders and call the function recursively
     foreach ($SubFolder in $Folder.SubFolders)
        {
		    if($SubFolder.Name -ne "Forms")
		    {  
			    Write-Host "`t" -NoNewline
				GetFiles($Subfolder)
				 
			}
		}

 }
#C:\Users\gsubbaraman\Documents\InputData.csv
#Get the Site collection 
#Read the CSV file
$CSVData = Import-CSV -path "C:\Users\Documents\InputData.csv"
$OutPutFile = "C:\Users\Documents\Output.csv"
$ListItemCollection = @()
foreach ($Row in $CSVData) 
{

Write-Host $Row.SiteCollection

$Site= Get-SPSite $Row.SiteCollection 

      #Loop throuh all Sub Sites
       foreach($Web in $Site.AllWebs)
       {
	    
	    Write-Host "Site Name: '$($web.Title)' at $($web.URL)"
		foreach($list in $Web.Lists)
		{
		   #Filter Doc Libs, Eliminate Hidden ones
			if(($List.BaseType -eq "DocumentLibrary") -and ($List.Hidden -eq $false) )
               { 
                Write-Host $list.Title
                if($list.Title -eq "Site Assets")
                {
			        GetFiles($List.RootFolder)

                }
			   }
		}

	   }
}





