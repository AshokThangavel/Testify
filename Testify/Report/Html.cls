Class Testify.Report.Html Extends %RegisteredObject
{
Property FileName As %String(MAXLEN = 150);

Property AbsoluteFileName As %String(MAXLEN = 5000);

Property UnitTestId As %Integer;

Property HTMLStream As %Stream.TmpCharacter;

Parameter UTResultGbl As STRING = "^UnitTest.Result";

ClassMethod DownloadReport(pUnitTestId As %Integer = "", Output FileName) As %Stream.TmpCharacter
{
    If 'pUnitTestId{
        Return $$$ERROR($$$GeneralError,"unit test id is invalid")
    }
    Set obj = ..%New(pUnitTestId)
    Set FileName = obj.FileName
    Do obj.Generate()
    Return obj.HTMLStream
}

Method Generate() As %Status
{
    Set tUnitTestId = ..UnitTestId
    If '$Data(@..#UTResultGbl(..UnitTestId),utinfo) {
		Do ..HTMLStream.Write("<h1> No test result found for id "_..UnitTestId_"</h1>")
        Goto End
		Quit
	}
    Do ..BuildSystemInfo()
    Set testSuite=""
    For {
        Set testSuite = $Order(@..#UTResultGbl(tUnitTestId,testSuite)) Quit:testSuite=""
        Set testCase=""
        For {
            Set testCase = $Order(@..#UTResultGbl(tUnitTestId,testSuite,testCase)) Quit:testCase=""
            ;
            Set caseId=tUnitTestId_"||"_testSuite
            Set testCase1 = tUnitTestId_"||"_testSuite_"||"_testCase
            ;
            &SQL(Select Status,Duration,Name INTO :status,:Duration,:Name from %UnitTest_Result.TestSuite where TestInstance=:tUnitTestId)
            ;
            Set status = ..Status(status)
            ; print test suite
            ;
            Do ..HTMLStream.WriteLine("    <div class=""summary"">")
            Do ..HTMLStream.WriteLine("      <div class=""summary__data"">")
            Do ..HTMLStream.WriteLine("        <h2>Test Suite</h2>")
            Do ..HTMLStream.WriteLine("        <div class=""additional-summary prefix"">")
            Do ..HTMLStream.WriteLine("        </div>")
            Do ..HTMLStream.WriteLine("        <p class=""run-count""> <b>"_testSuite_"</b> status <span class="""_status_""">"_status_"</span>. tests took "_Duration_" s.</p>")
            ;
            ; print testcase
            &SQL(Select Name,Duration,Status,ErrorAction,ErrorDescription INTO
                            :Name,:Duration,:Status,:ErrorAction,:ErrorDescription
                    from %UnitTest_Result.TestCase where TestSuite=:caseId)
            Set Status =..Status(status)
            ;
            Do ..HTMLStream.WriteLine("        <h2>Test case</h2>")
            Do ..HTMLStream.WriteLine("    <div class=""summary"">")
            Do ..HTMLStream.WriteLine("      <div class=""summary__data"">")
            Do ..HTMLStream.WriteLine("        <div class=""additional-summary prefix"">")
            Do ..HTMLStream.WriteLine("        </div>")
            Do ..HTMLStream.WriteLine("        <p class=""run-count""> <b>"_Name_"</b> status <span class="""_Status_""">"_Status_"</span>. tests took "_Duration_" s.</p>")
            ;
            Do ..HTMLStream.WriteLine("        <p class=""filter"">(Un)check the boxes to filter the results.</p>")
            ; print check box
            &SQL(
                Select   SUM(CASE WHEN Status = 0 THEN 1 ELSE 0 END) AS failed,
                SUM(CASE WHEN Status = 1 THEN 1 ELSE 0 END) AS passed,
                SUM(CASE WHEN Status = 2 THEN 1 ELSE 0 END) AS skipped
                INTO :failed,:passed,:skipped
                from %UnitTest_Result.TestMethod where TestCase=:testCase1
            )
            ;
            Do ..HTMLStream.WriteLine("        <div class=""summary__reload"">")
            Do ..HTMLStream.WriteLine("          <div class=""summary__reload__button hidden"" onclick=""location.reload()"">")
            Do ..HTMLStream.WriteLine("            <div>There are still tests running. <br />Reload this page to get the latest results!</div>")
            Do ..HTMLStream.WriteLine("          </div>")
            Do ..HTMLStream.WriteLine("        </div>")
            Do ..HTMLStream.WriteLine("        <div class=""summary__spacer""></div>")
            Do ..HTMLStream.WriteLine("        <div class=""controls"">")
            Do ..HTMLStream.WriteLine("          <div class=""filters"">")
            Do ..HTMLStream.WriteLine("            <input checked=""true"" class=""filter"" name=""filter_checkbox"" type=""checkbox"" data-test-result=""failed"" />")
            Do ..HTMLStream.WriteLine("            <span class=""failed"">"_failed_" Failed,</span>")
            Do ..HTMLStream.WriteLine("            <input checked=""true"" class=""filter"" name=""filter_checkbox"" type=""checkbox"" data-test-result=""passed"" />")
            Do ..HTMLStream.WriteLine("            <span class=""passed"">"_passed_" Passed,</span>")
            Do ..HTMLStream.WriteLine("            <input checked=""true"" class=""filter"" name=""filter_checkbox"" type=""checkbox"" data-test-result=""skipped"" disabled/>")
            Do ..HTMLStream.WriteLine("            <span class=""skipped"">"_skipped_" Skipped</span>")
            Do ..HTMLStream.WriteLine("          </div>")
            Do ..HTMLStream.WriteLine("          <div class=""collapse"">")
            Do ..HTMLStream.WriteLine("            <button id=""show_all_details"">Show all details</button>&nbsp;/&nbsp;<button id=""hide_all_details"">Hide all details</button>")
            Do ..HTMLStream.WriteLine("          </div>")
            Do ..HTMLStream.WriteLine("        </div>")
            Do ..HTMLStream.WriteLine("      </div>")
            ;
            Do ..HTMLStream.WriteLine("      <div class=""additional-summary summary"">")
            Do ..HTMLStream.WriteLine("      </div>")
            Do ..HTMLStream.WriteLine("      <div class=""additional-summary postfix"">")
            Do ..HTMLStream.WriteLine("      </div>")
            Do ..HTMLStream.WriteLine("    </div>")
            ;
            ; Print test result
            Do ..HTMLStream.WriteLine("    <table id=""results-table"">")
            Do ..HTMLStream.WriteLine("      <thead id=""results-table-head"">")
            Do ..HTMLStream.WriteLine("        <tr>")
            Do ..HTMLStream.WriteLine("          <th class=""sortable"" data-column-type=""result"">Result</th>")
            Do ..HTMLStream.WriteLine("          <th class=""sortable"" data-column-type=""testId"">Test</th>")
            Do ..HTMLStream.WriteLine("          <th class=""sortable"" data-column-type=""duration"">Duration</th>")
            Do ..HTMLStream.WriteLine("          <th>Links</th>")
            Do ..HTMLStream.WriteLine("        </tr>")
            Do ..HTMLStream.WriteLine("      </thead>")
            ;
            ; print test cases
            Set case=""
            For {
                Set case=$Order(@..#UTResultGbl(tUnitTestId,testSuite,testCase,case),1,data) Quit:case=""
                Set status = ..Status($ListGet(data,1))
                Do ..HTMLStream.WriteLine("<tbody class=""results-table-row "_status_""" id=""testi.py::test_failure"">")
                Do ..HTMLStream.WriteLine("<tr class=""collapsible"" data-id=""test_2"">")
                Do ..HTMLStream.WriteLine("<td class=""col-result collapsed"">"_status_"</td><td class=""col-testId"">"_case_"</td><td class=""col-duration"">"_$ListGet(data,2)_"</td><td class=""col-links""></td></tr>")
                ;
                Set caseDetails = ""
                Set data=""
                Do ..HTMLStream.WriteLine("  <tr class=""extras-row"">")
                Do ..HTMLStream.WriteLine("    <td class=""extra"" colspan=""4"">")
                Do ..HTMLStream.WriteLine("      <div class=""extraHTML""></div>")
                Do ..HTMLStream.WriteLine("      <div class=""media hidden"">")
                Do ..HTMLStream.WriteLine("        <div class=""media-container"">")
                Do ..HTMLStream.WriteLine("          <div class=""media-container__nav--left"">&lt;</div>")
                Do ..HTMLStream.WriteLine("          <div class=""media-container__viewport"">")
                Do ..HTMLStream.WriteLine("            <img src="""">")
                Do ..HTMLStream.WriteLine("            <video controls="""">")
                Do ..HTMLStream.WriteLine("              <source src="""" type=""video/mp4"">")
                Do ..HTMLStream.WriteLine("            </video>")
                Do ..HTMLStream.WriteLine("          </div>")
                Do ..HTMLStream.WriteLine("          <div class=""media-container__nav--right"">&gt;</div>")
                Do ..HTMLStream.WriteLine("        </div>")
                Do ..HTMLStream.WriteLine("        <div class=""media__name""></div>")
                Do ..HTMLStream.WriteLine("        <div class=""media__counter""></div>")
                Do ..HTMLStream.WriteLine("      </div>")
                Do ..HTMLStream.WriteLine("      <div class=""logwrapper"">")
                Do ..HTMLStream.WriteLine("        <div class=""logexpander""></div>")
                Do ..HTMLStream.WriteLine("        <div class=""log"">")
                For {
                    Set caseDetails=$Order(@..#UTResultGbl(tUnitTestId,testSuite,testCase,case,caseDetails),1,data) Quit:caseDetails=""
                    Set mstatus = ..Status($ListGet(data))
                    Do ..HTMLStream.WriteLine("<span><span class="""_mstatus_""">"_mstatus_"</span> "_ $Translate($ListToString($List(data,2,4)),","," ")_"</span><br>")
                }
                Do ..HTMLStream.WriteLine("</div>")
                Do ..HTMLStream.WriteLine("      </div>")
                Do ..HTMLStream.WriteLine("    </td>")
                Do ..HTMLStream.WriteLine("  </tr>")
                Do ..HTMLStream.WriteLine("</tbody>")
            }
            ; end of print test cases
            Do ..HTMLStream.WriteLine("    </table>")
            }
    }
	Do ..HTMLStream.WriteLine("  </body>")
    ;
End ;
    Do ..HTMLStream.WriteLine("  </html>")
	Return $$$OK
}


ClassMethod Status(status As %Integer) [ CodeMode = expression ]
{
$Case(status,0:"failed",1:"passed",:"skipped")
}

Method BuildSystemInfo()
{
    Set utinfo = $Get(@..#UTResultGbl(..UnitTestId))
	Do ..HTMLStream.WriteLine("<!DOCTYPE html>")
	Do ..HTMLStream.WriteLine("<html>")
	Do ..HTMLStream.WriteLine("  <head>")
	Do ..HTMLStream.WriteLine("    <meta charset=""utf-8""/>")
	Do ..HTMLStream.WriteLine("    <title id=""head-title"">"_..FileName_"</title>")
	Do ..HTMLStream.WriteLine("<style>")
	Do ..HTMLStream.WriteLine("body {font-family: Helvetica, Arial, sans-serif;font-size: 12px;/* do not increase min-width as some may use split screens */min-width: 800px;color: #999;}h1 {font-size: 24px;color: black;}h2 {font-size: 16px;color: black;}p {color: black;}a {color: #999;}table {border-collapse: collapse;}/****************************** * SUMMARY INFORMATION ******************************/#environment td {padding: 5px;border: 1px solid #e6e6e6;vertical-align: top;}#environment tr:nth-child(odd) {background-color: #f6f6f6;}#environment ul {margin: 0;padding: 0 20px;}/****************************** * TEST RESULT COLORS ******************************/span.passed,.passed .col-result {color: green;}span.skipped,span.xfailed,span.rerun,.skipped .col-result,.xfailed .col-result,.rerun .col-result {color: orange;}span.error,span.failed,span.xpassed,.error .col-result,.failed .col-result,.xpassed .col-result {color: red;}.col-links__extra {margin-right: 3px;}/****************************** * RESULTS TABLE * * 1. Table Layout * 2. Extra * 3. Sorting items * ******************************//*------------------ * 1. Table Layout *------------------*/#results-table {border: 1px solid #e6e6e6;color: #999;font-size: 12px;width: 100%;}#results-table th,#results-table td {padding: 5px;border: 1px solid #e6e6e6;text-align: left;}#results-table th {font-weight: bold;}/*------------------ * 2. Extra *------------------*/.logwrapper {max-height: 230px;overflow-y: scroll;background-color: #e6e6e6;}.logwrapper.expanded {max-height: none;}.logwrapper.expanded .logexpander:after {content: ""collapse [-]"";}.logwrapper .logexpander {z-index: 1;position: sticky;top: 10px;width: max-content;border: 1px solid;border-radius: 3px;padding: 5px 7px;margin: 10px 0 10px calc(100% - 80px);cursor: pointer;background-color: #e6e6e6;}.logwrapper .logexpander:after {content: ""expand [+]"";}.logwrapper .logexpander:hover {color: #000;border-color: #000;}.logwrapper .log {min-height: 40px;position: relative;top: -50px;height: calc(100% + 50px);border: 1px solid #e6e6e6;color: black;display: block;font-family: ""Courier New"", Courier, monospace;padding: 5px;padding-right: 80px;white-space: pre-wrap;}div.media {border: 1px solid #e6e6e6;float: right;height: 240px;margin: 0 5px;overflow: hidden;width: 320px;}.media-container {display: grid;grid-template-columns: 25px auto 25px;align-items: center;flex: 1 1;overflow: hidden;height: 200px;}.media-container--fullscreen {grid-template-columns: 0px auto 0px;}.media-container__nav--right,.media-container__nav--left {text-align: center;cursor: pointer;}.media-container__viewport {cursor: pointer;text-align: center;height: inherit;}.media-container__viewport img,.media-container__viewport video {object-fit: cover;width: 100%;max-height: 100%;}.media__name,.media__counter {display: flex;flex-direction: row;justify-content: space-around;flex: 0 0 25px;align-items: center;}.collapsible td:not(.col-links) {cursor: pointer;}.collapsible td:not(.col-links):hover::after {color: #bbb;font-style: italic;cursor: pointer;}.col-result {width: 130px;}.col-result:hover::after {content: "" (hide details)"";}.col-result.collapsed:hover::after {content: "" (show details)"";}#environment-header h2:hover::after {content: "" (hide details)"";color: #bbb;font-style: italic;cursor: pointer;font-size: 12px;}#environment-header.collapsed h2:hover::after {content: "" (show details)"";color: #bbb;font-style: italic;cursor: pointer;font-size: 12px;}/*------------------ * 3. Sorting items *------------------*/.sortable {cursor: pointer;}.sortable.desc:after {content: "" "";position: relative;left: 5px;bottom: -12.5px;border: 10px solid #4caf50;border-bottom: 0;border-left-color: transparent;border-right-color: transparent;}.sortable.asc:after {content: "" "";position: relative;left: 5px;bottom: 12.5px;border: 10px solid #4caf50;border-top: 0;border-left-color: transparent;border-right-color: transparent;}.hidden, .summary__reload__button.hidden {display: none;}.summary__data {flex: 0 0 550px;}.summary__reload {flex: 1 1;display: flex;justify-content: center;}.summary__reload__button {flex: 0 0 300px;display: flex;color: white;font-weight: bold;background-color: #4caf50;text-align: center;justify-content: center;align-items: center;border-radius: 3px;cursor: pointer;}.summary__reload__button:hover {background-color: #46a049;}.summary__spacer {flex: 0 0 550px;}.controls {display: flex;justify-content: space-between;}.filters,.collapse {display: flex;align-items: center;}.filters button,.collapse button {color: #999;border: none;background: none;cursor: pointer;text-decoration: underline;}.filters button:hover,.collapse button:hover {color: #ccc;}.filter__label {margin-right: 10px;} ")
	Do ..HTMLStream.WriteLine("</style>")
	Do ..HTMLStream.WriteLine("  </head>")
	Do ..HTMLStream.WriteLine("  <body>")
	Do ..HTMLStream.WriteLine("    <h1 id=""title"">"_..FileName_"</h1>")
	Do ..HTMLStream.WriteLine("    <p>Report generated on "_$ListGet(utinfo,1)_" by iris-ut.html</p>")
	Do ..HTMLStream.WriteLine("    <div id=""environment-header"">")
	Do ..HTMLStream.WriteLine("      <h2>Environment</h2>")
	Do ..HTMLStream.WriteLine("    </div>")
	Do ..HTMLStream.WriteLine("    <table id=""environment"">")
	Do ..HTMLStream.WriteLine("    <!-- TEMPLATES -->")
	Do ..HTMLStream.WriteLine("      <tr>")
	Do ..HTMLStream.WriteLine("        <td>Machine</td>")
	Do ..HTMLStream.WriteLine("        <td>"_$ListGet(utinfo,3)_"</td>")
	Do ..HTMLStream.WriteLine("      </tr>")
	;
	Do ..HTMLStream.WriteLine("      <tr>")
	Do ..HTMLStream.WriteLine("        <td>Instance</td>")
	Do ..HTMLStream.WriteLine("        <td>"_$ListGet(utinfo,4)_"</td>")
	Do ..HTMLStream.WriteLine("      </tr>")
	;
	Do ..HTMLStream.WriteLine("      <tr>")
	Do ..HTMLStream.WriteLine("        <td>version</td>")
	Do ..HTMLStream.WriteLine("        <td>"_$ListGet(utinfo,5)_"</td>")
	Do ..HTMLStream.WriteLine("      </tr>")
	;
	Do ..HTMLStream.WriteLine("      <tr>")
	Do ..HTMLStream.WriteLine("        <td>Namespace</td>")
	Do ..HTMLStream.WriteLine("        <td>"_$ListGet(utinfo,6)_"</td>")
	Do ..HTMLStream.WriteLine("      </tr>")
	;
	Do ..HTMLStream.WriteLine("</table>")
}

Method %OnNew(pUnitTestId As %Integer = "") As %Status
{
    Set ..UnitTestId = pUnitTestId
    Set ..FileName = "ut-"_..UnitTestId_$Translate($ZDatetime($Horolog,3)," -:")_".html"
    Quit $$$OK
}
}