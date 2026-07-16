$ExportPath = "C:\Temp\"
New-Item -Path $ExportPath -ItemType Directory -Force


$RuleScopeReport = foreach ($Rule in Get-ADSyncRule | Sort-Object Direction, Precedence) {

    $GroupNumber = 0

    foreach ($ScopeGroup in @($Rule.ScopeFilter)) {

        $GroupNumber++

        $ConditionNumber = 0

        foreach ($Condition in @($ScopeGroup.ScopeConditions)) {

            $ConditionNumber++

            [PSCustomObject]@{
                RuleName         = $Rule.Name
                RuleIdentifier   = $Rule.Identifier
                Direction        = $Rule.Direction
                Precedence       = $Rule.Precedence
                Disabled         = $Rule.Disabled
                Connector        = $Rule.Connector
                SourceObjectType = $Rule.SourceObjectType
                TargetObjectType = $Rule.TargetObjectType

                ScopeGroup       = $GroupNumber
                ConditionNumber  = $ConditionNumber

                Attribute        = $Condition.Attribute
                Operator         = $Condition.ComparisonOperator
                Value            = $Condition.ComparisonValue
            }
        }
    }
}

$RuleScopeReport |
Export-Csv "$ExportPath\EntraConnect_SyncRules_ScopeFilters.csv" -NoTypeInformation -Encoding UTF8

$RuleScopeReport |
Format-Table RuleName, Direction, Precedence, ScopeGroup, Attribute, Operator, Value -AutoSize