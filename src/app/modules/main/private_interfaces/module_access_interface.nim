import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/stickers/service as stickers_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/transaction/service as transaction_service

import eventemitter

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(
  self: AccessInterface,
  events: EventEmitter,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  stickersService: stickers_service.Service
  ) 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method checkForStoringPassword*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")