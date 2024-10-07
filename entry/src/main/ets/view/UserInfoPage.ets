import { ItemGroup } from "../components/ItemGroup"
import { SubItemArrow } from "../components/SubItemArrow"

@Component
export struct UserInfoPage {
  @Builder
  CustomDivider() {
    Divider()
      .strokeWidth('1px')
      .color($r('sys.color.ohos_id_color_list_separator'))
      .margin({ left: 12, right: 8 })
  }

  build() {
    Column() {
      Blank().height(5)
      ItemGroup() {
        SubItemArrow({title: '个人信息'})
        Divider()
          .strokeWidth('1px')
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({left: 12, right: 8})
        SubItemArrow({title: '更改头像'})
        Divider()
          .strokeWidth('1px')
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({left: 12, right: 8})
        SubItemArrow({title: '修改密码'})
      }

      Column() {


        Row().height(16)


      }
      .margin({ bottom: 19.5 })
      .flexShrink(0)

      Scroll() {

      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .flexShrink(1)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12 })
  }
}