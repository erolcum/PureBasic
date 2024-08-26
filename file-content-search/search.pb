
Structure FILEITEM
  Name.s
  Attributes.i
  Size.q
  DateCreated.i
  DateAccessed.i
  DateModified.i
EndStructure

; This is a constant to identify the window.
Enumeration
  #WindowFiles
EndEnumeration

; This is an enumeration to identify controls that will appear on the window.
Enumeration
  #FolderButton
  #UpdateButton
  #SearchButton
  #ToFindString
  #LabelText
  #FolderText
  #FilesList
EndEnumeration

Procedure FilesExamine(Folder.s, List Files.FILEITEM())
  ; Obtains file properties from Folder into Files.
  
  Protected.l Result
  
  ; Clear current contents.
  ClearList(Files())
  
  ; Open the directory to enumerate its contents.
  Result = ExamineDirectory(0, Folder, "*.*")  
  
  ; If this is ok, begin enumeration of entries.
  If Result
    ; Loop through until NextDirectoryEntry(0) becomes zero - indicating that there are no more entries.
    While NextDirectoryEntry(0)
      ; If the directory entry is a file, not a folder.
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File
        ; Add a new element to the list.
        AddElement(Files())
        ; And populate it with the properties of the file.
        Files()\Name = DirectoryEntryName(0)
        Files()\Size = DirectoryEntrySize(0)
        Files()\Attributes = DirectoryEntryAttributes(0)
        Files()\DateCreated = DirectoryEntryDate(0, #PB_Date_Created)
        Files()\DateAccessed = DirectoryEntryDate(0, #PB_Date_Accessed)
        Files()\DateModified = DirectoryEntryDate(0, #PB_Date_Modified)
      EndIf
    Wend
    
    ; Close the directory.
    FinishDirectory(0)
  EndIf
  
  ; Sort the list into ascending alphabetical order of file name.
  SortStructuredList(Files(), #PB_Sort_Ascending, OffsetOf(FILEITEM\Name), #PB_String)
EndProcedure

Procedure.s FolderSelect(Folder.s)
  ; Displays a path requester and returns the new path, or the old one if the requester is cancelled.
  Protected.s SelectedPath
  
  SelectedPath = PathRequester("Choose a folder.", Folder)
  
  If SelectedPath = ""
    SelectedPath = Folder
  EndIf
  
  ProcedureReturn SelectedPath
EndProcedure

Procedure LabelUpdate(Folder.s)
  ; Updates the folder label.
  SetGadgetText(#FolderText, Folder)
EndProcedure

Procedure ListLoad(ListView.l, List Files.FILEITEM())
  ; Load the files properties from list Files() into the list view #FilesList.
  Protected.s Access, Attrib, Create, Folder, Modify, Msg, Num, Size
  
  ; Remove previous contents.
  ClearGadgetItems(ListView)
  
  ForEach Files()
    ; Display the item number and file name.
    Num = StrU(ListIndex(Files()) + 1)
    
    ; These lines convert the three date values to something more familiar.
    Create = FormatDate("%dd/%mm/%yyyy", Files()\DateCreated)
    Access = FormatDate("%dd/%mm/%yyyy", Files()\DateAccessed)
    Modify = FormatDate("%dd/%mm/%yyyy", Files()\DateModified)
    
    ; Convert the file size to a padded string the same as with the index value above,
    ; but allow space for the maximum size of a quad.
    Size = StrU(Files()\Size)
    
    ; Convert the attributes to a string, for now.
    Attrib = StrU(Files()\Attributes)
    
    ; Build a row string.  
    ; The Line Feed character 'Chr(10)' tells the gadget to move to the next column.
    Msg = Num + Chr(10) + Files()\Name + Chr(10) + Create + Chr(10) + Access + Chr(10) + Modify + Chr(10) + Attrib + Chr(10) + Size
    
    ; Add the row to the list view gadget.
    AddGadgetItem(#FilesList, -1, Msg)
  Next Files()
EndProcedure

Procedure SearchFiles(ListView.l, List Files.FILEITEM(), StringToFind.s)
  
  Protected.s Msg
  Protected FileCounter
  ; Remove previous contents.
  ClearGadgetItems(ListView)
  
  ForEach Files()
    f = ReadFile(#PB_Any, Files()\Name)
    If f
      If FindString(ReadString(f, #PB_File_IgnoreEOL), StringToFind, 1, #PB_String_NoCase)
        Msg =  Chr(10) + Files()\Name 
        AddGadgetItem(#FilesList, -1, Msg)
        FileCounter + 1
      EndIf
      CloseFile(f)
    EndIf
  Next Files()
  
  ProcedureReturn FileCounter
EndProcedure

Procedure WindowCreate()
  ; Creates the wdwFiles window.
  Protected Flags
  
  ; This line defines a flag for the window attributes by OR-ing together the desired attribute constants.
  Flags = #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget| #PB_Window_TitleBar
  
  ; Open a window.
  OpenWindow(#WindowFiles, 50, 50, 600, 400, "Search for a word in the content of text files", Flags)
  ; A button to choose a folder.
  ButtonGadget(#FolderButton, 5, 5, 100, 30, "Select Folder")
  ; A button to update the list.
  ButtonGadget(#UpdateButton, 112, 5, 100, 30, "Update List")
  
  ButtonGadget(#SearchButton, 495, 5, 100, 30, "Search")
  TextGadget(#LabelText, 275, 10, 200, 25, "String to Find :")
  StringGadget(#ToFindString, 358, 7, 130, 26, "")
  ; A text gadget to show the name of the folder.
  TextGadget(#FolderText, 5, 40, 400, 25, "")
  ; A list icon gadget to hold the file list and properties.
  ListIconGadget(#FilesList, 5, 70, 400, 326, "#", 35)
  ; Add columns to the ListIconGadget to hold each property.
  AddGadgetColumn(#FilesList, 1, "Name", 200)
  AddGadgetColumn(#FilesList, 2, "Created", 100)
  AddGadgetColumn(#FilesList, 3, "Accessed", 100)
  AddGadgetColumn(#FilesList, 4, "Modified", 100)
  AddGadgetColumn(#FilesList, 5, "Attributes", 150)
  AddGadgetColumn(#FilesList, 6, "Size", 100)
EndProcedure

Procedure WindowDestroy()
  ; Closes the window.
  ; If necessary, you could do other tidying up jobs here too.
  CloseWindow(#WindowFiles)
EndProcedure

Procedure WindowResize()
  ; Resizes window gadgets to match the window size.
  ResizeGadget(#FolderText, #PB_Ignore, #PB_Ignore, WindowWidth(#WindowFiles) - 10, #PB_Ignore)
  ResizeGadget(#FilesList, #PB_Ignore, #PB_Ignore, WindowWidth(#WindowFiles) - 10, WindowHeight(#WindowFiles) - 74)
EndProcedure

;- Main
; Now we define a list of files using the structure previously specified.
NewList Files.FILEITEM()

; And some working variables to make things happen.
Define.s Folder, FindIt
Define.l Event, EventWindow, EventGadget, EventType, EventMenu

;Folder = "C:\ProgramData\PureBasic\Examples\Sources"
;Folder = "C:\Program Files\PureBasic\Examples\Sources"
Folder = "C:\Users\x\Documents\purebasic" ;GetHomeDirectory()

; Create the window and set the initial contents.
WindowCreate()
WindowResize()
LabelUpdate(Folder)
FilesExamine(Folder, Files())
ListLoad(#FilesList, Files())

;- Event Loop
Repeat
  ; Wait until a new window or gadget event occurs.
  Event = WaitWindowEvent()
  EventWindow = EventWindow()
  EventGadget = EventGadget()
  EventType = EventType()
  
  ; Take some action.
  Select Event
    Case #PB_Event_Gadget
      ; A gadget event occurred.
      If EventGadget = #FolderButton
        ; The folder button was clicked.
        Folder = FolderSelect(Folder)
        LabelUpdate(Folder)
        FilesExamine(Folder, Files())
        ListLoad(#FilesList, Files())
        
      ElseIf EventGadget = #UpdateButton
        ; The update button was clicked.
        LabelUpdate(Folder)
        FilesExamine(Folder, Files())
        ListLoad(#FilesList, Files())
        
      ElseIf EventGadget = #FolderText
        ; Do nothing here.
        
      ElseIf EventGadget = #FilesList
        ; Do nothing here.
        
      ElseIf EventGadget = #SearchButton
        FindIt = GetGadgetText(#ToFindString)
        If Len(FindIt) = 0 
          MessageRequester("Warning", "Write something to find in files !")  
        EndIf
        
        LabelUpdate("Found the following " + Str(SearchFiles(#FilesList, Files(), FindIt)) +
                    " files containing **" + FindIt + "** in this folder" )
      EndIf
      
    Case #PB_Event_SizeWindow
      ; The window was moved or resized.
      If EventWindow = #WindowFiles
        WindowResize()  
      EndIf
      
    Case #PB_Event_CloseWindow
      ; The window was closed.
      If EventWindow = #WindowFiles
        WindowDestroy()
        Break
      EndIf
  EndSelect
ForEver

