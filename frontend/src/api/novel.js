import request from "../utils/request";

export function getNovelList(params) {
  return request.get("/novel/list", { params });
}

export function getCategories() {
  return request.get("/novel/categories");
}

export function getNovelDetail(id) {
  return request.get(`/novel/detail/${id}`);
}

export function publishNovel(data) {
  return request.post("/novel/publish", data);
}

export function getMyNovels(params) {
  return request.get("/novel/my", { params });
}

export function deleteNovel(id) {
  return request.delete(`/novel/${id}`);
}
