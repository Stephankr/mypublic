$ExportPath = "C:\Temp\"
New-Item -Path $ExportPath -ItemType Directory -Force



New-Item -Path $ExportPath -ItemType Directory -Force | Out-Null

function Get-FirstPropertyValue {
    param(
        [Parameter(Mandatory = $true)]
        $Object,

        [Parameter(Mandatory = $true)]
        [string[]]$PropertyNames
    )

    foreach ($PropertyName in $PropertyNames) {
        $Property = $Object.PSObject.Properties |
        Where-Object { $_.Name -eq $PropertyName } |
        Select-Object -First 1

        if ($null -ne $Property) {
            return $Property.Value
        }
    }

    return $null
}

$RuleScopeReport = foreach ($Rule in Get-ADSyncRule | Sort-Object Direction, Precedence) {

    $ScopeGroupNumber = 0

    foreach ($ScopeGroup in @($Rule.ScopeFilter)) {

        $ScopeGroupNumber++

        $ConditionNumber = 0

        foreach ($Condition in @($ScopeGroup.ScopeConditions)) {

            $ConditionNumber++

            $RawProperties = (
                $Condition.PSObject.Properties |
                ForEach-Object {
                    "$($_.Name)=$($_.Value)"
                }
            ) -join " | "

            [PSCustomObject]@{
                RuleName               = $Rule.Name
                RuleIdentifier         = $Rule.Identifier
                Direction              = $Rule.Direction
                Precedence             = $Rule.Precedence
                Disabled               = $Rule.Disabled
                Connector              = $Rule.Connector
                SourceObjectType       = $Rule.SourceObjectType
                TargetObjectType       = $Rule.TargetObjectType

                ScopeGroup             = $ScopeGroupNumber
                ConditionNumber        = $ConditionNumber

                Attribute              = Get-FirstPropertyValue -Object $Condition -PropertyNames @(
                    "Attribute",
                    "AttributeName",
                    "SourceAttribute",
                    "CSAttribute",
                    "MVAttribute"
                )

                Operator               = Get-FirstPropertyValue -Object $Condition -PropertyNames @(
                    "ComparisonOperator",
                    "Operator",
                    "ComparisonType"
                )

                Value                  = Get-FirstPropertyValue -Object $Condition -PropertyNames @(
                    "ComparisonValue",
                    "Value",
                    "Values"
                )

                ConditionRawProperties = $RawProperties
            }
        }
    }
}

$RuleScopeReport |
Export-Csv "$ExportPath\EntraConnect_SyncRules_ScopeFilters_WithRaw.csv" -NoTypeInformation -Encoding UTF8