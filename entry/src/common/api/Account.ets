import axios, { AxiosResponse } from '@ohos/axios'
import {oAuthConfig,} from '../config/environment'

interface LoginData {
  username: string;
  password: string;
}

interface ApiResponse {
  access_token: string;
  token_type: string;
  expires_in: number;
  refresh_token: string;
}

export interface UserInfo {
  family_name: string;
  given_name:string;
  preferred_username:string;
  email: string;
}


const getLoginData = (username: string, password: string): string => {
  const formData = new Map<string, string>();
  formData.set('grant_type', 'password');
  formData.set('scope', oAuthConfig.scope);
  formData.set('username', username);
  formData.set('password', password);
  formData.set('client_id', oAuthConfig.clientId);

  if (oAuthConfig.clientSecret) {
    formData.set('client_secret', oAuthConfig.clientSecret);
  }

  let formBody: string[] = [];
  formData.forEach((value, key) => {
    const encodedKey: string = encodeURIComponent(key);
    const encodedValue: string = encodeURIComponent(value);
    formBody.push(`${encodedKey}=${encodedValue}`);
  });

  return formBody.join('&');
};

export const login = async (loginData: LoginData): Promise<ApiResponse> => {
  const response: AxiosResponse<ApiResponse> = await axios.post<ApiResponse>(
    '/connect/token',
    getLoginData(loginData.username, loginData.password),
    {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      baseURL: oAuthConfig.issuer,
    }
  );
  console.info("result", JSON.stringify(response.data));
  if (response.data.access_token) {
    console.log('Written token to storage');
    AppStorage.setOrCreate('token_type', response.data.token_type)
    AppStorage.setOrCreate('expires_in', response.data.expires_in)
    AppStorage.setOrCreate('access_token', response.data.access_token)
    AppStorage.setOrCreate('refresh_token', response.data.refresh_token)
    const userInfo = await getUserInfo(response.data.access_token)
    if (userInfo) {
      console.log('Written userInfo to storage');
      AppStorage.setOrCreate('userInfo', userInfo)
    }
  }
  return response.data;
};

export const mockLogin = async (loginData: LoginData): Promise<ApiResponse> => {
  AppStorage.setOrCreate('userInfo', {
    family_name:'张',
    given_name:'三',
    preferred_username:'张三',
    email:'zhangsan@sample.io'
  })
  return new Promise((resolve) => {
    setTimeout(() => {
      console.info("Mock login successful for user:", loginData.username);
      resolve({
        access_token: 'mockAccessToken123',
        token_type:'Bearer',
        refresh_token: 'mockRefreshToken123',
        expires_in: 3600,
      });
    }, 1000); // 模拟网络延迟
  });
};


const getLoginOutData = (): string => {
  const formData = new Map<string, string>();
  const token:string  =  AppStorage.get('access_token')??'1';
  formData.set('client_id', oAuthConfig.clientId);
  formData.set('token', token);
  formData.set('token_type_hint', 'access_token');

  let formBody: string[] = [];
  formData.forEach((value, key) => {
    const encodedKey: string = encodeURIComponent(key);
    const encodedValue: string = encodeURIComponent(value);
    formBody.push(`${encodedKey}=${encodedValue}`);
  });

  return formBody.join('&');
};

export const logout = async (): Promise<void> => {
  try {
    const response:string = await axios.post(
      '/connect/revocat',
      getLoginOutData(),
      {
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        baseURL: oAuthConfig.issuer,
      }
    );
    console.info("Logout successful", response);
  } catch (error) {
    console.error("Logout failed", error);
  }
};

export const getUserInfo = async (token: string): Promise<UserInfo | undefined> => {
  try {
    const response: AxiosResponse<UserInfo> = await axios.get<UserInfo>(
      '/connect/userinfo',
      {
        headers: { 
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': `Bearer ${token}`
        },
        baseURL: oAuthConfig.issuer,
      }
    );
    console.log('User Info:', JSON.stringify(response.data));
    return response.data;
  } catch (error) {
    console.error('Failed to fetch user info:', error);
    return undefined;
  }
};