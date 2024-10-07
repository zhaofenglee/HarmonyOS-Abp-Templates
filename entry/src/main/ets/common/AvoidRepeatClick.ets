/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';

const domainId: number = 0x0000;
const logTag: string = 'AvoidRepeatClick';
// Set the interval for repeated taps to 1 second.
const CLICK_INTERVAL: number = 1000;

export class AvoidRepeatClick {
  static lastClickTime: number = 0; // Record the time of the last repeated tap.
  public static avoidRepeatClick(callback: VoidCallback) {
    const currentTime = Date.now();
    if (Math.abs(currentTime - AvoidRepeatClick.lastClickTime) > CLICK_INTERVAL) {
      AvoidRepeatClick.lastClickTime = currentTime;
      hilog.info(domainId, logTag, 'Effective click');
      callback();
    } else {
      hilog.info(domainId, logTag, 'Invalid click');
    }
  }
}

