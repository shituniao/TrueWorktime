;定义托盘菜单
A_TrayMenu.Rename("E&xit","退出")
A_TrayMenu.Delete("&Suspend Hotkeys")
A_TrayMenu.Delete("&Pause Script")

A_TrayMenu.Insert("1&", "功能设置", MenuHandler)
A_TrayMenu.Insert("2&", "工作软件", MenuHandler)
A_TrayMenu.Insert("3&", "每日记录", MenuHandler)
A_TrayMenu.Insert("4&", "项目记录", MenuHandler)
A_TrayMenu.Insert("5&")
A_TrayMenu.Default:=IniRead("Config.ini","setting","trayicon") "&"
A_TrayMenu.ClickCount:=1

;用到的各种托盘功能函数
MenuHandler(ItemName, ItemPos, MyMenu) {
    ShowConfig(ItemPos)
}
;显示主界面
ShowConfig(tab){
    Config.Show("Center")
    ConfigTab.Choose(tab)
    Config_Resize(tab)
}

