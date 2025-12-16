Class Testify.Utils Extends %RegisteredObject
{

ClassMethod ImportDeepseePackages(pLocation As %String = "") As %Status
{
    // Import DeepSee User Library Utils package
    Set loc = ##class(%File).NormalizeDirectory(pLocation)
    Set fileSet = ##class(%File).FileSetFunc(loc, "*.DFI")
    While fileSet.%Next() {
        Set fileName = fileSet.Name
        Set files(fileName)=""
        If (fileName'="") {
            Set tSC = ##class(%DeepSee.UserLibrary.Utils).%Import(fileName)
            If $$$ISERR(tSC) {
                Write tSC
            }
        }
    }
    Set fileName = ##class(%File).NormalizeFilename(pLocation_"/Chart-Samples.xml")
    Set sc= $System.OBJ.Export(.items,fileName)
    If $$$ISOK(sc) {
        Do ##class(%DeepSee.UserLibrary.Utils).%Import(fileName,1,1)
    }
    Quit tSC
}

ClassMethod ImportDeepseePackages1(pLocation As %String = "") As %Status
{
    Set loc = ##class(%File).NormalizeDirectory(pLocation)
    Set fileSet = ##class(%File).FileSetFunc(loc, "*.DFI")
    While fileSet.%Next() {
        Set fileName = fileSet.Name
        Set files(fileName)=""
    }
    Set fileName = ##class(%File).NormalizeFilename($ZUtil(12,"")_"/Testify_DFI.xml")
    Set sc= $System.OBJ.Export(.files,fileName)
    If $$$ISOK(sc) {
        Do ##class(%DeepSee.UserLibrary.Utils).%Import(fileName,1,1)
    }
}

}
