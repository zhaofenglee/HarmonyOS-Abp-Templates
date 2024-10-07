## 说明文档
ABP platform provide basic HormonyOS startup template.

## 如何使用
### 1.配置和运行后端
entry/src/common/config/environment.ets


### 已实现功能
#### 1.登录&退出
![img.png](/docs/img.png)

#### 2.本地化对接abp框架
```
import localizationManager from '../../../common/utils/LocalizationManager';
//在你的项目任意位置
localizationManager.getLocalized('MyProjectName::Login')
```
注：预览器启动不加载EntryAbility会导致加载本地化资源异常

#### 3.语言切换
![img3.png](/docs/img3.png)

### 待实现功能
#### 1.修改用户图像
#### 2.修改用户密码


### 参考资料
#### 登录界面
https://gitee.com/harmonyos_samples/UserAuth