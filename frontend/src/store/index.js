import { defineStore } from "pinia";
import { ref } from "vue";
import { getProfile } from "../api/user";

export const useUserStore = defineStore("user", () => {
  const user = ref(null);
  const token = ref(localStorage.getItem("token") || "");

  const isLoggedIn = () => !!token.value;

  const setToken = (t) => {
    token.value = t;
    localStorage.setItem("token", t);
  };

  const logout = () => {
    token.value = "";
    user.value = null;
    localStorage.removeItem("token");
  };

  const fetchProfile = async () => {
    if (isLoggedIn()) {
      const res = await getProfile();
      user.value = res.data;
    }
  };

  return { user, token, isLoggedIn, setToken, logout, fetchProfile };
});
