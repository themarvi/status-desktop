import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/contacts/service as contacts_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    contactsService: contacts_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  contactsService: contacts_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.contactsService = contactsService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_CONTACT_ADDED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactAdded(args.contactId)

  self.events.on(SIGNAL_CONTACT_BLOCKED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactBlocked(args.contactId)

  self.events.on(SIGNAL_CONTACT_UNBLOCKED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactUnblocked(args.contactId)

  self.events.on(SIGNAL_CONTACT_REMOVED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactRemoved(args.contactId)

  self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactNicknameChanged(args.contactId)

  self.events.on(SIGNAL_CONTACT_UNTRUSTWORTHY) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.contactTrustStatusChanged(args.publicKey, args.trustStatus)

  self.events.on(SIGNAL_CONTACT_TRUSTED) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.contactTrustStatusChanged(args.publicKey, args.trustStatus)

  self.events.on(SIGNAL_REMOVED_TRUST_STATUS) do(e: Args):
    var args = TrustArgs(e)
    self.delegate.contactTrustStatusChanged(args.publicKey, args.trustStatus)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactUpdated(args.contactId)

proc getContacts*(self: Controller): seq[ContactsDto] =
  return self.contactsService.getContacts()

proc getContact*(self: Controller, id: string): ContactsDto =
  return self.contactsService.getContactById(id)

proc getContactNameAndImage*(self: Controller, contactId: string):
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.contactsService.getContactNameAndImage(contactId)

proc addContact*(self: Controller, publicKey: string) =
  self.contactsService.addContact(publicKey)

proc unblockContact*(self: Controller, publicKey: string) =
  self.contactsService.unblockContact(publicKey)

proc blockContact*(self: Controller, publicKey: string) =
  self.contactsService.blockContact(publicKey)

proc removeContact*(self: Controller, publicKey: string) =
  self.contactsService.removeContact(publicKey)

proc changeContactNickname*(self: Controller, publicKey: string, nickname: string) =
  self.contactsService.changeContactNickname(publicKey, nickname)

method markUntrustworthy*(self: Controller, publicKey: string): void =
  self.contactsService.markUntrustworthy(publicKey)

method removeTrustStatus*(self: Controller, publicKey: string): void =
  self.contactsService.removeTrustStatus(publicKey)

method getVerificationRequestSentTo*(self: Controller, publicKey: string): VerificationRequest =
  self.contactsService.getVerificationRequestSentTo(publicKey)

method getVerificationRequestFrom*(self: Controller, publicKey: string): VerificationRequest =
  self.contactsService.getVerificationRequestFrom(publicKey)

method sendVerificationRequest*(self: Controller, publicKey: string, challenge: string) =
  self.contactsService.sendVerificationRequest(publicKey, challenge)

method cancelVerificationRequest*(self: Controller, publicKey: string) =
  self.contactsService.cancelVerificationRequest(publicKey)

method verifiedTrusted*(self: Controller, publicKey: string): void =
  self.contactsService.verifiedTrusted(publicKey)

method verifiedUntrustworthy*(self: Controller, publicKey: string): void =
  self.contactsService.verifiedUntrustworthy(publicKey)
