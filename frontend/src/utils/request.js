import axios from "axios";
import { ElMessage } from "element-plus";

const request = axios.create({
  baseURL: "/api",
  timeout: 15000,
});

request.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

request.interceptors.response.use(
  (res) => {
    const data = res.data;
    if (data.code !== 200) {
      // 401 未认证：清除 token 并跳转登录页
      if (data.code === 401) {
        localStorage.removeItem("token");
        ElMessage.error(data.message || "登录已过期，请重新登录");
        // 避免在登录页重复跳转
        if (window.location.hash !== "#/login" && window.location.hash !== "#/register") {
          window.location.href = "#/login";
        }
        return Promise.reject(new Error(data.message));
      }
      ElMessage.error(data.message || "请求失败");
      return Promise.reject(new Error(data.message));
    }
    return data;
  },
  (err) => {
    ElMessage.error(err.response?.data?.message || "网络错误");
    return Promise.reject(err);
  }
);

export default request;
