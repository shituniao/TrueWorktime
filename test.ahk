Config :=Gui()
Config.Title :="工作计时器"
Config.MarginX :=12
Config.MarginY :=15
Config.SetFont("s10","Microsoft YaHei UI")
ExeWork :=Config.AddListView("xm ym r9 vExeWork w300 -Hdr -Multi",["名称"])
ExeWorkIcon := IL_Create()
ExeWork.SetImageList(ExeWorkIcon)
ExeWork.OnEvent("ItemSelect",ExeWork_ItemSelect)
Config.Add("Button", "xm w80 w300", "✔️保存").OnEvent("Click", ClickSAVE)

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
        ExeWork.Add("Icon" IL_Add(ExeWorkIcon, WinGetProcessPath(this_id)) ,StrSplit(WinGetProcessName(this_id),".exe")[1])
        ENL_p.Push(WinGetProcessName(this_id))
    }
    hased :=0
}

ExeWork_ItemSelect(ExeWork, Item, Selected){
    if(Selected){

    }
}
ClickSAVE(thisGui, *){
}

Config.Show("AutoSize Center")
