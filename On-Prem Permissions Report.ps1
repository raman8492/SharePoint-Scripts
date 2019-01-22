Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

Function GetUserAccessReport($WebAppURL, $FileUrl)
{
	Write-Host "Generating permission report..."

	#Get All Site Collections of the WebApp
	$SiteCollections = Get-SPSite -WebApplication $WebAppURL -Limit All

	#Write CSV- TAB Separated File) Header
	"URL`t Title/Name`tPermissionType`tPermissions `tUserEmail `tDisplayName" | out-file $FileUrl

	#Check Web Application Policies
	$WebApp= Get-SPWebApplication $WebAppURL

	foreach ($Policy in $WebApp.Policies) 
  	{
		$PolicyRoles=@()
		foreach($Role in $Policy.PolicyRoleBindings)
		{
			$PolicyRoles+= $Role.Name +";"
		}
		
		"$($AdminWebApp.URL)`tWeb Application`t$($AdminSite.Title)`tWeb Application Policy`t$($PolicyRoles)`t$($Policy.UserName)" | Out-File $FileUrl -Append
	}

	#Loop through all site collections
	foreach($Site in $SiteCollections) 
    {
	  #Check Whether the Search User is a Site Collection Administrator
	  foreach($SiteCollAdmin in $Site.RootWeb.SiteAdministrators)
      	{
			"$($Site.RootWeb.Url)`tSite`t$($Site.RootWeb.Title)`tSite Collection Administrator`tSite Collection Administrator`t$($SiteCollAdmin.Email) `t$($SiteCollAdmin.DisplayName)" | Out-File $FileUrl -Append
		}
  
	   #Loop throuh all Sub Sites
       foreach($Web in $Site.AllWebs) 
       {	
			if($Web.HasUniqueRoleAssignments -eq $True)
			{

				#Get all the users granted permissions to the list
				foreach($WebRoleAssignment in $Web.RoleAssignments ) 
				{ 
					#Is it a User Account?
					if($WebRoleAssignment.Member.userlogin)    
					{
                        
						#Get the Permissions assigned to user
						$WebUserPermissions=@()
						foreach ($RoleDefinition  in $WebRoleAssignment.RoleDefinitionBindings)
						{
                            Write-Host $RoleDefinition.Name
                            if($RoleDefinition.Name -eq "Full Control")
                            {
							    $WebUserPermissions += $RoleDefinition.Name +";"
                            }
						}
						
						#Send the Data to Log file
						"$($Web.Url)`tSite`t$($Web.Title)`tDirect Permission`t$($WebUserPermissions) `t$($WebRoleAssignment.Member.Email) `t$($WebRoleAssignment.Member.DisplayName)" | Out-File $FileUrl -Append
					}
					#Its a SharePoint Group, So search inside the group and check if the user is member of that group
					else  
					{
						foreach($user in $WebRoleAssignment.member.users)
						{
							#Get the Group's Permissions on site
							$WebGroupPermissions=@()
							foreach ($RoleDefinition  in $WebRoleAssignment.RoleDefinitionBindings)
							{
                                Write-Host $RoleDefinition.Name
                                if($RoleDefinition.Name -eq "Full Control")
                                {
								    $WebGroupPermissions += $RoleDefinition.Name +";"
                                }
							}
							
							#Send the Data to Log file
							"$($Web.Url)`tSite`t$($Web.Title)`tMember of $($WebRoleAssignment.Member.Name) Group`t$($WebGroupPermissions)`t$($user.Email) `t$($user.DisplayName)" | Out-File $FileUrl -Append
						}
					}
				}
			}
				
			

		}	
	}
}

#Call the function to Check User Access
GetUserAccessReport "https://domain.org/" "C:\SharePoint_Permission_Report.csv"
Write-Host "Complete"
