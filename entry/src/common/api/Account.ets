import axios, { AxiosError, AxiosResponse } from '@ohos/axios'
import {oAuthConfig,} from '../config/environment'
import PromptUtil from '../utils/PromptUtil';

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

interface ChangePasswordData {
  currentPassword: string;
  newPassword: string;
}

interface Profile  {
  userName: string;
  email: string;
  name: string;
  surname: string;
  phoneNumber: string | null,
  isExternal: boolean;
  hasPassword: boolean;
  concurrencyStamp: string| null;
}

interface UpdateProfile  {
  userName: string;
  email: string;
  name: string;
  surname: string| null;
  phoneNumber: string | null;
  concurrencyStamp: string| null;
}

// 创建自定义的 axios 实例
const axiosInstance = axios.create({
  baseURL: oAuthConfig.issuer,
  // 可以根据需要添加其他配置
});

interface ErrorResponseData {
  // 定义错误响应数据的类型
  error: BadRequest;
}

interface BadRequest {
  code: string;
  message: string;
  details: string | null;
  data: object;
  validationErrors: object;
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
  const response: AxiosResponse<ApiResponse> = await axiosInstance.post<ApiResponse>(
    '/connect/token',
    getLoginData(loginData.username, loginData.password),
    {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    }
  );
  console.info("result", JSON.stringify(response.data));
  if (response.data.access_token) {
    console.log('Written token to storage');
    AppStorage.setOrCreate('token_type', response.data.token_type)
    AppStorage.setOrCreate('expires_in', response.data.expires_in)
    PersistentStorage.persistProp('access_token', response.data.access_token)
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
    AppStorage.setOrCreate('access_token', '')
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

export const changePassword = async (passwordData: ChangePasswordData): Promise<void> => {
  const token:string  =  AppStorage.get('access_token')??'1';
  await axiosInstance.post<void>(
    '/api/account/my-profile/change-password',
    passwordData,
    {
      headers: { 'Authorization': 'Bearer '+token },
    }
  ).then((response: AxiosResponse<void>) => {
    return response.data;
  });

};


export const getProfile = async (): Promise<Profile | undefined> => {
  try {
    const token:string  =  AppStorage.get('access_token')??'';
    const response: AxiosResponse<Profile> = await axios.get<Profile>(
      '/api/account/my-profile',
      {
        headers: {
          'Authorization': `Bearer ${token}`
        },
        baseURL: oAuthConfig.issuer,
      }
    );
    console.log('my profile:', JSON.stringify(response.data));
    return response.data;
  } catch (error) {
    console.error('Failed to fetch user info:', error);
    return undefined;
  }
};

export const updateProfile = async (updateProfile:UpdateProfile): Promise<Profile | undefined> => {
  try {
    const token:string  =  AppStorage.get('access_token')??'';
    const response: AxiosResponse<Profile> = await axios.put<Profile>(
      '/api/account/my-profile',
      updateProfile,
      {
        headers: {
          'Authorization': `Bearer ${token}`
        },
        baseURL: oAuthConfig.issuer,
      }
    );
    console.log('my profile:', JSON.stringify(response.data));
    return response.data;
  } catch (error) {
    console.error('Failed to fetch user info:', error);
    return undefined;
  }
};


// 添加响应拦截器
axiosInstance.interceptors.response.use(
  (response: AxiosResponse) => {
    // 对响应数据做点什么
    return response;
  },
  (error: AxiosError) => {
    // 对响应错误做统一处理
    if (error.response) {
      console.log("error:" + JSON.stringify(error));
      const data = error.response.data as ErrorResponseData // cast the data property to 'unknown' type
      if (data)
      {
        handleErrorStatusCode(error.response.status,data);
      }
      else
      {
        PromptUtil.promptMessage(error.message,3000);
      }
    } else {
      console.error("error:" + JSON.stringify(error));
    }
    return Promise.reject(error);
  }
);

// 通用的错误处理函数
function handleErrorStatusCode(status: number,data: ErrorResponseData): void {
  console.log("error.message:" + data.error.message);
  console.log("error.details:" + data.error.details);
  switch (status) {
    case 401:
      console.log('handleErrorStatusCode:401');
      break;
    case 403:
      console.log('handleErrorStatusCode:403');
      break;
    case 404:
      console.log('handleErrorStatusCode:404');
      break;
    default:
      console.log('handleErrorStatusCode:default');
      break;
  }
  PromptUtil.promptMessage(`${data.error.message}`+`${data.error.details?'\n'+data.error.details:''}`,3000);
}