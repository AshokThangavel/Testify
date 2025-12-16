/// 
Class Testify.Analytics.UTResults Extends %DeepSee.CubeDefinition [ DependsOn = Testify.Analytics.UnitTestResults, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="Testify.Analytics.UTResults" displayName="Testify.Analytics.UTResults" disabled="false" abstract="false" sourceClass="Testify.Analytics.UnitTestResults" namedFactNums="true" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false" enableSqlRestrict="false">
  <dimension name="UTDate" disabled="false" hasAll="false" allCaption="All UTDate" allDisplayName="UTDate" sourceProperty="UTDate" type="time" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="New_Level1" disabled="false" timeFunction="DayMonthYear" list="false" useDisplayValue="true" sort="desc" useAsFilter="true" hidden="false" factNumber="2">
      </level>
    </hierarchy>
  </dimension>
  <measure name="TotalUTCount" disabled="false" sourceProperty="TotalUTCount" aggregate="SUM" type="number" hidden="false" searchable="false" factNumber="1">
  </measure>
  <measure name="TotalDuration" disabled="false" sourceProperty="TotalDuration" aggregate="SUM" type="number" hidden="false" searchable="false" factNumber="2">
  </measure>
</cube>
}

}
