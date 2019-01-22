$admin = "<your account>"
$pass = ConvertTo-SecureString "<password>" -AsPlainText -Force

$OutputFile = "C:\Temp\AllSitePermissions.csv"
Set-Content $OutputFile "Site,HasUniquePerm?,Group Name,Group Owner,Login Name,Roles"

Function Get-SPOAllSitePermissions ($url)
{
    $ctx = New-Object Microsoft.SharePoint.Client.ClientContext($url)
    $ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($admin, $pass)
    $web = $ctx.Web    
    Load-CSOMProperties -Object $web -PropertyNames @("HasUniqueRoleAssignments", "Url", "Title")
    $ctx.Load($ctx.Web.Webs)    
    $ctx.Load($ctx.Web.RoleAssignments)    
    $ctx.ExecuteQuery()
    Write-Host $web.Url
    $webUrl = $web.Url    
    $record = "`"$webUrl`",$($web.HasUniqueRoleAssignments),"     
    if($web.HasUniqueRoleAssignments -eq $true) {
        $firstIteration = $true #helps when to append commas
        foreach($roleAssignment in $ctx.Web.RoleAssignments) {
            Load-CSOMProperties -Object $roleAssignment -PropertyNames @("Member","RoleDefinitionBindings")
            $ctx.ExecuteQuery()
            $roles = ($roleAssignment.RoleDefinitionBindings | Select -ExpandProperty Name) -join ", ";
            $loginName = if($roleAssignment.Member.PrincipalType -eq "User") { $($roleAssignment.Member.LoginName) } else { "" }
            $record += if($firstIteration) { "" } else { ",," }
            $record += "`"$($roleAssignment.Member.Title)`",`"$($roleAssignment.Member.OwnerTitle)`","
            $record += "`"$loginName`",`"$roles`""             
            Add-Content $OutputFile $record
            $firstIteration = $false
            $record = ""
        }       
    }
    else {
        Add-Content $OutputFile $record #you can refer the permissions from its parent web.
    }
    if($web.Webs.Count -eq 0)
    {
   
    }
    else {
        foreach ($web in $web.Webs) {
            Get-SPOAllSitePermissions -Url $web.Url
        }
    }
}

# Paths to SDK. Please verify location on your computer.
# On farm it would be available at c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\
Add-Type -Path "Microsoft.SharePoint.Client.dll" 
Add-Type -Path "Microsoft.SharePoint.Client.Runtime.dll"

.\Load-CSOMProperties.ps1

Get-SPOAllSitePermissions "<your site collection url here>"