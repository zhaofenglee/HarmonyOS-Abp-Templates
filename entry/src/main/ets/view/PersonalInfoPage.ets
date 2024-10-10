import { ItemGroup } from "../components/ItemGroup"
import { SubItemArrow } from "../components/SubItemArrow"
import l from '../../../common/utils/LocalizationManager';
import CommonConstants from "../common/constants/CommonConstants";
import PromptUtil from "../../../common/utils/PromptUtil";
import { changePassword,getProfile,updateProfile } from '../../../../src/common/api/Account';
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
@Extend(Text)
function style(TextAlign: TextAlign) {
  .textAlign(TextAlign)
  .fontSize($r('app.float.big_text_size'))
    .width('100%')
}

@Component
export struct PersonalInfoPage {

  @State userName: string = '';
  @State email: string = '';
  @State name: string = '';
  @State surname: string|null = null;
  @State phoneNumber: string|null = null;
  @State concurrencyStamp: string|null = null;
  @State isInvalid: boolean = false;
  @Builder
  CustomDivider() {
    Divider()
      .strokeWidth('1px')
      .color($r('sys.color.ohos_id_color_list_separator'))
      .margin({ left: 12, right: 8 })
  }

  async aboutToAppear() {
    const myProfile = await getProfile();
    if (myProfile) {
      this.userName = myProfile?.userName??'';
      this.email = myProfile?.email;
      this.name = myProfile?.name;
      this.surname = myProfile?.surname;
      this.phoneNumber = myProfile?.phoneNumber;
      this.concurrencyStamp = myProfile?.concurrencyStamp;
    }
  }


  isInvalidControl(){
    this.isInvalid = false;
    if (this.userName.length > 0 && this.email.length > 0) {
      this.isInvalid = true;
    }
  }

  async updateProfile()
  {
    if (this.userName === '' || this.email === '') {
      PromptUtil.promptMessage($r('app.string.input_empty_tips'), CommonConstants.PROMPT_DURATION);
      return;
    }
    try {
      const response = await updateProfile({
        userName: this.userName,
        email: this.email,
        name:this.name,
        surname:this.surname,
        phoneNumber:this.phoneNumber,
        concurrencyStamp:this.concurrencyStamp,
      });
      this.concurrencyStamp = response?.concurrencyStamp??null;
      PromptUtil.promptMessage(l.getLocalized('AbpAccount::SavedSuccessfully'), 5000);
    } catch (error) {
      Logger.info('updateProfile_error' + error)
    }
  }



  build() {
    Column() {
      Blank().height(5)
      Column()
      {
        Text(l.getLocalized('AbpAccount::DisplayName:UserName')+' *')
          .style(TextAlign.Start)
        TextInput({ text:this.userName })
          .inputStyle()
          .onChange((value: string) => {
            this.userName = value;
            this.isInvalidControl();
          })

        Line().lineStyle()
        Text(l.getLocalized('AbpAccount::DisplayName:Name'))
          .style(TextAlign.Start)
        TextInput({ text:this.name })
          .inputStyle()
          .onChange((value: string) => {
            this.name = value;
            this.isInvalidControl();
          })

        Line().lineStyle()
        Text(l.getLocalized('AbpAccount::DisplayName:Surname'))
          .style(TextAlign.Start)
        TextInput({ text:this.surname })
          .inputStyle()
          .onChange((value: string) => {
            this.surname = value;
            this.isInvalidControl();
          })

        Line().lineStyle()
        Text(l.getLocalized('AbpAccount::DisplayName:Email')+' *')
          .style(TextAlign.Start)
        TextInput({ text:this.email })
          .inputStyle()
          .onChange((value: string) => {
            this.email = value;
            this.isInvalidControl();
          })

        Line().lineStyle()

        Text(l.getLocalized('AbpAccount::DisplayName:PhoneNumber'))
          .style(TextAlign.Start)
        TextInput({ text:this.phoneNumber })
          .inputStyle()
          .onChange((value: string) => {
            this.phoneNumber = value;
            this.isInvalidControl();
          })
      }
      .backgroundColor(Color.White)
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
          this.updateProfile();
        })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12 })
    .backgroundColor($r('app.color.background'))
  }
}