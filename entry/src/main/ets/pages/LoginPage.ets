/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import CommonConstants from '../common/constants/CommonConstants';
import { router, window } from '@kit.ArkUI';
import PreferenceModel from '../model/PreferenceModel';
import PromptUtil from '../../../common/utils/PromptUtil';
import UserAuthModel from '../model/UserAuthModel';
import Logger from '../common/utils/Logger';
import { login,mockLogin } from '../../../../src/common/api/Account';
import localizationManager from '../../../common/utils/LocalizationManager';
import applicationConfigurationManager from '../../../common/utils/ApplicationConfigurationManager';
import deviceInfo from '@ohos.deviceInfo'
import abp from '../../../common/store/Abp';

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
function blueTextStyle() {
  .fontColor($r('app.color.login_blue_color'))
  .fontSize($r('app.float.small_text_size'))
  .fontWeight(FontWeight.Medium)
}

/**
 * Login Page.
 */
@Entry
@Component
struct LoginPage {
  @State account: string = '';
  @State password: string = '';
  @Provide('isFace') isFace: boolean = false;
  @Provide('isFingerprint') isFingerprint: boolean = false;
  @State isLogin: boolean = false;
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink('userLogin') userLogin: boolean = false;
  private keyAlias: string = CommonConstants.LOGIN_KEYS;

  async aboutToAppear()
  {
    //如果为空表示预览器，emulator代表模拟器
    if (deviceInfo.productModel==="") {
      await localizationManager.init();
      await applicationConfigurationManager.init();
    }

  }

  async onPageShow() {
    window.getLastWindow(getContext(this)).then((windowStage: window.Window) => {
      windowStage.setWindowPrivacyMode(true);
    });
    const token:string|undefined  =  AppStorage.get('access_token');
    if (token){
      await applicationConfigurationManager.init();
      if (abp.currentUser.isAuthenticated)
      {
        this.userLogin = true;
        router.replaceUrl({
          url: 'pages/MainPage'
        });
      }

    }
    this.isFace = PreferenceModel.getPreference(CommonConstants.IS_SHOW_FACE, false) as boolean;
    this.isFingerprint = PreferenceModel.getPreference(CommonConstants.IS_SHOW_FINGERPRINT, false) as boolean;
  }

  onPageHide(): void {
    window.getLastWindow(getContext(this)).then((windowStage: window.Window) => {
      windowStage.setWindowPrivacyMode(false);
    });
  }

  @Builder
  PagesMap(name: string) {
    if (name === 'register') {
      //RegisterPage()
    }
  }

  /**
   * Check whether the login button can be clicked
   */
  isLoginAvailable() {
    this.isLogin = false;
    if (this.account.length > 0 && this.password.length > 0) {
      this.isLogin = true;
    }
  }

  /**
   * Process the login process
   */
  async login() {
    if (this.account === '' || this.password === '') {
      PromptUtil.promptMessage($r('app.string.input_empty_tips'), CommonConstants.PROMPT_DURATION);
      return;
    }
    console.log('login start');
    Logger.info('account' + this.account)
    Logger.info('password' + this.password)
    try {
      //TODO：需要把模拟登录切换成login
      const response = await login({
        username: this.account,
        password: this.password
      });
      Logger.info('access_token:' + response.access_token)
      if (response.access_token) {
        this.userLogin = true;
        await applicationConfigurationManager.init();
        router.replaceUrl({
          url: 'pages/MainPage'
        });
      }
    } catch (error) {
      Logger.info('login_error' + error.message)
      PromptUtil.promptMessage($r('app.string.message_login_prompt'), CommonConstants.PROMPT_DURATION);
    }
  }

