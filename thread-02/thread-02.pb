; Simple thread example for result data ByRef

CompilerIf Not #PB_Compiler_Thread
  CompilerError "Use Compiler-Option ThreadSafe!"
CompilerEndIf

Structure udtThreadData
  ThreadID.i
  strVal.s
  fltVal.f
  List Text.s()
EndStructure

Procedure MyThread(*Data.udtThreadData)
  Protected index
  With *Data
    \strVal = "Hello World!"
    \fltVal = 2023.24
    For index = 1 To 10
      AddElement(\Text())
      \Text() = "List Entry " + index
      Delay(100)
    Next
  EndWith
  
EndProcedure

Global *MyData.udtThreadData

*MyData = AllocateStructure(udtThreadData)
With *MyData
  \ThreadID = CreateThread(@MyThread(), *MyData)
  While IsThread(\ThreadID)
    Debug "Wait ..."
    Delay(200)
  Wend
  ;WaitThread(\ThreadID) ;WaitThread(\ThreadID,500)
  Debug \strVal
  Debug \fltVal
  ForEach \Text()
    Debug \Text()
  Next
EndWith

FreeStructure(*MyData)
