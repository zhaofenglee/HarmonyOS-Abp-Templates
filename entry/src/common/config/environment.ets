// 获取环境变量
const ENV: string = 'dev';

// 根据环境变量设置BASE_URL
export const BASE_URL = ENV === 'prod'
  ? 'https://api.bookstore.cn'
  : 'https://api.bookstore.dev';

interface OAuthConfig {
  scope: string;
  clientId: string;
  clientSecret?: string;
  issuer: string;
}

// 根据环境变量设置oAuthConfig
export const oAuthConfig: OAuthConfig = {
  scope: 'profile email offline_access bookstore',
  clientId: 'Bookstore_Mobile',
  clientSecret: undefined,
  issuer: ENV === 'prod'
    ? 'https://login.bookstore.cn'
    : 'https://login.bookstore.dev',
};