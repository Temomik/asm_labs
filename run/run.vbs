Set oShell = CreateObject ("Wscript.Shell") 
Dim strArgs
strArgs = "cmd /c run-com-e.bat"
oShell.Run strArgs, 0, false