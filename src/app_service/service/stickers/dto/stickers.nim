{.used.}

import json, strformat, strutils, stint

include ../../../common/json_utils
include ../../../common/utils

type StickerDto* = object
  hash*: string
  packId*: int

type StickerPackDto* = object
  id*: int
  name*: string
  author*: string
  price*: Stuint[256]
  preview*: string
  stickers*: seq[StickerDto]
  thumbnail*: string


proc `$`(self: StickerDto): string =
  result = fmt"""StickerDto(
    hash: {self.hash},
    packId: {$self.packId}, 
    ]"""

proc `$`*(self: StickerPackDto): string =
  result = fmt"""StickerPackDto(
    id: {$self.id}, 
    name: {self.name},
    author: {self.author},
    price: {$self.price}, 
    preview: {self.preview}, 
    stickersLen: {$self.stickers.len}, 
    thumbnail:{self.thumbnail}  
    )"""

proc toStickerDto(jsonObj: JsonNode): StickerDto =
  result = StickerDto()
  discard jsonObj.getProp("hash", result.hash)
  discard jsonObj.getProp("packId", result.packId)

proc toStickerPackDto*(jsonObj: JsonNode): StickerPackDto =
  result = StickerPackDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("author", result.author)
  result.price = stint.fromHex(Stuint[256], jsonObj["price"].getStr)
  discard jsonObj.getProp("thumbnail", result.thumbnail)

  result.stickers = @[]
  for sticker in jsonObj["stickers"]:
    result.stickers.add(sticker.toStickerDto)
