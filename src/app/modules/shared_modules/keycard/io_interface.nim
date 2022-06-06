import NimQml

type FlowStateType* {.pure.} = enum
  PluginKeycard = "pluginKeycardState"
  InsertKeycard = "insertKeycardState"
  ReadingKeycard = "readingKeycardState"

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method switchToState*(self: AccessInterface, state: FlowStateType) {.base.} =
  raise newException(ValueError, "No implementation available")

method startKeycardFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method cancelFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")