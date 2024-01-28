Archive :=Gui()
Archive.Title :="TrueWorkTime - 归档"
Archive.MarginX :=10
Archive.MarginY :=10
Archive.SetFont("s9","Microsoft YaHei UI")

Archive.AddText("x10 y15","归档名称：")
ArchiveNameItem:=Archive.AddEdit("x+1 yp-3.5 -Multi w328")
ArchiveNameItem.OnEvent("Change",Archive_Rename)

Archive.AddText("x10 y+8 section","选择项目：")
Archive.AddText("x130 ys","项目时长：")
Archive.AddText("x230 ys","开始时间：")

ArchiveChooseItem:=Archive.AddDropDownList("xs y+5 w100")
ArchiveChooseItem.OnEvent("Change",Archive_ChooseItem)
ArchiveTime:=Archive.AddText("x130 yp+4 w400",FormatSeconds(Items[logger.CurrentItem]['time']))
ArchiveStartTime:=Archive.AddText("x230 yp w400",FormatTime(Items[logger.CurrentItem]['start'],"yyyy年M月dd日"))

ArchiveOK:=Archive.AddButton("xs y+10 w390 +Disabled","✔️归档")
ArchiveOK.OnEvent("Click",Archive_OK)

ArchiveComplete:=Archive.AddText("xs y+10 w400",)

Archive_ChooseItem(GuiCtrlObj, Info){
    ArchiveTime.Text:=FormatSeconds(Items[GuiCtrlObj.Value]['time'])
    ArchiveStartTime.Text:=FormatTime(Items[GuiCtrlObj.Value]['start'],"yyyy年M月dd日")
}

Archive_OK(GuiCtrlObj, Info){
    FileAppend "`n" ArchiveNameItem.Text "," Items[ArchiveChooseItem.Value]['start'] "," A_Now "," Items[ArchiveChooseItem.Value]['time'] , "archive.csv"
    ArchiveComplete.Text:="完成！归档时间：" FormatTime(A_Now,"yyyy年M月dd日 HH:mm:ss")
    Archive.Move(,,,205)
    ArchiveRefresh()
}

Archive_Rename(GuiCtrlObj, Info){
    if(ArchiveNameItem.Text=""){
        ArchiveOK.Opt("+Disabled")
    }Else{
        ArchiveOK.Opt("-Disabled")
    }
}
