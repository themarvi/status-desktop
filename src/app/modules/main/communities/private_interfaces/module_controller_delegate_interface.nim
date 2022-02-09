
method myRequestAdded*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityLeft*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityChannelReordered*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityChannelDeleted*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityCategoryCreated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityCategoryEdited*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityCategoryDeleted*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityEdited*(self: AccessInterface, community: CommunityDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityAdded*(self: AccessInterface, community: CommunityDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityImported*(self: AccessInterface, community: CommunityDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onImportCommunityErrorOccured*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")
