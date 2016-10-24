# rx-sample-code

## Demo 列表

### [Stopwatch](http://7xokf3.com1.z0.glb.clouddn.com/Stopwatch.mov)

仿 Apple 计时器逻辑，使用了 MVVM 和状态机，代码仅 200 行。

### [PDF-Expert-Contents](http://7xokf3.com1.z0.glb.clouddn.com/pdf-epert-demo-mute.mov)

仿 PDF Expert 目录展开逻辑，支持无限层级展开。

### [Expandable](http://7xokf3.com1.z0.glb.clouddn.com/expanded-sample.mov)

对 [如何在 iOS 中实现一个可展开的 Table View](http://swift.gg/2015/12/03/expandable-table-view/) 一文的 Demo ，用 Rx 重写。

### RxDataSourcesExample

RxDataSources 基本使用例子。

### SelectCell

更新 Cell 选择状态例子，如选择联系人（单选/多选）。

> 这是一种单选的方案，另外一种可以参见 TwoWayBind 中的 SelectPayment ，根据具体情况选择使用哪种方案。个人推荐本例中的选择联系人方案。

### TwoWayBind

内含：

- 加减购物车
- 选择支付方式
- 更改带组分类的推送设置

## 如何运行

项目依赖使用 Carthage 管理。

参考命令：

```
carthage update --verbose --platform ios --color auto --no-use-binaries
```

> 期待其他 Demo 或者对代码有什么疑问或者建议，欢迎提 issue ，我会尽快回复。

## License

MIT
