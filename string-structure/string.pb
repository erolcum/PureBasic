Procedure MyFunction(Value1, Value2, *Result.Integer)
  Protected r1
  
  *Result\i = Value1 + Value2
  
  If *Result\i > 0
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
  
EndProcedure

Procedure MyFunctionStr(Value1.s, Value2.s, *Result.String)
  Protected r1
  
  *Result\s = Value1 + Value2
  
  r1 = Len(*Result\s)
  ProcedureReturn r1
  
EndProcedure


Define Value.i

a = MyFunction(100, 200, @Value)

Debug Value

; Special with Strings, Because we need always a variable where stored the pointer to string

Define sVal.String ; This define a string structure

a = MyFunctionStr("ABC ", "World!", @sVal)

Debug sVal\s 
ShowMemoryViewer(@sVal\s, 20)
