Class Testify.UI.Dashboard Extends %CSP.Page
{

ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	Do ##class(Testify.Analytics.UnitTestResults).LoadData()
	Set sc=##class(%DeepSee.Utils).%BuildCube("Testify.Analytics.UTResults",,0)
	 Set %response.ServerSideRedirect =
        "/csp/"_$Namespace_"/_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD=Testify/UnitTestResultsDashboard.dashboard"

	Quit $$$OK
}

ClassMethod OnPage() As %Status
{

	Quit $$$OK
}

}
