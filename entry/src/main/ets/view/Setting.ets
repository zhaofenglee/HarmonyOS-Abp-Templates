/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import CommonConstants from '../common/constants/CommonConstants'
import ItemData from '../model/ItemDataModel'
import mainViewModel from '../viewmodel/MainViewModel'
import { router } from '@kit.ArkUI'
import { logout,UserInfo } from '../../../../src/common/api/Account';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';
import { RegisterPage } from './RegisterPage';
import { UserInfoPage } from './UserInfoPage';
import l from '../../../common/utils/LocalizationManager';
import applicationConfigurationManager, {Language}  from '../../../common/utils/ApplicationConfigurationManager';


/**
 * Setting tab content
 */
@Component
export default struct Setting {
  private userInfo = AppStorage.get('userInfo') as UserInfo;
  @State languages:Language[]=[]

  async aboutToAppear() {
    this.languages = applicationConfigurationManager.getLanguages();
  }
  @Builder settingCell(item: ItemData) {
    Row() {
      Row({ space: CommonConstants.COMMON_SPACE }) {
        Image(item.img)
          .width($r('app.float.setting_size'))
          .height($r('app.float.setting_size'))
        Text(item.title)
          .fontSize($r('app.float.normal_text_size'))
      }
      Image($r('app.media.ic_right_grey'))
        .width($r('app.float.setting_jump_width'))
        .height($r('app.float.setting_jump_height'))
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(CommonConstants.FULL_PARENT)
    .padding({
      left: $r('app.float.setting_cell_left'),
      right: $r('app.float.setting_cell_right')
    })
  }

  build() {
    Scroll() {
      Column({ space: CommonConstants.COMMON_SPACE }) {
        NavRouter()
        {
          Row() {
            Row() {
              Image($r('app.media.ic_account'))
                .borderRadius('20.00vp')
                .height(40)
                .width('40.00vp')
                .margin({ top: '0.00vp', right: '5.00vp', bottom: '0.00vp', left: '20.00vp' })

              Column() {
                Text(this.userInfo?.preferred_username)
                  .fontSize($r('app.float.setting_account_fontSize'))
                Text(this.userInfo?.email)
                  .fontSize($r('app.float.little_text_size'))
                  .margin({ top: $r('app.float.setting_name_margin')})
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: $r('app.float.setting_account_margin')})
            }

            Image($r('app.media.ic_public_arrow_right'))
              .fillColor($r('sys.color.ohos_id_color_foreground'))
              .opacity(0.2)
              .width(12)
              .height(24)
          }
          .width('100%')
          .height(80)
          .padding({ left: 8, right: 12 })
          .margin({ top: 16 })
          .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
          .justifyContent(FlexAlign.SpaceBetween)
          .borderRadius(20)
          .id('dearUserRow')

          NavDestination() {
            UserInfoPage()
          }
          .title('我的账户')

        }
        List() {
          ForEach(mainViewModel.getSettingListData(), (item: ItemData) => {
            ListItem() {
              this.settingCell(item)
            }
            .height($r('app.float.setting_list_height'))
            .onClick(() => {
              // 根据 item.id 导航到指定的页面
              navigateToPage(item.id)
            })
          }, (item: ItemData, index: number) => index + JSON.stringify(item))
          ListItem() {
            Row() {
              Row({ space: CommonConstants.COMMON_SPACE }) {
                Image($r('app.media.world_clock'))
                  .width($r('app.float.setting_size'))
                  .height($r('app.float.setting_size'))
                Text(l.getLocalized('MyProjectName::Language'))
                  .fontSize($r('app.float.normal_text_size'))
              }
              Image($r('app.media.ic_right_grey'))
                .width($r('app.float.setting_jump_width'))
                .height($r('app.float.setting_jump_height'))
            }
            .bindMenu(
              this.languages.map((language): MenuItem => ({
                value: l.getLocalized(language.displayName),
                action: async () => {
                  // 在此编写对应的操作
                  await AppStorage.setOrCreate('User_Language', language.cultureName)
                  await l.init();
                  //切换到首页
                  await router.replaceUrl({
                    url: 'pages/MainPage'
                  });
                }
              })),
            )
            .justifyContent(FlexAlign.SpaceBetween)
            .width(CommonConstants.FULL_PARENT)
            .padding({
              left: $r('app.float.setting_cell_left'),
              right: $r('app.float.setting_cell_right')
            })
          }
          .height($r('app.float.setting_list_height'))
        }
        .width(CommonConstants.FULL_PARENT)
        .height('380vp')
        .backgroundColor(Color.White)
        .divider({
          strokeWidth: $r('app.float.setting_list_width'),
          color: Color.Grey,
          startMargin: $r('app.float.setting_list_margin'),
          endMargin: $r('app.float.list_end_margin')
        })
        .borderRadius($r('app.float.setting_list_radius'))
        .padding({
          top: $r('app.float.setting_list_padding'),
          bottom: $r('app.float.setting_list_padding')
        })

        Blank()

        Button($r('app.string.setting_button'), { type: ButtonType.Capsule })
          .width(CommonConstants.BUTTON_WIDTH)
          .height($r('app.float.login_button_height'))
          .fontSize($r('app.float.normal_text_size'))
          .fontColor($r('app.color.setting_button_font'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('app.color.setting_button_background'))
          .margin({ bottom: $r('app.float.setting_button_bottom')})
          .onClick(async () => {
            await logout()
            router.replaceUrl({
              url: CommonConstants.ROUTER_LOGIN_URL
            })
          })
      }
      .height(CommonConstants.FULL_PARENT)
    }
  }
}

// 导航函数示例
function navigateToPage(id: string) {
  console.log('navigateToPage',id);
  switch(id) {
    case 'page1':
      // 导航到页面1
      break;
    case 'page2':
      // 导航到页面2
      break;
    // 添加更多页面导航
    default:
      // 默认导航
      break;
  }
}

interface MenuItem {
  value: string;
  action: () => void;
}