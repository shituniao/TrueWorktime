Try{
    FileDelete "logNEW.csv"
}

FileAppend "start,worktime,alltime,ratio" , "logNEW.csv"
Loop read,"log.csv"{
    if(A_Index>1){
        FileAppend "`n", "logNEW.csv"
        Loop Parse,A_LoopReadLine,"CSV"{
            switch A_Index{
            case 1:
                if(InStr(A_LoopField,":")){
                    ;OutputDebug("___:")
                    FileAppend YYDD(A_LoopField), "logNEW.csv"
                    ;OutputDebug(YYDD(A_LoopField))
                }Else{
                    FileAppend A_LoopField, "logNEW.csv"
                }
            Default:
                if(InStr(A_LoopField,":")){
                    ;OutputDebug("___:")
                    FileAppend "," YYDD(A_LoopField), "logNEW.csv"
                    ;OutputDebug(YYDD(A_LoopField))
                }Else{
                    FileAppend "," A_LoopField, "logNEW.csv"
                }

            }
        }
    }
}
YYDD(a){
    aa:=StrSplit(a,":")
    b:=0
    Loop aa.Length{
        switch A_Index{
        case 1:
            b+=aa[1]*3600
        case 2:
            b+=aa[2]*60
        case 3:
            b+=aa[3]
        }
    }
    Return b
}
FileCopy "log.csv","logOLD.csv",1
FileCopy "logNEW.csv","log.csv",1