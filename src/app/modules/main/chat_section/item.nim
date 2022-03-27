import strformat, json
import base_item, sub_model, sub_item

type
  Item* = ref object of BaseItem
    subItems: SubModel

proc initItem*(id, name, icon: string, color, emoji, description: string,
    `type`: int, amIChatAdmin: bool, hasUnreadMessages: bool, notificationsCount: int, muted,
    blocked, active: bool, position: int, categoryId: string, colorHash: seq[ColorHashSegment] = @[], highlight: bool = false): Item =
  result = Item()
  result.setup(id, name, icon, color, emoji, description, `type`, amIChatAdmin, hasUnreadMessages,
  notificationsCount, muted, blocked, active, position, categoryId, colorHash, highlight)
  result.subItems = newSubModel()

proc delete*(self: Item) =
  self.subItems.delete
  self.BaseItem.delete

proc subItems*(self: Item): SubModel {.inline.} =
  self.subItems

proc `$`*(self: Item): string =
  result = fmt"""ChatSectionItem(
    itemId: {self.id},
    name: {self.name},
    amIChatAdmin: {self.amIChatAdmin},
    icon: {self.icon},
    color: {self.color},
    emoji: {self.emoji},
    description: {self.description},
    type: {self.`type`},
    hasUnreadMessages: {self.hasUnreadMessages},
    notificationsCount: {self.notificationsCount},
    muted: {self.muted},
    blocked: {self.blocked},
    active: {self.active},
    position: {self.position},
    categoryId: {self.categoryId},
    highlight: {self.highlight},
    trustStatus: {self.trustStatus},
    subItems:[
      {$self.subItems}
    ]"""

proc toJsonNode*(self: Item): JsonNode =
  result = %* {
    "itemId": self.id,
    "name": self.name,
    "amIChatAdmin": self.amIChatAdmin,
    "icon": self.icon,
    "color": self.color,
    "emoji": self.emoji,
    "description": self.description,
    "type": self.`type`,
    "hasUnreadMessages": self.hasUnreadMessages,
    "notificationsCount": self.notificationsCount,
    "muted": self.muted,
    "blocked": self.blocked,
    "active": self.active,
    "position": self.position,
    "categoryId": self.categoryId,
    "highlight": self.highlight,
    "trustStatus": self.trustStatus,
  }

proc appendSubItems*(self: Item, items: seq[SubItem]) =
  self.subItems.appendItems(items)

proc appendSubItem*(self: Item, item: SubItem) =
  self.subItems.appendItem(item)

proc prependSubItems*(self: Item, items: seq[SubItem]) =
  self.subItems.prependItems(items)

proc prependSubItem*(self: Item, item: SubItem) =
  self.subItems.prependItem(item)

proc setActiveSubItem*(self: Item, subItemId: string) =
  self.subItems.setActiveItem(subItemId)
