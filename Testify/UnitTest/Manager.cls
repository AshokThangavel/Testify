Class Testify.UnitTest.Manager Extends (%UnitTest.Manager, Testify.UnitTest.Base)
{
/// Send unit test class at runtime as an array
/// <EXAMPLE>
/// Set exportFiles("UnitTest.Cases.ClinDocCase.cls")=""
/// </EXAMPLE>
ClassMethod RunScripts(ByRef exportFiles)
{
	#define NormalizeDir(%dir)	##class(%File).NormalizeDirectory(%dir)
	#define NormalizeFile(%file)	##class(%File).NormalizeFilename(%file)
    #define DirectoryExists(%dir) ##class(%File).DirectoryExists(%dir)

	Set utDir = $$$NormalizeDir(..#UTDir)
    If '$$$DirectoryExists(utDir){
        Do ##class(%File).CreateDirectoryChain(utDir)
    }
	Do ..UnitTestRootSet(..#UTDir)
	Set file = $$$NormalizeFile(utDir_"/testcases.xml")
	Do $System.OBJ.Export(.exportFiles,file,,.err)

	Do ..RunTest(,"/nodisplay/display=none/nodelete")
	//Do ##class(%File).Delete(file)
}

/// Called at the end of SaveResult() to perform any result aggregation tasks required by subtasks.
Method OnAfterSaveResult(ByRef userparam)
{
	Set ^||testify.lastid($Job) = ..ResultId
	Quit 1
}
}