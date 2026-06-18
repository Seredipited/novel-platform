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
    if (res.data.code !== 200) {
      ElMessage.error(res.data.message || "请求失败");
      return Promise.reject(new Error(res.data.message));
    }
    return res.data;
  },
  (err) => {
    ElMessage.error(err.response?.data?.message || "网络错误");
    return Promise.reject(err);
  }
);

export default request;
