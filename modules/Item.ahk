
class item {
    __New(name:="",start:=A_Now,last:=A_Now,duration:=0){
        this.name:=name
        this.start:=start
        this.last:=last
        this.duration:=duration
    }
}

;检查Item窗口名
CheckItem(currentWindow){
    newOne:=True
    for i in logger.itemList{
        if(i.name==currentWindow){
            newOne:=False
            theOne:=i
            Break
        }
    }
    if(newOne){
        theOne:=item(currentWindow,A_Now,A_Now)
        logger.itemList.InsertAt(1, theOne)
        OutputDebug("加入新item，名为" theOne.name "时间：" theOne.duration)
    }Else{
        theOne.last:=A_Now
        theOne.duration++
        OutputDebug("已有窗口，名为" theOne.name "时间：" theOne.duration)
    }
    logger.currentItem:=theOne
}

;更新项目记录文件
UpdateItems(){
    File_items:=FileOpen("data/items.csv", "w")
    for i in logger.itemList{
        File_items.Write(i.name "," i.start "," i.last "," i.duration "`n")
    }
}

;读取Item文件到logger.itemList
ReadItems(){
    readItem:=[]
    Loop Read,"data/items.csv"{
        readItem:=StrSplit(A_LoopReadLine, ",")
        logger.itemList.Push(item(readItem[1],readItem[2],readItem[3],readItem[4]))
    }
    for i in logger.itemList{
        OutputDebug("----------程序列表" i.name)
    }
}

;对item文件是否过期的筛选
FilterItems(){
    filterItem:=[]
    News:=[]
    Olds:=[]
    Loop Read,"data/items.csv"{
        filterItem:=StrSplit(A_LoopReadLine, ",")
        if(DateDiff(A_Now,filterItem[3],"days")<15){
            News.Push(filterItem[1] "," filterItem[2] "," filterItem[3] "," filterItem[4])
        }Else{
            Olds.Push(filterItem[1] "," filterItem[2] "," filterItem[3] "," filterItem[4])
            OutputDebug(filterItem[1] "已过期")
        }

    }
    File_items:=FileOpen("data/items.csv", "w")
    File_itemsOld:=FileOpen("data/itemsOld.csv", "a")
    for n in News{
        File_items.Write(n "`n")
    }
    for o in Olds{
        File_itemsOld.Write(o "`n")
    }
    File_items.Close()
    File_itemsOld.Close()
}
