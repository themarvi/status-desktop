import ../item

method offerToStorePassword*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitStoringPasswordError*(self: AccessInterface, errorDescription: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitStoringPasswordSuccess*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method activeSectionSet*(self: AccessInterface, sectionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method enableSection*(self: AccessInterface, sectionType: SectionType) {.base.} =
  raise newException(ValueError, "No implementation available")

method disableSection*(self: AccessInterface, sectionType: SectionType) {.base.} =
  raise newException(ValueError, "No implementation available")