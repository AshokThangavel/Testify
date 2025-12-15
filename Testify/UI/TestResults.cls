Class Testify.UI.TestResults Extends %CSP.Page
{

Parameter Title As STRING [ Final ] = "Testify";

Parameter APPLICATION As STRING = "Testify";

Parameter DOMAIN As STRING = "Testify";

ClassMethod OnRenderScreen() As %Status
{
	&HTML<
    <div class="fixed-header">
        <div class="header-content">
            <h1>Unit Test Results</h1>
            <p>View and manage your test suite results</p>
        </div>
    </div>

    <div class="container">
        <div class="table-container">
            <table id="testTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Status</th>
                        <th>DateTime</th>
                        <th>Duration</th>
                        <th>Download</th>
                        <th>ViewTestResult</th>
                        <th>DeleteSuite</th>
                    </tr>
                </thead>
                <tbody id="testTableBody">
                    <tr>
                        <td colspan="7" class="table-loading">
                            <i class="fas fa-spinner"></i><br>Loading test suites...
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Modal for Test Results -->
	    <div id="testResultModal" class="modal">
	        <div class="modal-content">
	            <div class="modal-header">
	                <h3 id="modalTitle">Test Results</h3>
	                <div id="modalMeta" style="font-size:12px;color:#6c757d;"></div>
	                <button class="close" onclick="closeModal()">&times;</button>
	            </div>
	            <div class="modal-body" id="modalBody">
	                <!-- Test results will be inserted here -->
	            </div>
	        </div>
	    </div>
	>
	Quit 1
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
	*{margin:0;padding:0;box-sizing:border-box}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background-color:#f8f9fa;color:#333;line-height:1.3}.fixed-header{position:fixed;top:0;left:0;right:0;background:#fff;padding:15px 0;box-shadow:0 2px 4px rgba(0,0,0,.1);z-index:100}.header-content{max-width:1200px;margin:0 auto;padding:0 20px}.header-content h1{font-size:24px;font-weight:600;color:#2c3e50;margin-bottom:4px}.header-content p{color:#7f8c8d;font-size:14px}.container{max-width:1200px;margin:0 auto;padding:100px 20px 20px}.table-container{background:#fff;border-radius:6px;box-shadow:0 1px 3px rgba(0,0,0,.1);overflow:hidden}table{width:100%;border-collapse:collapse;font-size:13px}th,td{padding:8px 12px;text-align:left;border-bottom:1px solid #e9ecef;white-space:nowrap}th{background:#f8f9fa;font-weight:600;color:#495057;font-size:12px;text-transform:uppercase;letter-spacing:.5px}tr:hover{background-color:#f8f9fa}.status{font-size:12px;font-weight:500}.status.passed{color:#2e7d32}.status.failed{color:#c62828}.status.running{color:#f57c00}.btn{padding:4px 10px;border:1px solid #dee2e6;border-radius:3px;cursor:pointer;font-size:12px;font-weight:500;text-decoration:none;display:inline-flex;align-items:center;gap:4px;transition:all .2s ease;background:#f8f9fa;color:#495057}.btn:hover{background:#e9ecef}.btn-danger{background:#f8d7da;color:#721c24;border-color:#f5c6cb}.btn-danger:hover{background:#f1aeb5}.btn-primary{background:#e7f3ff;color:#06c;border-color:#b3d9ff}.btn-primary:hover{background:#cce7ff}.modal{display:none;position:fixed;z-index:1000;left:0;top:0;width:100%;height:100%;background-color:rgba(0,0,0,.5);overflow:hidden}.modal-content{background-color:#fff;position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);width:90%;max-width:900px;height:80vh;max-height:80vh;border-radius:6px;box-shadow:0 4px 20px rgba(0,0,0,.15);display:flex;flex-direction:column}.modal-header{background:#f8f9fa;padding:12px 16px;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid #e9ecef;flex-shrink:0}.modal-header h3{margin:0;font-size:16px;font-weight:600;color:#2c3e50}.close{background:none;border:none;font-size:20px;cursor:pointer;color:#6c757d;padding:0;width:28px;height:28px;display:flex;align-items:center;justify-content:center;border-radius:4px}.close:hover{background:#e9ecef}.modal-body{flex-grow:1;overflow-y:auto;padding:0;background:#fff}.modal-body::-webkit-scrollbar{width:6px}.modal-body::-webkit-scrollbar-track{background:#f1f1f1}.modal-body::-webkit-scrollbar-thumb{background:#c1c1c1;border-radius:3px}.modal-body::-webkit-scrollbar-thumb:hover{background:#a8a8a8}.test-results{font-family:"SF Mono",Monaco,"Cascadia Code",monospace;padding:16px;font-size:12px}.test-case{border:1px solid #e9ecef;border-radius:4px;margin-bottom:12px;overflow:hidden}.test-case-header{background:#f8f9fa;padding:10px 12px;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid #e9ecef}.test-case-title{font-weight:600;font-size:13px;color:#2c3e50}.test-case-meta{display:flex;align-items:center;gap:10px}.test-case-status{font-weight:500;font-size:12px}.test-case-status.passed{color:#2e7d32}.test-case-status.failed{color:#c62828}.test-case-duration{color:#6c757d;font-size:11px}.test-case-body{padding:12px}.test-steps{display:flex;flex-direction:column;gap:8px}.test-step{border-left:2px solid #e9ecef;padding-left:10px}.test-step.passed{border-left-color:#2e7d32}.test-step.failed{border-left-color:#c62828}.test-step-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:4px}.test-step-info{display:flex;align-items:center;gap:8px}.test-step-counter{background:#e9ecef;color:#495057;padding:1px 6px;border-radius:10px;font-size:10px;font-weight:600}.test-step-action{font-weight:600;color:#2c3e50;font-size:12px}.test-step-status{font-size:11px;font-weight:500}.test-step-status.passed{color:#2e7d32}.test-step-status.failed{color:#c62828}.test-step-description{color:#6c757d;font-size:11px}.summary-section{background:#f8f9fa;border-radius:4px;padding:12px;margin:16px 0 12px}.summary-title{font-size:13px;font-weight:600;color:#2c3e50;margin-bottom:10px;text-align:center}.summary-stats{display:flex;justify-content:center;gap:20px;flex-wrap:wrap}.summary-stat{display:flex;align-items:center;gap:6px;font-weight:500;font-size:12px}.summary-stat.passed{color:#2e7d32}.summary-stat.failed{color:#c62828}.summary-stat i{font-size:14px}.loading{text-align:center;padding:30px;color:#6c757d}.loading i{font-size:20px;animation:spin 1s linear infinite}@keyframes spin{0%{transform:rotate(0)}100%{transform:rotate(360deg)}}@media (max-width:768px){.container{padding:110px 10px 20px}.header-content h1{font-size:20px}.table-container{overflow-x:auto}table{min-width:600px}.modal-content{width:95%;height:85vh;max-height:85vh}.summary-stats{flex-direction:column;align-items:center;gap:10px}}
]]>
	</data>
}