  /**
   * Operations After a User Is Successfully Authenticated.
   *
   * @param Whether the user authentication is successful.
   */
  userAuthResult: (isSuccess: boolean) => void = (isSuccess: boolean) => {
    if (isSuccess) {
      this.userLogin = true;
      router.replaceUrl({
        url: 'pages/MainPage'
      });
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Image($r('app.media.ic_logo'))
          .width($r('app.float.logo_image_size'))
          .height($r('app.float.logo_image_size'))
          .margin({
            top: $r('app.float.logo_margin_top'),
            bottom: $r('app.float.logo_margin_bottom')
          })
        Text($r('app.string.login_page'))
          .fontSize($r('app.float.title_text_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.title_text_color'))
        Text($r('app.string.login_more'))
          .fontSize($r('app.float.normal_text_size'))
          .fontColor($r('app.color.login_text_color'))
          .margin({
            bottom: $r('app.float.login_bottom'),
            top: $r('app.float.login_top')
          })

        Column() {
          TextInput({ placeholder: $r('app.string.account') })
            .maxLength(CommonConstants.INPUT_ACCOUNT_LENGTH)
            .type(InputType.USER_NAME)
            .inputStyle()
            .onChange((value: string) => {
              this.account = value;
              this.isLoginAvailable();
            })

          Line().lineStyle()

          TextInput({ placeholder: $r('app.string.password') })
            .maxLength(CommonConstants.INPUT_PASSWORD_LENGTH)
            .type(InputType.Password)
            .inputStyle()
            .onChange((value: string) => {
              this.password = value;
              this.isLoginAvailable();
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

        Row() {
          Text($r('app.string.message_login')).blueTextStyle()
          Text($r('app.string.forgot_password')).blueTextStyle()
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(CommonConstants.FULL_PARENT)
        .padding({
          top: $r('app.float.forgot_margin_top'),
          left: $r('app.float.forgot_margin_left'),
          right: $r('app.float.forgot_margin_right')
        })
        //Text(localizationManager.getLocalized('LeptonX::Login'))

        Button($r('app.string.login'), { type: ButtonType.Capsule })
          .width(CommonConstants.BUTTON_WIDTH)
          .height($r('app.float.login_button_height'))
          .fontSize($r('app.float.normal_text_size'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.isLogin ? $r('app.color.login_button_color') : $r('app.color.button_color_unavailable'))
          .margin({
            top: $r('app.float.button_top'),
            bottom: $r('app.float.button_bottom')
          })
          .enabled(this.isLogin)
          .onClick(() => {
            this.login();
          })
        if (false)
        {
          Text($r('app.string.register_account'))
            .fontColor($r('app.color.login_blue_color'))
            .fontSize($r('app.float.normal_text_size'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.pageInfos.pushPathByName('register', null);
            })
        }


        Blank()

        if (this.isFace || this.isFingerprint) {
          Text($r('app.string.other_login_method'))
            .fontColor($r('app.color.other_login_color'))
            .fontSize($r('app.float.little_text_size'))
            .fontWeight(FontWeight.Medium)
            .margin({
              top: $r('app.float.other_margin_top'),
              bottom: $r('app.float.other_margin_bottom')
            })
          Row({ space: CommonConstants.LOGIN_METHODS_SPACE }) {
            if (this.isFace) {
              Button({ type: ButtonType.Circle, stateEffect: true }) {
                Image($r('app.media.face'))
              }
              .height($r('app.float.other_image_size'))
              .width($r('app.float.other_image_size'))
              .backgroundColor($r('app.color.background'))
              .onClick(() => {
                UserAuthModel.getFaceAuth(this.userAuthResult);
                UserAuthModel.start();
              })
            }

            if (this.isFingerprint) {
              Button({ type: ButtonType.Circle, stateEffect: true }) {
                Image($r('app.media.touchid'))
              }
              .height($r('app.float.other_image_size'))
              .width($r('app.float.other_image_size'))
              .backgroundColor($r('app.color.background'))
              .onClick(() => {
                UserAuthModel.getFingerprintAuth(this.userAuthResult);
                UserAuthModel.start();
              })
            }
          }
        }
      }
      .backgroundColor($r('app.color.background'))
      .height(CommonConstants.FULL_PARENT)
      .width(CommonConstants.FULL_PARENT)
      .padding({
        left: $r('app.float.page_padding_hor'),
        right: $r('app.float.page_padding_hor'),
        bottom: $r('app.float.login_page_bottom')
      })
    }
    .navDestination(this.PagesMap)
    .hideTitleBar(true)
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.background'))
  }
}