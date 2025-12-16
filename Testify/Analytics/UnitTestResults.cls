Class Testify.Analytics.UnitTestResults Extends %Persistent
{

Parameter DEFAULTGLOBAL = "^Testify.Analytics.UTResult";

Property UTDate As %Date;

Property TotalDuration As %Decimal(SCALE = 2);

Property Namespace As %String;

Property TotalUTCount As %Integer;

Index UTDateIdx On UTDate [ IdKey, Unique ];

ClassMethod LoadInitialData()
{
	&SQL(
	INSERT INTO Testify_Analytics.UnitTestResults
	    (UTDate, TotalDuration, Namespace, TotalUTCount)
	SELECT
	    DATE(DateTime) AS UTDate,
	    SUM(Duration) AS TotalDuration,
	    Namespace,
	    COUNT(*) AS TotalUTCount
	FROM %UnitTest_Result.TestInstance
	GROUP BY DATE(DateTime), Namespace
	)
    Do ..SetInitialized()
}

ClassMethod LoadData()
{
    If '..GetInitialized() {
        Do ..LoadInitialData()
        Quit
    }
	&SQL(
	INSERT OR UPDATE INTO Testify_Analytics.UnitTestResults
	    (UTDate, TotalDuration, Namespace, TotalUTCount)
	SELECT
	   DATE(DateTime) AS UTDate,
	    SUM(Duration) AS TotalDuration,
	    Namespace,
	    COUNT(*) AS TotalUTCount
	FROM %UnitTest_Result.TestInstance
	WHERE DATE(DateTime) = CURRENT_DATE
	)
}

ClassMethod SetInitialized()
{
    Set ^qcpr.ut.Analytics.Cube("Testify.Analytics.UTResults","init")=$Horolog
}

ClassMethod GetInitialized() [ CodeMode = expression ]
{
$Data(^qcpr.ut.Analytics.Cube("Testify.Analytics.UTResults","init"))
}

ClassMethod ClearEntireData()
{
    &SQL(DELETE FROM Testify_Analytics.UnitTestResults)
    Kill ^Testify.Analytics.Cube("Testify.Analytics.UTResults","init")
}

Storage Default
{
<Data name="UnitTestResultsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>UTDate</Value>
</Value>
<Value name="3">
<Value>TotalDuration</Value>
</Value>
<Value name="4">
<Value>Namespace</Value>
</Value>
<Value name="5">
<Value>TotalUTCount</Value>
</Value>
</Data>
<DataLocation>^Testify.Analytics.UTResultD</DataLocation>
<DefaultData>UnitTestResultsDefaultData</DefaultData>
<IdLocation>^Testify.Analytics.UTResultD</IdLocation>
<IndexLocation>^Testify.Analytics.UTResultI</IndexLocation>
<StreamLocation>^Testify.Analytics.UTResultS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