ClassMethod GetTestSuites() As %String
{
	Set data=[]
	Set tResult  = ##class(%SQL.Statement).%ExecDirect(,"SELECT JSON_OBJECT('id':ID, 'dateTime':DateTime, 'duration':CONCAT(Duration,' ms') ) as testInstance FROM %UnitTest_Result.TestInstance ORDER BY ID DESC")
	While tResult.%Next(){
		Set testdata = {}.%FromJSON(tResult.testInstance)
		Set testdata.status = ..calcStatus(testdata.id)
		Do data.%Push(testdata)
	}
	Return data.%ToJSON()
}

ClassMethod calcStatus(pTestId) As %Status
{
	Set notPassed=0
	Set ind=##class(%UnitTest.Result.TestInstance).%OpenId(pTestId)
	If $IsObject(ind) {
		For i=1:1:ind.TestSuites.Count() {
			Set suitestatus=##class(%UnitTest.Portal.standardPage).GetTestStatus(pTestId,ind.TestSuites.GetAt(i).Name)
			Set suite(suitestatus)=$Get(suite(suitestatus))+1
			If suitestatus'=1 {
				Set notPassed=1
			}
		}
	}
	If notPassed=0 {
		Set status = "All Suites Passed"
	}
	Else {
		Set sub=""
		For  {
			Set sub=$Order(suite(sub))
			Quit:sub=""
			Set str=$$$Text("Test Suite")
			If suite(sub)>1 {
				Set str=$$$Text("Test Suites")
			}
			If sub=0 {
				Set status=$$$Text("failed")
			}
			If sub=2 {
				Set status=$$$Text("skipped")
			}
			If sub=1 {
				Set status=$$$Text("passed")
			}

		}
	}
	Quit status
}

ClassMethod UnitTestResultById(Id As %Integer) As %DynamicArray
{
	Quit:Id="" ""
	Set arr = ##class(Testify.Format.Serializer).GenerateJSON(Id)
	Return arr.%ToJSON()
}

ClassMethod DeleteUnitTestResult(pTestId As %Integer) As %Status
{
	Return ##class(%UnitTest.Result.TestInstance).%DeleteId(pTestId)
}

