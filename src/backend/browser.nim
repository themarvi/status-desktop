import json, strutils
import core, utils
import response_type
import ./backend

export response_type


proc addBookmark*(bookmark: backend.Bookmark): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("addBookmark".prefix, %*[{
    "url": bookmark.url,
    "name": bookmark.name,
    "imageUrl": bookmark.imageUrl,
    "removed": bookmark.removed,
    "deletedAt": bookmark.deletedAt
  }])

proc removeBookmark*(url: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("removeBookmark".prefix, %*[url])
