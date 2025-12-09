Class Testify.Report.Download Extends %CSP.Page
{


ClassMethod OnPage() As %Status
{
	If $IsObject($Get(%stream)) {
		Do %stream.OutputToDevice()
	}
	Return $$$OK
}

ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	#dim %response As %CSP.Response
    #dim %request As %CSP.Request

	If $Data(%request.Data("utid",1)) {
		Set id = %request.Data("utid",1)
		Set htmlstream = ##class(Testify.Report.Html).DownloadReport(id,.fileName)
        If '$IsObject(htmlstream) Quit $$$OK
        Set %response.ContentType = "application/html"
		Set %stream = ##class(%FileBinaryStream).%New()
		Do %stream.CopyFrom(htmlstream)
		Do %response.SetHeader("Content-Disposition", "attachment; filename="""_fileName_"""")

	}
	Quit $$$OK
}

}
