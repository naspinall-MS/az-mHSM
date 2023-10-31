#Set date
$date = Get-Date -Format MMddyyyy

#Variables
$mHSMName = "mhsm-$date"
$LAWName = "LAW-$date"
$location = 'westus3'
$subscription = 'subscription1'
$ResourceGroupName = 'mHSM-Test'
$certPath = 'C:\Users\username'
$diagnosticSettingName = 'MHSM-Test-Diag-LAW'
$actionGroupName = 'MonitoringAlerts'
$actionGroupShortName = 'Alerts'
$actionGroupReceiverName = 'user1'
$actionGroupEmail = 'user@example.com'
$alertQuery = "AzureDiagnostics | where OperationName in ('RoleAssignmentCreate','KeyCreate','KeyRecover','KeyRestore','KeyDelete','KeyGet')"
$queryRuleName = 'mHSM-rule-test'

#Set context
$subscriptionId = (Set-AzContext -SubscriptionName $subscription).Subscription.Id

#Initial setup
$rg = New-AzResourceGroup -Name $ResourceGroupName -Location $location
$user = Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id
$hsm = New-AzKeyVaultManagedHsm -Name $mHSMName -ResourceGroupName $rg.ResourceGroupName -Location $location -Administrator $user.Id -SoftDeleteRetentionInDays "7"

#Download security domain
Export-AzKeyVaultSecurityDomain -Name $hsm.Name -Certificates "$certPath\cert_0.cer", "$certPath\cert_1.cer", "$certPath\cert_2.cer" -OutputPath "MHSMsd.ps.json" -Quorum 2

#Create LAW and diagnostics settings
$LAW = New-AzOperationalInsightsWorkspace -Location $location -Name $LAWName -ResourceGroupName $rg.ResourceGroupName -Sku pergb2018
$log = New-AzDiagnosticSettingLogSettingsObject -Category AuditEvent -Enabled $true -RetentionPolicyDay 0 -RetentionPolicyEnabled $false
$diag = New-AzDiagnosticSetting -Name $diagnosticSettingName -ResourceId $hsm.ResourceId -Log $log -WorkspaceId $LAW.ResourceId
$diag | select *

#Create action group
$email = New-AzActionGroupReceiver -Name $actionGroupReceiverName -EmailReceiver -EmailAddress $actionGroupEmail
$actionGroup = Set-AzActionGroup -Name $actionGroupName -ResourceGroupName $rg.ResourceGroupName -ShortName $actionGroupShortName -Receiver $email

#Set up alerts
$condition = New-AzScheduledQueryRuleConditionObject -Query $alertQuery -TimeAggregation "Count" -Operator "GreaterThan" -Threshold "0" -FailingPeriodNumberOfEvaluationPeriod 1 -FailingPeriodMinFailingPeriodsToAlert 1 -ResourceIdColumn "_ResourceId"
New-AzScheduledQueryRule -Name $queryRuleName -ResourceGroupName $rg.ResourceGroupName -Location $location -DisplayName mHSM-rule -Scope "/subscriptions/$subscriptionId/resourceGroups/$($rg.ResourceGroupName)/providers/Microsoft.KeyVault/managedHSMs/$($hsm.Name)" `
-Severity 2 -WindowSize ([System.TimeSpan]::New(0,5,0)) -EvaluationFrequency ([System.TimeSpan]::New(0,1,0)) -CriterionAllOf $condition -ActionGroupResourceId $actionGroup.Id -AutoMitigate