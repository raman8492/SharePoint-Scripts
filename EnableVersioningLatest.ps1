#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
   
#Variables for Processing
$CSVData = Import-CSV -path "C:\Users\gsubbaraman\Documents\InputData.csv"

$UserName=""
$Password =""
  
#Setup Credentials to connect
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))
#$Context.Credentials = $spCredentials 
#$Context.ExecuteQuery()
 
Try {
    #Function to Get all lists from the web
    Function Get-SPOList($Web)
    {
        $Context.Load($Web)
        $Context.ExecuteQuery()
        #Get All Lists from the web
        $Lists = $Web.Lists
        $Context.Load($Lists)
        $Context.ExecuteQuery()
 
        #Get all lists from the web  
        ForEach($List in $Lists)
        {
            
            if($List.BaseTemplate -ne 102)
            {
            #Get the List Name
                Write-host $Web.Url " , "$List.Title 
                $List.EnableVersioning = $true
            
                $List.Update()
                $Context.ExecuteQuery()
            }

        }
    }
 
    #Function to get all webs from given URL
    Function Get-SPOWeb($WebURL)
    {
        #Set up the context
        $Context = New-Object Microsoft.SharePoint.Client.ClientContext($WebURL)
        $Context.Credentials = $Credentials
        $Context.executeQuery()
        $Web = $context.Web
        $Context.Load($web)
        #Get all immediate subsites of the site
        $Context.Load($web.Webs) 
        $Context.executeQuery()
  
        #Call the function to Get Lists of the web
        Write-host "Processing Web :"$Web.URL
        Get-SPOList $Web
  
        #Iterate through each subsite in the current web
        foreach ($Subweb in $web.Webs)
        {
            #Call the function recursively to process all subsites underneaththe current web
            Get-SPOWeb($SubWeb.URL)
        }
    }
 
    #Call the function to get all sites
foreach ($Row in $CSVData) 
{
$SiteUrl = $Row.SiteCollection
Get-SPOWeb $SiteUrl
}
    
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}


#Read more: http://www.sharepointdiary.com/2015/08/sharepoint-online-get-all-lists-using-powershell.html#ixzz5NcSOO1uJ