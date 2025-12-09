Class Testify.UnitTest.Base Extends %RegisteredObject
{

Parameter BaseDir As COSEXPRESSION = "$system.Util.InstallDirectory()";

Parameter UTDir As COSEXPRESSION = "##class(%File).NormalizeDirectory(..#BaseDir_""/Testify"")";

ClassMethod UnitTestRootSet(pDirectory = {..#UTDir})
{
	Set:pDirectory'="" ^UnitTestRoot=pDirectory
}

/// System usage. IRIS refers this global
ClassMethod UnitTestRootGet() [ CodeMode = expression ]
{
$Get(^UnitTestRoot)
}


/// Create a directory to load the Unit test files
ClassMethod CheckUTExist()
{
	If '##class(%File).DirectoryExists(..#UTDir) {
		Do ##class(%File).CreateDirectoryChain(..#UTDir)
	}
}

}