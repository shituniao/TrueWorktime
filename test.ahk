Config :=Gui()
Config.Title :="工作计时器"
Config.MarginX :=12
Config.MarginY :=15
Config.SetFont("s10","Microsoft YaHei UI")
ExeWork :=Config.AddListView("xm ym r9 vExeWork w300 +List",["名称"])
ImageListID := IL_Create()
ExeWork.SetImageList(ImageListID)

ids := WinGetList() ;获取当前程序列表
ENL_p :=[] ;程序列表去重
;ExeNameList :=[]
hased :=0
for this_id in ids
{
    for this_n in ENL_p{
        if (WinGetProcessName(this_id) =this_n){
            hased:=1
            Break
        }
    }
    if (hased =0){
        ;ExeNameList.Push(StrSplit(WinGetProcessName(this_id),".exe")[1])
        ExeWork.Add(,StrSplit(WinGetProcessName(this_id),".exe")[1])
        IL_Add(ImageListID, WinGetProcessPath(this_id), A_Index) 
    }
    ENL_p.Push(WinGetProcessName(this_id))
    hased :=0
}

Config.Show("AutoSize Center")
