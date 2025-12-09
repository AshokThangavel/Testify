Class Testify.Home Extends %CSP.Page
{

Parameter Title As STRING [ Final ] = "Testify";

Parameter APPLICATION As STRING = "Testify";

Parameter TestCaseBase As STRING = "Testify.UnitTest.TestCases";


Parameter UnitTestMgr As STRING = "Testify.UnitTest.Manager";

ClassMethod OnRenderScreen()
{
	&HTML<
    <div class="container">
        <div class="left-panel">
            <h1>Test Execution</h1>
            <h4>Select Unit Test files to execute</h4>

            <div class="form-group">
                <label for="test-select">Test File</label>
                <select id="test-select">
                    <option value="">-- Select a test file --</option>
    >
    Do ..GetTestcaseClasses(.myitems)
    Set clas = ""
    For {
        Set clas = $Order(myitems(clas)) Quit:clas=""
        Write "<option value="""_clas_""">"_clas_"</option>"
    }
    &HTML<
        </select>
            </div>

            <button id="run-test" class="btn" disabled>Run Test</button>
        </div>

        <div class="right-panel">
            <div class="response-container">
                <div id="empty-state" class="empty-state">
                    <div class="empty-state-icon">📋</div>
                    <h3>No Test Results</h3>
                    <p>Select a test file and click "Run Test" to see the results here.</p>
                </div>

                <div id="response-area" style="display: none;">
                    <div class="response-header">
                        <div class="response-title">Test Results</div>

                        <div id="status-badge" class="status-badge"></div>
                        <div id="download-html" class="download-html"></div>
                    </div>
                    <div id="response-content" class="test-results"></div>
                </div>
            </div>
        </div>
    </div>
	>
}

ClassMethod executeList(package)
{
	Set package = package_".cls"
	Set packages(package)=""
	Do $ClassMethod(..#UnitTestMgr,"RunScripts",.packages)
}

ClassMethod GetUnitTestData(package)
{
	Set id = $Get(^||testify.lastid($Job))
	Set:id="" id = ^|$Namespace|UnitTest.Result
	Set json = ..UnitTestResultById(id)
	Set:'$IsObject(json) json =[]
	Return json.%ToJSON()
}

ClassMethod UnitTestResultById(Id As %Integer) As %DynamicArray
{
	Quit:Id="" ""
	Set testSuite = $Order(^UnitTest.Result(Id,""))
	Set testCase = $Order(^UnitTest.Result(Id,testSuite,""))
	Set TestCaseId = Id_"||"_testSuite_"||"_testCase
	Set cased = {"testid":(Id),"testCase":(testCase),"TestCaseId":(TestCaseId)}
	Set tReslt = ##class(%SQL.Statement).%ExecDirect(,"Select ID,Name as TestMethod,Status,ErrorDescription,Duration from %UnitTest_Result.TestMethod where TestCase=?",TestCaseId)
	Set arr = []
	While tReslt.%Next() {
		Set j = {
				"id":(tReslt.ID),
				"testMethod":(tReslt.TestMethod),
				"status": (tReslt.Status),
				"erroDescription":(tReslt.ErrorDescription),
				"duration":(tReslt.Duration)
		}
		Set TestMethod = TestCaseId_"||"_tReslt.TestMethod
		Set tResult1 = ##class(%SQL.Statement).%ExecDirect(, "Select ID,Counter,Action,Status,Description from %UnitTest_Result.TestAssert where TestMethod=?",TestMethod)
		Set resultarr=[]
		While tResult1.%Next() {
			Set jsn = {"Counter":(tResult1.Counter),
					"action":(tResult1.Action),
					"status":(tResult1.Status),
					"description":(tResult1.Description),
					"location":("")
			}
			Do resultarr.%Push(jsn)

		}
		Do j.%Set("testResult",resultarr)
		Do arr.%Push(j)
	}
	//zw arr
	Return arr
}

ClassMethod GetTestcaseClasses(Output pClsList)
{
	Do $System.OBJ.GetPackageList(.pClsList,..#TestCaseBase)
	Set tResult = ##class(%SQL.Statement).%ExecDirect(,"SELECT Name FROM %Dictionary.ClassDefinitionQuery_SubclassOf(?)",..#TestCaseBase)
	While tResult.%Next()
	{
		Set pClsList(tResult.Name)=""
	}
}

ClassMethod OnPage() As %Status
{
	Do ..OnPageCSPROOT()
	Quit 1
}

ClassMethod OnPageCSPROOT() As %Boolean
{
	Do ..OnPageHTML()
}

ClassMethod OnPageHTML() As %Boolean
{
	Write "<html>",!
	Do ..OnPageHEAD()
	Do ..OnPageBODY()
	Write !,"</html>"
	Return $$$OK
}

ClassMethod OnPageHEAD() As %Boolean
{
	Write "<head>",!
	Write !,"<title>"_..#Title_"</title>",!
    Write "<style>",!
	Do ..LoadCSS()
	Write "</style>",!
	Write "<link rel=""shortcut icon"" href=""portal/ISC_IRIS_icon.ico"">"
	Write " <link rel=""stylesheet"" href=""https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"">",!
	Write "</head>",!
	Write ..HyperEventHead(0,0)
	Return $$$OK
}

ClassMethod OnPageBODY() As %Boolean
{
	Do ..RenderScreen()
	Return $$$OK
}

/// Override this method to render your screens in UI
ClassMethod RenderScreen()
{
	Do ..OnRenderScreen()
	Do ..Scripts()
}

ClassMethod LoadCSS()
{
	Set obj = ##class(%Dictionary.CompiledXData).%OpenId($ClassName()_"||Style")
	Return:(obj = "") $$$OK
	Set xdata = obj.Data
	Set status = ##class(%XML.TextReader).ParseStream(xdata, .textreader)
	While textreader.Read() { If (textreader.NodeType="chars") { Write textreader.Value } }
	Return $$$OK
}

XData Style
{
<data>
	<![CDATA[
	:root{--primary-color:#4a6cf7;--secondary-color:#6c757d;--success-color:#28a745;--danger-color:#dc3545;--warning-color:#ffc107;--light-color:#f8f9fa;--dark-color:#343a40;--border-radius:8px;--box-shadow:0 4px 6px rgba(0,0,0,.1)}*{box-sizing:border-box;margin:0;padding:0}body{font-family:'Roboto',sans-serif;background-color:#f5f7fb;color:var(--dark-color);line-height:1.6}.container{display:flex;min-height:100vh}.left-panel{width:350px;background-color:#fff;padding:2rem;box-shadow:var(--box-shadow);z-index:1}.right-panel{flex:1;padding:2rem;overflow-y:auto}h1{font-size:1.8rem;margin-bottom:.5rem;color:var(--dark-color)}h4{font-size:1rem;font-weight:500;margin-bottom:1.5rem;color:var(--secondary-color)}.form-group{margin-bottom:1.5rem}label{display:block;margin-bottom:.5rem;font-weight:500}select{width:100%;padding:.75rem;border:1px solid #ddd;border-radius:var(--border-radius);background-color:#fff;font-size:1rem;transition:border-color .3s}select:focus{outline:0;border-color:var(--primary-color);box-shadow:0 0 0 3px rgba(74,108,247,.2)}.btn{display:inline-block;padding:.75rem 1.5rem;background-color:var(--primary-color);color:#fff;border:0;border-radius:var(--border-radius);font-size:1rem;cursor:pointer;transition:background-color .3s}.btn:hover{background-color:#3a5bd9}.btn:disabled{background-color:var(--secondary-color);cursor:not-allowed}.response-container{background-color:#fff;border-radius:var(--border-radius);box-shadow:var(--box-shadow);padding:1.5rem;height:calc(100vh - 4rem);overflow-y:auto}.response-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:1rem;padding-bottom:1rem;border-bottom:1px solid #eee}.response-title{font-size:1.2rem;font-weight:500}.status-badge{padding:.25rem .75rem;border-radius:20px;font-size:.875rem;font-weight:500}.status-success{background-color:rgba(40,167,69,.1);color:var(--success-color)}.status-error{background-color:rgba(220,53,69,.1);color:var(--danger-color)}
    .status-loading{background-color:rgba(108,117,125,.1);color:var(--secondary-color)}.loading-spinner{display:inline-block;width:20px;height:20px;border:3px solid rgba(255,255,255,.3);border-radius:50%;border-top-color:#fff;animation:spin 1s ease-in-out infinite}@keyframes spin{to{transform:rotate(360deg)}}.empty-state{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;color:var(--secondary-color);text-align:center}.empty-state-icon{font-size:3rem;margin-bottom:1rem;opacity:.5}.test-results{display:flex;flex-direction:column;gap:1.5rem}.test-case{border:1px solid #eee;border-radius:var(--border-radius);overflow:hidden}.test-case-header{background-color:#f8f9fa;padding:1rem;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid #eee}.test-case-title{font-weight:500;font-size:1.1rem}.test-case-meta{display:flex;align-items:center;gap:1rem}.test-case-status{padding:.25rem .5rem;border-radius:4px;font-size:.8rem;font-weight:500}.test-case-status.passed{background-color:rgba(40,167,69,.1);color:var(--success-color)}.test-case-status.failed{background-color:rgba(220,53,69,.1);color:var(--danger-color)}.test-case-duration{font-size:.9rem;color:var(--secondary-color)}.test-case-body{padding:1rem}.test-steps{display:flex;flex-direction:column;gap:.75rem}.test-step{border-left:3px solid #eee;padding-left:1rem}.test-step.passed{border-left-color:var(--success-color)}.test-step.failed{border-left-color:var(--danger-color)}.test-step-header{display:flex;justify-content:space-between;margin-bottom:.25rem}.test-step-info{display:flex;align-items:center;gap:.5rem}.test-step-counter{font-weight:500;color:var(--secondary-color)}.test-step-action{font-weight:500}.test-step-status{display:flex;align-items:center;gap:.25rem;font-size:.85rem}.test-step-status.passed{color:var(--success-color)}.test-step-status.failed{color:var(--danger-color)}.test-step-description{margin-bottom:.25rem;color:var(--dark-color)}.test-step-location{font-size:.8rem;color:var(--secondary-color);font-family:'Courier New',Courier,monospace}.summary-section{margin-top:1.5rem;padding:1rem;background-color:#f8f9fa;border-radius:var(--border-radius)}.summary-title{font-weight:500;margin-bottom:.5rem}.summary-stats{display:flex;gap:1rem}.summary-stat{display:flex;align-items:center;gap:.25rem}.summary-stat i{font-size:.9rem}.summary-stat.passed{color:var(--success-color)}.summary-stat.failed{color:var(--danger-color)}@media (max-width:768px){.container{flex-direction:column}.left-panel{width:100%}}
]]>
	</data>
}

ClassMethod Scripts()
{
	&HTML<
	<script language="javascript">
        document.addEventListener('DOMContentLoaded', function() {
            const testSelect = document.getElementById('test-select');
            const runTestBtn = document.getElementById('run-test');
            const emptyState = document.getElementById('empty-state');
            const responseArea = document.getElementById('response-area');
            const statusBadge = document.getElementById('status-badge');
            const downloadHtml = document.getElementById('download-html');
            const responseContent = document.getElementById('response-content');

            // Enable/disable run button based on selection
            testSelect.addEventListener('change', function() {
                runTestBtn.disabled = !this.value;
            });

            // Run test when button is clicked
            runTestBtn.addEventListener('click', function() {
                const selectedTest = testSelect.value;

                if (!selectedTest) return;

                // Show loading state
                emptyState.style.display = 'none';
                responseArea.style.display = 'block';
                statusBadge.className = 'status-badge status-loading';
                statusBadge.innerHTML = '<span class="loading-spinner"></span> Running...';
                responseContent.innerHTML = '<div>Executing test...</div>';

                // Make API call
                runTest(selectedTest)
                    .then(response => {
	                     const topId = response[0]?.id || ''; // safe fallback
        				// Extract the number before the first '||'
        				const utid = topId.split('||')[0];

                        // Handle successful response
                        const hasFailures = response.some(test => test.status === 0);

                        if (hasFailures) {
                            statusBadge.className = 'status-badge status-error';
                            statusBadge.textContent = 'Failed';
                            downloadHtml.innerHTML = `<a href="Testify.Report.Download.cls?utid=${utid}">Download</a>`;
                        } else {
                            statusBadge.className = 'status-badge status-success';
                            statusBadge.textContent = 'Success';
                            downloadHtml.innerHTML = `<a href="Testify.Report.Download.cls?utid=${utid}">Download</a>`;
                        }

                        // Format and display the test results
                        responseContent.innerHTML = formatTestResults(response);
                    })
                    .catch(error => {
                        // Handle error
                        statusBadge.className = 'status-badge status-error';
                        statusBadge.textContent = 'Error';
                        responseContent.innerHTML = `<div class="error-message">Error: ${error.message}</div>`;
                    });
            });

            // Function to run the test and return parsed JSON
            async function runTest(testName) {
                try {
                    // This is where you call your server method
                    // Replace this with your actual server call
                    #server(..executeList(testName))#;
                    const resultData = #server(..GetUnitTestData(testName))#;
                    return JSON.parse(resultData);
                } catch (error) {
                    throw new Error(`Failed to run test: ${error.message}`);
                }
            }

            // Function to format test results as HTML
            function formatTestResults(testResults) {
                if (!testResults || testResults.length === 0) {
                    return '<div>No test results available</div>';
                }

                let html = '';
                let totalPassed = 0;
                let totalFailed = 0;

                testResults.forEach(test => {
                    const testStatus = test.status === 1 ? 'passed' : 'failed';
                    const statusText = test.status === 1 ? 'Passed' : 'Failed';
                    const statusIcon = test.status === 1 ? 'fa-check-circle' : 'fa-times-circle';

                    if (test.status === 1) {
                        totalPassed++;
                    } else {
                        totalFailed++;
                    }

                    html += `
                        <div class="test-case">
                            <div class="test-case-header">
                                <div class="test-case-title">${test.testMethod}</div>
                                <div class="test-case-meta">
                                    <div class="test-case-status ${testStatus}">
                                        <i class="fas ${statusIcon}"></i> ${statusText}
                                    </div>
                                    <div class="test-case-duration">${(test.duration * 1000).toFixed(2)}ms</div>
                                </div>
                            </div>
                            <div class="test-case-body">
                                <div class="test-steps">
                    `;

                    test.testResult.forEach(step => {
                        const stepStatus = step.status === 1 ? 'passed' : 'failed';
                        const stepStatusText = step.status === 1 ? 'Passed' : 'Failed';
                        const stepStatusIcon = step.status === 1 ? 'fa-check-circle' : 'fa-times-circle';

                        html += `
                            <div class="test-step ${stepStatus}">
                                <div class="test-step-header">
                                    <div class="test-step-info">
                                        <span class="test-step-counter">#${step.Counter}</span>
                                        <span class="test-step-action">${step.action}</span>
                                    </div>
                                    <div class="test-step-status ${stepStatus}">
                                        <i class="fas ${stepStatusIcon}"></i> ${stepStatusText}
                                    </div>
                                </div>
                                <div class="test-step-description">${step.description}</div>
                                ${step.location ? `<div class="test-step-location">${step.location}</div>` : ''}
                            </div>
                        `;
                    });

                    html += `
                                </div>
                            </div>
                        </div>
                    `;
                });

                // Add summary section
                html += `
                    <div class="summary-section">
                        <div class="summary-title">Test Summary</div>
                        <div class="summary-stats">
                            <div class="summary-stat passed">
                                <i class="fas fa-check-circle"></i>
                                <span>${totalPassed} Passed</span>
                            </div>
                            <div class="summary-stat failed">
                                <i class="fas fa-times-circle"></i>
                                <span>${totalFailed} Failed</span>
                            </div>
                            <div class="summary-stat">
                                <i class="fas fa-clock"></i>
                                <span>${testResults.length} Tests</span>
                            </div>
                        </div>
                    </div>
                `;

                return html;
            }
        });
    </script>
	>
}
}