ClassMethod Scripts()
{
	&HTML<
	<script language="javascript">
        testSuites = JSON.parse(#server(..GetTestSuites())#);
        function renderTestSuites(suites) {
            const tbody = document.getElementById('testTableBody');
            tbody.innerHTML = '';

            suites.forEach(suite => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${suite.id}</td>
                    <td><span class="status ${suite.status}">${suite.status.charAt(0).toUpperCase() + suite.status.slice(1)}</span></td>
                    <td>${suite.dateTime}</td>
                    <td>${suite.duration}</td>
                    <td><a href="Testify.Report.Download.cls?utid=${suite.id}"" class="btn btn-primary" download><i class="fas fa-download"></i> Download</a></td>
                    <td><button class="btn" onclick="viewTestResult('${suite.id}')"><i class="fas fa-eye"></i> View</button></td>
                    <td><button class="btn btn-danger" onclick="deleteSuite('${suite.id}')"><i class="fas fa-trash"></i> Delete</button></td>
                `;
                tbody.appendChild(row);
            });
        }

        function renderTestResults(data) {
            let html = '<div class="test-results">';

            data.results.forEach(suite => {
                html += `
                    <div class="test-suite">
                        <div class="test-suite-header">${suite.suiteName}</div>
                        <div class="test-suite-body">
                `;

                // Render test cases
                suite.testcases.forEach(testcase => {
                    html += `
                        <div class="test-case">
                            <div class="test-case-header">${testcase.testcaseName}</div>
                            <div class="test-case-body">
                    `;

                    // Render methods
                    testcase.methods.forEach(method => {
                        html += `
                            <div class="test-method">
                                <div class="test-method-header">${method.methodName}</div>
                                <div class="test-method-details">
                                    <div><strong>Action:</strong> ${method.assertAction} #${method.assertCounter}</div>
                                    <div><strong>Description:</strong> ${method.assertDescription}</div>
                                    ${method.assertLocation ? `<div><strong>Location:</strong> ${method.assertLocation}</div>` : ''}
                                </div>
                            </div>
                        `;
                    });

                    html += `
                            </div>
                        </div>
                    `;
                });

                html += `
                        </div>
                    </div>
                `;
            });

            // Calculate summary statistics
            let totalSuites = data.results.length;
            let totalTestCases = 0;
            let totalMethods = 0;

            data.results.forEach(suite => {
                totalTestCases += suite.testcases.length;
                suite.testcases.forEach(testcase => {
                    totalMethods += testcase.methods.length;
                });
            });

            // Render summary
            html += `
                <div class="summary-section">
                    <div class="summary-title">Test Summary</div>
                    <div class="summary-stats">
                        <div class="summary-stat">
                            <i class="fas fa-layer-group"></i>
                            <span>${totalSuites} Suites</span>
                        </div>
                        <div class="summary-stat">
                            <i class="fas fa-briefcase"></i>
                            <span>${totalTestCases} Test Cases</span>
                        </div>
                        <div class="summary-stat">
                            <i class="fas fa-cogs"></i>
                            <span>${totalMethods} Methods</span>
                        </div>
                    </div>
                </div>
            `;

            html += '</div>';
            return html;
        }

        // Function to load test suites
        async function loadTestSuites() {
            try {
                const suites = JSON.parse(#server(..GetTestSuites())#);;
                renderTestSuites(suites);

            } catch (error) {
                const tbody = document.getElementById('testTableBody');
                tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #c62828; padding: 40px;">Error loading test suites</td></tr>';
            }
        }

        // Function to view test results
        async function viewTestResult(testId) {
            const modal = document.getElementById('testResultModal');
            const modalTitle = document.getElementById('modalTitle');
            const modalMeta = document.getElementById('modalMeta');
            const modalBody = document.getElementById('modalBody');

            // Show loading state
            modalTitle.innerHTML = `Test Results - Loading...`;

    			modalMeta.innerHTML = '';

            modalBody.innerHTML = '<div class="loading"><i class="fas fa-spinner"></i><br>Loading test results...</div>';
            modal.style.display = 'block';

            try {
                data = JSON.parse(#server(..UnitTestResultById(testId))#);
                // Update modal header with test metadata
                modalTitle.innerHTML = `Test Results - ID: ${data.id} (${data.namespace})`;
                modalMeta.innerHTML = `
                    <span>Duration: ${data.duration}</span> |
                    <span>DateTime: ${data.testDateTime}</span>
                `;
                modalBody.innerHTML = renderTestResults(data);

            } catch (error) {
                modalTitle.innerHTML = `Test Results - Error`;
				modalMeta.innerHTML = '';
                modalBody.innerHTML = '<div style="text-align: center; color: #c62828; padding: 40px;">Error loading test results</div>';
            }
        }

        // Function to close modal
        function closeModal() {
            const modal = document.getElementById('testResultModal');
            modal.style.display = 'none';
        }

        // Function to delete suite
        function deleteSuite(testId) {
            if (confirm('Delete this test suite?')) {
	            alert(testId);
                let sc = #server(..DeleteUnitTestResult(testId))#;
                window.location.reload();
            }
        }

        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('testResultModal');
            if (event.target === modal) {
                closeModal();
            }
        }

        // Close modal with Escape key
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                closeModal();
            }
        });

        // Download notification
        document.addEventListener('DOMContentLoaded', function() {
            // Load test suites on page load
            loadTestSuites();

            // Setup download notifications
            document.addEventListener('click', function(e) {

            });
        });
    </script>
	>
}

}