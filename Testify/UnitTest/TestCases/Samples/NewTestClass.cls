/// Sample Test class
Class Testify.UnitTest.TestCases.Samples.NewTestClass Extends Testify.UnitTest.TestCases
{
Method TestAdd1()
{
    Do $$$AssertEquals(5,5, "Test 2+3=5")
    Do $$$AssertNotEquals(4,5, "Test 3+4 '= 5")
}

}