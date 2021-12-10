import chronicles
import controller_interface
import io_interface

import ../../../../../../app_service/service/contacts/service as contact_service
import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/message/service as message_service

import ../../../../../core/signals/types
import eventemitter

export controller_interface

logScope:
  topics = "messages-controller"

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    chatId: string
    belongsToCommunity: bool
    contactService: contact_service.Service
    chatService: chat_service.Service
    messageService: message_service.Service

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter, chatId: string, belongsToCommunity: bool, 
  contactService: contact_service.Service, chatService: chat_service.Service, messageService: message_service.Service): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.contactService = contactService
  result.chatService = chatService
  result.messageService = messageService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SIGNAL_MESSAGES_LOADED) do(e:Args):
    let args = MessagesLoadedArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.newMessagesLoaded(args.messages, args.reactions, args.pinnedMessages)

  self.events.on(SIGNAL_MESSAGE_PINNED) do(e:Args):
    let args = MessagePinUnpinArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onPinUnpinMessage(args.messageId, true)

  self.events.on(SIGNAL_MESSAGE_UNPINNED) do(e:Args):
    let args = MessagePinUnpinArgs(e)
    if(self.chatId != args.chatId):
      return
    self.delegate.onPinUnpinMessage(args.messageId, false)

method getChatId*(self: Controller): string =
  return self.chatId

method getChatDetails*(self: Controller): ChatDto =
  return self.chatService.getChatById(self.chatId)

method getOneToOneChatNameAndImage*(self: Controller): tuple[name: string, image: string, isIdenticon: bool] =
  return self.chatService.getOneToOneChatNameAndImage(self.chatId)

method belongsToCommunity*(self: Controller): bool =
  return self.belongsToCommunity

method addReaction*(self: Controller, messageId: string, emojiId: int) =
  let (res, err) = self.messageService.addReaction(self.chatId, messageId, emojiId)
  if(err.len != 0):
    error "an error has occurred while saving reaction: ", err
    return

  self.delegate.onReactionAdded(messageId, emojiId, res)

method removeReaction*(self: Controller, messageId: string, reactionId: string) =
  let (res, err) = self.messageService.removeReaction(reactionId)
  if(err.len != 0):
    error "an error has occurred while removing reaction: ", err
    return

  self.delegate.onReactionRemoved(messageId, reactionId)

method pinUnpinMessage*(self: Controller, messageId: string, pin: bool) =
  self.messageService.pinUnpinMessage(self.chatId, messageId, pin)

method getContactById*(self: Controller, contactId: string): ContactsDto =
  return self.contactService.getContactById(contactId)

method getContactNameAndImage*(self: Controller, contactId: string): 
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.contactService.getContactNameAndImage(contactId)