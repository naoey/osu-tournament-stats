export enum ContentType {
  Json = "application/json",
  FormData = "application/x-www-form-urlencoded",
  Multipart = "multipart/form-data",
}

export enum HttpMethod {
  Get = "GET",
  Put = "PUT",
  Post = "POST",
  Delete = "DELETE",
}

export enum HttpStatus {
  Ok = 200,
  Created = 201,
  NoContent = 204,
  Unauthorised = 401,
  Forbidden = 403,
  ServerError = 500,
}
