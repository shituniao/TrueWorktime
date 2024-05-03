;计时器悬浮窗
ClockGui := Gui()
ClockGui.Opt("+AlwaysOnTop -Caption +ToolWindow +DPIScale Disabled" ) ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
ClockGui.MarginY:=4
ClockGui.BackColor := Theme[logger.background] ; 初始白色背景(下面会变成半透明的).
ClockGui.SetFont("s12","Microsoft YaHei UI") 
;WinSetTransColor(" 0", ClockGui) ; 半透明:
ClockGui.Show("NoActivate") ; NoActivate 让当前活动窗口继续保持活动状态.
ClockGui.Move(logger.x,logger.y,logger.w,logger.h)
ClockText := ClockGui.Add("Text", "x0 ym r1 w" logger.w " c" Theme[logger.color] " Center", "准备") 

;累计计时器悬浮窗
ItemGui := Gui()
ItemGui.Opt("+AlwaysOnTop -Caption +ToolWindow +DPIScale" )
ItemGui.MarginY:=4
ItemGui.BackColor := Theme["gray"] ;红f92f60/ffd8d9黄ffc700/7d4533蓝1c5cd7/aeddff绿008463/c6fbe7
ItemGui.SetFont("s12","Microsoft YaHei UI") 
ItemText :=ItemGui.Add("Text","x0 ym r1 w" logger.w " c" Theme['black'] " Center", FormatSeconds(0))
if(logger.itemShow){
    ItemGui.Show("NoActivate")
}
ItemGui.Move(logger.x-logger.w,logger.y,logger.w,logger.h)