# TrueWorktime
## 说明

### 工作计时器是一个帮助用户记录工作时长和空闲时长的程序。

---

## 基本原理
### 程序每秒检测当前正在使用的软件是否是预先设定的工作软件，以及用户是否在30秒内有鼠标操作或键盘输入。    
     
1. 若当前软件是工作软件，且电脑在30秒内有键鼠操作，则会记录为工作时间，显示为黑底白字。  
   ![pic](https://gd-hbimg.huaban.com/17c195cb35592709755e627cec7f8e747ea3ccfd254d-YRz54V)
2. 若当前软件不是工作软件，或超过30秒没有操作，则会记录为空闲时间，显示为白底黑字。  
   ![pic](https://gd-hbimg.huaban.com/28589e0e034902c6990dd3f6fc1221175b9bf5f83325-N982Cn)
3. 提供久坐提醒功能，当用户维持键鼠操作超过30分钟时，程序会显示红色久坐提示（这个功能可以关闭）  
   ![pic](https://gd-hbimg.huaban.com/333b04cdb1d33e53d236d56f70440c655d124c871596-GcVxU1)
4. 软件可以通过托盘菜单设置工作软件  
   ![pic](https://gd-hbimg.huaban.com/67c5b53251b72c7b8ed5970fc336cc5296a1314c4fc5-9benJV)
   


### 本程序基于AutoHotkey 2.0.2编写  
### 由shituniao制作



