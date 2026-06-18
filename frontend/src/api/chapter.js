import request from "../utils/request";

export function getChapterList(novelId) {
  return request.get(`/chapter/list/${novelId}`);
}

export function getChapterDetail(id) {
  return request.get(`/chapter/detail/${id}`);
}

export function addChapter(data) {
  return request.post("/chapter/add", data);
}

export function updateChapter(data) {
  return request.put("/chapter/update", data);
}

export function deleteChapter(id) {
  return request.delete(`/chapter/delete/${id}`);
}
