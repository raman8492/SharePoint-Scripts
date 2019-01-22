if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null)
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

Function Get-BreakInheritance($SPWeb)
{
    Write-Host "Inheritance Break for "$SPWeb.Url
        If ( ($SPWeb.HasUniqueRoleAssignments -and $SPWeb.HasUniqueRoleDefinitions) -eq $false )
        {
        $SPWeb.RoleDefinitions.BreakInheritance($true, $true)
        #$spWeb.BreakRoleInheritance($true,$true)
        $SPWeb.Update()
        
        foreach($spList in $SPWeb.Lists)
        {

            $spList.ResetRoleInheritance()
            $spList.Update()
            
        }
        } 
}
Function Get-UserGroups($SPWeb)
{
    $role = $SPWeb.RoleDefinitions["Read"]
        foreach($SPGroup in $SPWeb.Groups)
        {

            Write-Host $SPGroup.Name
            $ra = $SPGroup.ParentWeb.RoleAssignments.GetAssignmentByPrincipal($SPGroup)
            $rd = $SPGroup.ParentWeb.RoleDefinitions["Read"]
            $rd1 = $SPGroup.ParentWeb.RoleDefinitions

            Write-Host $ra.RoleDefinitionBindings.Contains($rd)
            if(!$ra.RoleDefinitionBindings.Contains($rd))
            {
                $ra.RoleDefinitionBindings.add($rd)
                foreach($roledef in $rd1)
                {
                    if($roledef.Name -ne "Read")
                    {
                        $ra.RoleDefinitionBindings.Remove($roledef)
                        $ra.Update()
                        $SPGroup.Update()
                    }
                }
            }


         }


}

Function Get-RemoveUserRoleDef($SPWeb)
{
$role = $SPWeb.RoleDefinitions["Read"]
            foreach($User in $SPWeb.Users)
            {
            $roleas = $SPWeb.RoleAssignments.GetAssignmentByPrincipal($User)
            $rd = $SPWeb.RoleDefinitions["Read"]
            $rd1 = $SPWeb.RoleDefinitions

            Write-Host $roleas.RoleDefinitionBindings.Contains($rd)
                if(!$roleas.RoleDefinitionBindings.Contains($rd))
                {
                    $roleas.RoleDefinitionBindings.add($rd)

                    foreach($roledef in $rd1)
                    {
                        if($roledef.Name -ne "Read")
                        {
                        $roleas.RoleDefinitionBindings.Remove($roledef)
                        $roleas.Update()
                        
                        }
                    }
                }
            
            }
}

Function Get-SPOWeb($SPSiteUrl)
{
$spWeb = Get-SPWeb $SPSiteUrl -ErrorAction SilentlyContinue
if($spWeb -ne $null)
{

        Write-Host $SPWeb.Url "HasUniqueRoleAssignments" $SPWeb.HasUniqueRoleAssignments "HasUniqueRoleDefinitions" $SPWeb.HasUniqueRoleDefinitions

        Get-BreakInheritance $spWeb
        Get-UserGroups $spWeb
        Get-RemoveUserRoleDef ($spWeb)
       
        $spWeb.Update()

        foreach($web in $SPWeb.Webs)
        {
            Get-SPOWeb($web.Url)
            
        }
        
        

         

     
        
}


else
{
    Write-Host "Requested Site Could Not be found" -ForegroundColor DarkRed
}

}

#Provide Web URL
$SiteUrl = "https://domain/sites/TestSite"
Get-SPOWeb $SiteUrl

