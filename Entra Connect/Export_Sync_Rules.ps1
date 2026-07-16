$ExportPath = "C:\Temp\"
New-Item -Path $ExportPath -ItemType Directory -Force

$RuleScopeReport = foreach ($Rule in Get-ADSyncRule | Sort-Object Direction, Precedence) {

    if ($null -ne $Rule.ScopeFilter -and $null -ne $Rule.ScopeFilter.ScopeConditionGroups) {

        $GroupIndex = 0

        foreach ($Group in $Rule.ScopeFilter.ScopeConditionGroups) {
            $GroupIndex++

            $ConditionIndex = 0

            foreach ($Condition in $Group.ScopeConditions) {
                $ConditionIndex++

                [PSCustomObject]@{
                    RuleName          = $Rule.Name
                    RuleIdentifier    = $Rule.Identifier
                    Direction         = $Rule.Direction
                    Precedence        = $Rule.Precedence
                    Disabled          = $Rule.Disabled
                    Connector         = $Rule.Connector
                    SourceObjectType  = $Rule.SourceObjectType
                    TargetObjectType  = $Rule.TargetObjectType
                    ScopeGroup        = $GroupIndex
                    ConditionNumber   = $ConditionIndex
                    Attribute         = $Condition.Attribute
                    Operator          = $Condition.ComparisonOperator
                    Value             = $Condition.ComparisonValue
                }
            }
        }
    }
}

$RuleScopeReport |
Export-Csv "$ExportPath\EntraConnect_SyncRules_ScopeFilters.csv" -NoTypeInformation -Encoding UTF8