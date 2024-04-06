# Asteroids

## 项目说明

基于Lua和live2D实现的在宇宙间控制飞船攻击小行星的射击类游戏，在这款小游戏中，你可以控制一艘宇宙飞船，在行星中穿行并击破它们，每个大行星被击破会分裂成两个小行星，如果击破当前level的所有行星，即可解锁下一level，玩家生命数为3，会自动储存每次的最高分数。向着星辰大海前进吧！

## 技术框架

基于Lua和Love2D实现，使用包管理器luarocks和序列化工具lunajson辅助实现

## 如何使用

1. 下载love2D，链接为[LOVE (love2d.org)](https://www.love2d.org/wiki/Main_Page)，解压缩并配置环境变量即可
2. 获取code，在对应目录下终端输入` love .`即可运行本项目

## 项目结构

```
----components 工具组件
	|--Button.lua按钮组件
	|--Judge.lua判断组件
	|--SFX.lua音乐组件
	|--Text.lua文本组件
----objects 对象
	|--asteroids行星类
	|--Laser子弹类
	|--Player玩家类
----src 资源
	|--data数据
		|--save.json保存的数据
	|--sounds音乐
----states 游戏状态
	|--Game.lua 游玩状态
	|--Menu.lua菜单状态
----conf.lua 配置文件
----globals.lua 全局变量和函数
----main.lua 主程序
```

## 实现技术

音乐播放、游戏数据存储、碰撞检测、模拟太空中移动、射击子弹、玩家生命值、边界判断、文本淡入淡出、爆炸效果、无敌闪烁、火焰拖尾、一些工具类等

## 图片展示

![image](image\pic1.png)

![image](image\pic2.png)

![image](image\pic3.png)