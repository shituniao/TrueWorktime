bannerWidth :=100
xPosition := A_ScreenWidth - bannerWidth - 137

logger := StateLog() ;定义计时器对象

MyGui := Gui()
MyGui.Opt("+AlwaysOnTop -Caption +ToolWindow" ) ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
MyGui.BackColor := "ffffff" ; 可以是任何 RGB 颜色(下面会变成透明的).
MyGui.SetFont("s12","Microsoft YaHei UI") ; 设置大字体(32 磅).
CoordText := MyGui.Add("Text", "x0 y4 h30 w" bannerWidth " c000000 Center", "预备") 
WinSetTransColor(" 200", MyGui) ; 半透明:
WinSetExStyle("+0x20", MyGui) ;鼠标穿透
MyGui.Show("x" xPosition " y0 h30 w" bannerWidth " NoActivate") ; NoActivate 让当前活动窗口继续保持活动状态.

logger.Start ;启动计时

class StateLog {
    __New(){
        this.WorkTime :=0
        this.BreakTime :=0
        this.WorkIn :=0
        this.check :=ObjBindMethod(this, "StateCheck")
    }
    Start() {
        SetTimer this.check, 1000
    }
    StateCheck() {
        if(WinActive("ahk_exe TIM.exe") and A_TimeIdlePhysical<5000){
            this.WorkTime++
            if !(this.WorkIn = 1){
                this.WorkIn :=1
                MyGui.BackColor := "000000"
                CoordText.SetFont("cffffff")
            }
            CoordText.Value := FormatSeconds(this.WorkTime)
        }else{
            this.BreakTime++
            if !(this.WorkIn = 0){
                this.WorkIn :=0
                MyGui.BackColor := "ffffff"
                CoordText.SetFont("c000000")
            }
            CoordText.Value := FormatSeconds(this.BreakTime)
        }
    }
}

FormatSeconds(NumberOfSeconds) ; 把指定的秒数转换成 hh:mm:ss 格式.
{
    time := 19990101 ; 任意日期的 *午夜*.
    time := DateAdd(time, NumberOfSeconds, "Seconds")
    return FormatTime(time, "HH:mm:ss")
    /*
    ; 和上面方法不同的是, 这里不支持超过 24 小时的秒数:
    return FormatTime(time, "h:mm:ss")
    */
}
;ahk_exe TIM.exe