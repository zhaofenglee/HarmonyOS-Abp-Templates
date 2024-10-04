import axios from '@ohos/axios'
import {BASE_URL} from '../config/environment'

const axiosInstance = axios.create({
  baseURL:BASE_URL,
});

export default axiosInstance;
