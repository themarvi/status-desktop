import strformat

type
  Item* = object
    name: string
    symbol: string
    hasIcon: bool
    address: string
    decimals: int
    isCustom: bool
    isVisible: bool

proc initItem*(name, symbol: string, hasIcon: bool, address: string, decimals: int, isCustom: bool, isVisible: bool): Item =
  result.name = name
  result.symbol = symbol
  result.hasIcon = hasIcon
  result.address = address
  result.decimals = decimals
  result.isCustom = isCustom
  result.isVisible = isVisible

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    name: {self.name},
    symbol: {self.symbol},
    hasIcon: {self.hasIcon},
    address: {self.address},
    decimals: {self.decimals},
    isCustom:{self.isCustom},
    isVisible:{self.isVisible}
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getSymbol*(self: Item): string =
  return self.symbol

proc getHasIcon*(self: Item): bool =
  return self.hasIcon

proc getAddress*(self: Item): string =
  return self.address

proc getDecimals*(self: Item): int =
  return self.decimals

proc getIsCustom*(self: Item): bool =
  return self.isCustom

proc getIsVisible*(self: Item): bool =
  return self.isVisible
