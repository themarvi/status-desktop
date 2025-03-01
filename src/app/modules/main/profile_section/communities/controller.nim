import io_interface

import ../../../../../app_service/service/community/service as community_service


type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    communityService: community_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  communityService: community_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.communityService = communityService

proc delete*(self: Controller) =
  discard

proc inviteUsersToCommunity*(self: Controller, communityID: string, pubKeys: string): string =
  result = self.communityService.inviteUsersToCommunityById(communityID, pubKeys)

proc leaveCommunity*(self: Controller, communityID: string) =
  self.communityService.leaveCommunity(communityID)

method setCommunityMuted*(self: Controller, communityID: string, muted: bool) =
  self.communityService.setCommunityMuted(communityID, muted)

