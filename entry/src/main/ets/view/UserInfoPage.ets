import { ItemGroup } from "../components/ItemGroup"
import { SubItemArrow } from "../components/SubItemArrow"
import { ChangePassword } from "./ChangePassword"
import l from '../../../common/utils/LocalizationManager';
import { PersonalInfoPage } from "./PersonalInfoPage";

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
        NavRouter()
        {
          SubItemArrow({title: l.getLocalized('AbpUi::PersonalInfo')})
          NavDestination() {
            PersonalInfoPage()
          }
          .title(l.getLocalized('AbpUi::PersonalInfo'))
        }
        Divider()
          .strokeWidth('1px')
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({left: 12, right: 8})
        SubItemArrow({title: l.getLocalized('AbpAccount::ProfilePicture')})
        Divider()
          .strokeWidth('1px')
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({left: 12, right: 8})
        NavRouter()
        {
          SubItemArrow({title: l.getLocalized('AbpUi::ChangePassword')})
          NavDestination() {
            ChangePassword()
          }
          .title(l.getLocalized('AbpUi::ChangePassword'))
        }

      }

    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12 })
    .backgroundColor($r('app.color.background'))
  }
}