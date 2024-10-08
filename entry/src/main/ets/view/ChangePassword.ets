import { ItemGroup } from "../components/ItemGroup"
import { SubItemArrow } from "../components/SubItemArrow"
import l from '../../../common/utils/LocalizationManager';
import CommonConstants from "../common/constants/CommonConstants";
import PromptUtil from "../../../common/utils/PromptUtil";
import { changePassword } from '../../../../src/common/api/Account';
import Logger from "../common/utils/Logger";

@Extend(TextInput)
function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .height($r('app.float.login_input_height'))
  .fontSize($r('app.float.big_text_size'))
  .backgroundColor(Color.White)
  .width(CommonConstants.FULL_PARENT)
  .padding({ left: CommonConstants.INPUT_PADDING_LEFT })
  .margin({ top: $r('app.float.input_margin_top') })
}

@Extend(Line)
function lineStyle() {
  .width(CommonConstants.FULL_PARENT)
  .height($r('app.float.line_height'))
  .backgroundColor($r('app.color.line_color'))
}


@Component
export struct ChangePassword {

  @State currentPassword: string = '';
  @State newPassword: string = '';
  @State newPasswordConfirm: string = '';
  @State isInvalid: boolean = false;
  @Builder
  CustomDivider() {
    Divider()
      .strokeWidth('1px')
      .color($r('sys.color.ohos_id_color_list_separator'))
      .margin({ left: 12, right: 8 })
  }

  isInvalidControl(){
    this.isInvalid = false;
    if (this.currentPassword.length > 0 && this.newPassword.length > 0 && this.newPasswordConfirm.length > 0) {
      this.isInvalid = true;
    }
  }

  async changePassword()
  {
    if (this.currentPassword === '' || this.newPassword === ''|| this.newPasswordConfirm === '') {
      PromptUtil.promptMessage($r('app.string.input_empty_tips'), CommonConstants.PROMPT_DURATION);
      return;
    }
    if (this.newPassword !== this.newPasswordConfirm) {
      PromptUtil.promptMessage(l.getLocalized('AbpIdentity::Volo.Abp.Identity:PasswordConfirmationFailed'), CommonConstants.PROMPT_DURATION);
      return;
    }
    try {
      const response = await changePassword({
        currentPassword: this.currentPassword,
        newPassword: this.newPasswordConfirm
      });
      this.currentPassword='';
      this.newPassword = '';
      this.newPasswordConfirm = ''
      this.isInvalid=false;
      PromptUtil.promptMessage(l.getLocalized('AbpIdentity::DisplayName:NewPasswordConfirm'), 5000);
    } catch (error) {
      Logger.info('changePassword_error' + error)

    }
  }



  build() {
    Column() {
      Blank().height(5)
      Column()
      {
        TextInput({ text:this.currentPassword,placeholder: l.getLocalized('AbpIdentity::DisplayName:CurrentPassword') })
          .type(InputType.Password)
          .inputStyle()
          .onChange((value: string) => {
            this.currentPassword = value;
            this.isInvalidControl();
          })

        Line().lineStyle()

        TextInput({ text:this.newPassword,placeholder: l.getLocalized('AbpIdentity::DisplayName:NewPassword') })
          .type(InputType.Password)
          .inputStyle()
          .onChange((value: string) => {
            this.newPassword = value;
            this.isInvalidControl();
          })

        Line().lineStyle()

        TextInput({ text:this.newPasswordConfirm,placeholder: l.getLocalized('AbpIdentity::DisplayName:NewPasswordConfirm') })
          .type(InputType.Password)
          .inputStyle()
          .onChange((value: string) => {
            this.newPasswordConfirm = value;
            this.isInvalidControl();
          })
      }
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.input_border_radius'))
      .padding({
        top: $r('app.float.input_padding_top'),
        bottom: $r('app.float.input_padding_top'),
        left: $r('app.float.input_padding_left'),
        right: $r('app.float.input_padding_left')
      })
      Button(l.getLocalized('MyProjectName::Submit'), { type: ButtonType.Capsule })
        .width(CommonConstants.BUTTON_WIDTH)
        .height($r('app.float.login_button_height'))
        .fontSize($r('app.float.normal_text_size'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor(true ? $r('app.color.login_button_color') : $r('app.color.button_color_unavailable'))
        .margin({
          top: '20vp',
          bottom: $r('app.float.button_bottom')
        })
        .enabled(this.isInvalid)
        .onClick(() => {
          this.changePassword();
        })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12 })
    .backgroundColor($r('app.color.background'))
  }
}