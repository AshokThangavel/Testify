Class Testify.Format.Serializer Extends %RegisteredObject
{
Property FormatterData As %Stream.TmpCharacter;

Property IsVerbose As %Boolean [ InitialExpression = 0 ];

Property UnitTestId As %Integer;

Property ResultType As %String;

Property ResultSet As %SQL.StatementResult;

Parameter UTGbl As STRING = "^UnitTest.Result";

ClassMethod GenerateJSON(pUnitTestId As %Integer = 0, pResultType As %String = "", pIsVerbose As %Integer = 0) As %DynamicObject
{
	If 'pUnitTestId||('$Data(@..#UTGbl(pUnitTestId))) {
		Return $$$ERROR($$$GeneralError,"Unit test id is invalid")
	}
	Set obj = ..%New(pUnitTestId, pIsVerbose, pResultType)
	Do obj.SetResultSetObj()
	If obj.ResultSet.%SQLCODE {
		Return $$$ERROR($$$GeneralError,obj.ResultSet.%Message)
	}
	Return obj.JSON()
}

Method SetResultSetObj()
{
	If ..ResultType'=""{
		Set ..ResultSet = ..UTResultsFunc(..UnitTestId, ..ResultType)
	}
	Else {
		Set ..ResultSet = ..AllCasesFunc(..UnitTestId)
	}
}

Method JSON() As %DynamicObject
{
	Set tResult= ..ResultSet
    Set unitTest = {}
    Set unitTest.results = []
    Set (previousID,currentSuite,currentTestcase,suiteObj,testcaseObj) = ""

    While tResult.%Next() {
        If previousID = "" {
            Set unitTest.id = ..UnitTestId
            Set unitTest.namespace = tResult.namespace
            Set unitTest.duration = tResult.duration
            Set unitTest.testDateTime = tResult.testDateTime
        }
        Set previousID = ..UnitTestId
        If tResult.suiteName '= currentSuite {
            Set currentSuite = tResult.suiteName
            Set suiteObj = {
                "suiteName": (currentSuite),
                "testcases": []
            }
            Do unitTest.results.%Push(suiteObj)
            Set currentTestcase = ""
        }
        If tResult.testcaseName '= currentTestcase {
            Set currentTestcase = tResult.testcaseName
            Set testcaseObj = {
                "testcaseName": (currentTestcase),
                "methods": []
            }
            Do suiteObj.testcases.%Push(testcaseObj)
        }
        Set methodObj = {
            "methodName": (tResult.methodName),
            "testMethod": (tResult.testMethod),
            "assertAction": (tResult.assertAction),
            "assertCounter": (tResult.assertCounter),
            "assertDescription": (tResult.assertDescription),
            "assertLocation": (tResult.assertLocation)
        }
        Do testcaseObj.methods.%Push(methodObj)
    }
	Return unitTest
}

Query UTResults(pInstance As %Integer, pStatus) As %SQLQuery(ROWSPEC = "TotalCounts:%Integer,namespace:%String,duration:%String,testDateTime:%String,suiteName:%String,testcaseName:%String,methodName:%String,testMethod:%String,assertAction:%String,assertCounter:%Integer,assertDescription:%String,assertLocation:%String", SELECTMODE = "DISPLAY")
{
SELECT
count(*) as TotalCounts,
tinstance.Namespace AS namespace,
tinstance.Duration AS duration,
tinstance.DateTime AS testDateTime,
tsuite.Name AS suiteName,
tcase.Name AS testcaseName,
tmethod.Name AS methodName,
tassert.TestMethod AS testMethod,
tassert.Action AS assertAction,
tassert.Counter AS assertCounter,
tassert.Description AS assertDescription,
tassert.Location AS assertLocation
FROM
%UnitTest_Result.TestInstance tinstance
JOIN %UnitTest_Result.TestSuite tsuite ON tsuite.TestInstance=tinstance.ID
JOIN %UnitTest_Result.TestCase tcase  ON tcase.TestSuite=tsuite.ID
JOIN %UnitTest_Result.TestMethod tmethod ON tmethod.TestCase=tcase.ID
JOIN %UnitTest_Result.TestAssert tassert ON tassert.TestMethod=tmethod.ID
WHERE tinstance.ID=:pInstance AND tassert.Status=:pStatus
}

Query AllCases(pInstance As %Integer) As %SQLQuery(ROWSPEC = "TotalCounts:%String,namespace:%String,duration:%String,testDateTime:%String,suiteName:%String,testcaseName:%String,methodName:%String,testMethod:%String,assertAction:%String,assertCounter:%Integer,assertDescription:%String,assertLocation:%String", SELECTMODE = "DISPLAY")
{
SELECT
count(*) as TotalCounts,
tinstance.Namespace AS namespace,
tinstance.Duration AS duration,
tinstance.DateTime AS testDateTime,
tsuite.Name AS suiteName,
tcase.Name AS testcaseName,
tmethod.Name AS methodName,
tassert.TestMethod AS testMethod,
tassert.Action AS assertAction,
tassert.Counter AS assertCounter,
tassert.Description AS assertDescription,
tassert.Location AS assertLocation
FROM
%UnitTest_Result.TestInstance tinstance
JOIN %UnitTest_Result.TestSuite tsuite ON tsuite.TestInstance=tinstance.ID
JOIN %UnitTest_Result.TestCase tcase  ON tcase.TestSuite=tsuite.ID
JOIN %UnitTest_Result.TestMethod tmethod ON tmethod.TestCase=tcase.ID
JOIN %UnitTest_Result.TestAssert tassert ON tassert.TestMethod=tmethod.ID
WHERE tinstance.ID=:pInstance
}

Method %OnNew(pUnitTestId As %Integer = 0, pIsVerbose As %Integer = 0, pResultType As %String) As %Status
{
	Set ..UnitTestId = pUnitTestId
	Set ..IsVerbose = pIsVerbose
	Set ..ResultType= pResultType
	Return $$$OK
}
}