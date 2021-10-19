import NimQml, sequtils, sugar, json

# import ./item
import ../../../../../app_service/service/contacts/dto
import ./model
import status/types/profile
import models/[contact_list]
import ./io_interface

# import status/types/[identity_image, profile]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      contactList*: ContactList
      contactRequests*: ContactList
      addedContacts*: ContactList
      blockedContacts*: ContactList
      contactToAdd*: Dto
      accountKeyUID*: string

  proc delete*(self: View) =
    self.model.delete
    self.contactList.delete
    self.addedContacts.delete
    self.contactRequests.delete
    self.blockedContacts.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.contactList = newContactList()
    result.contactRequests = newContactList()
    result.addedContacts = newContactList()
    result.blockedContacts = newContactList()
    result.contactToAdd = Dto()

#   proc modelChanged*(self: View) {.signal.}

#   proc getModel*(self: View): QVariant {.slot.} =
#     return self.modelVariant

#   QtProperty[QVariant] model:
#     read = getModel
#     notify = modelChanged

  proc contactListChanged*(self: View) {.signal.}
  proc contactRequestAdded*(self: View, name: string, address: string) {.signal.}

  proc updateContactList*(self: View, contacts: seq[Profile]) =
    for contact in contacts:
      var requestAlreadyAdded = false
      for existingContact in self.contactList.contacts:
        if existingContact.address == contact.address and existingContact.requestReceived():
          requestAlreadyAdded = true
          break

      self.contactList.updateContact(contact)
      if contact.added:
        self.addedContacts.updateContact(contact)

      if contact.isBlocked():
        self.blockedContacts.updateContact(contact)

      if contact.requestReceived() and not contact.added and not contact.blocked:
        self.contactRequests.updateContact(contact)

      if not requestAlreadyAdded and contact.requestReceived():
        # TODO add back userNameOrAlias call
        self.contactRequestAdded(contact.username, contact.address)
        # self.contactRequestAdded(status_ens.userNameOrAlias(contact), contact.address)

    self.contactListChanged()

  proc getContactList(self: View): QVariant {.slot.} =
    return newQVariant(self.contactList)

  proc setContactList*(self: View, contactList: seq[Profile]) =
    self.contactList.setNewData(contactList)
    self.addedContacts.setNewData(contactList.filter(c => c.added))
    self.blockedContacts.setNewData(contactList.filter(c => c.blocked))
    self.contactRequests.setNewData(contactList.filter(c => c.hasAddedUs and not c.added and not c.blocked))

    self.contactListChanged()

  QtProperty[QVariant] list:
    read = getContactList
    write = setContactList
    notify = contactListChanged

  proc getAddedContacts(self: View): QVariant {.slot.} =
    return newQVariant(self.addedContacts)

  QtProperty[QVariant] addedContacts:
    read = getAddedContacts
    notify = contactListChanged

  proc getBlockedContacts(self: View): QVariant {.slot.} =
    return newQVariant(self.blockedContacts)

  QtProperty[QVariant] blockedContacts:
    read = getBlockedContacts
    notify = contactListChanged

  proc isContactBlocked*(self: View, pubkey: string): bool {.slot.} =
    for contact in self.blockedContacts.contacts:
      if contact.id == pubkey:
        return true
    return false

  proc getContactRequests(self: View): QVariant {.slot.} =
    return newQVariant(self.contactRequests)

  QtProperty[QVariant] contactRequests:
    read = getContactRequests
    notify = contactListChanged

  proc contactToAddChanged*(self: View) {.signal.}

  proc getContactToAddUsername(self: View): QVariant {.slot.} =
    var username = self.contactToAdd.alias;

    if self.contactToAdd.ensVerified and self.contactToAdd.name != "":
      username = self.contactToAdd.name

    return newQVariant(username)

  QtProperty[QVariant] contactToAddUsername:
    read = getContactToAddUsername
    notify = contactToAddChanged

  proc getContactToAddPubKey(self: View): QVariant {.slot.} =
    # TODO cofirm that id is the pubKey
    return newQVariant(self.contactToAdd.id)

  QtProperty[QVariant] contactToAddPubKey:
    read = getContactToAddPubKey
    notify = contactToAddChanged

  proc isAdded*(self: View, pubkey: string): bool {.slot.} =
    for contact in self.addedContacts.contacts:
      if contact.id == pubkey:
        return true
    return false

  proc contactRequestReceived*(self: View, pubkey: string): bool {.slot.} =
    for contact in self.contactRequests.contacts:
      if contact.id == pubkey:
        return true
    return false

  proc lookupContact*(self: View, value: string) {.slot.} =
    if value == "":
      return

    # self.lookupContact("ensResolved", value)

  proc ensWasResolved*(self: View, resolvedPubKey: string) {.signal.}

  proc ensResolved(self: View, id: string) {.slot.} =
    self.ensWasResolved(id)
    if id == "":
      self.contactToAddChanged()
      return

    let contact = self.delegate.getContact(id)

    if contact != nil:
      self.contactToAdd = contact
    else:
      self.contactToAdd = Dto(
        id: id,
        alias: self.delegate.generateAlias(id),
        ensVerified: false
      )
    self.contactToAddChanged()

  proc addContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.addContact(self.accountKeyUID, publicKey)
    # TODO add back joining of timeline
    # self.status.chat.join(status_utils.getTimelineChatId(publicKey), ChatType.Profile, "", publicKey)

  proc rejectContactRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.rejectContactRequest(publicKey)

  proc rejectContactRequests*(self: View, publicKeysJSON: string) {.slot.} =
    let publicKeys = publicKeysJSON.parseJson
    for pubkey in publicKeys:
      self.rejectContactRequest(pubkey.getStr)

  proc acceptContactRequests*(self: View, publicKeysJSON: string) {.slot.} =
    let publicKeys = publicKeysJSON.parseJson
    for pubkey in publicKeys:
      self.addContact(pubkey.getStr)

  proc changeContactNickname*(self: View, publicKey: string, nickname: string) {.slot.} =
    var nicknameToSet = nickname
    if (nicknameToSet == ""):
      nicknameToSet = DELETE_CONTACT
    self.delegate.changeContactNickname(publicKey, nicknameToSet, self.accountKeyUID)

  proc unblockContact*(self: View, publicKey: string) {.slot.} =
    self.contactListChanged()
    self.delegate.unblockContact(publicKey)

  proc contactBlocked*(self: View, publicKey: string) {.signal.}

  proc blockContact*(self: View, publicKey: string) {.slot.} =
    self.contactListChanged()
    self.contactBlocked(publicKey)
    self.delegate.blockContact(publicKey)

  proc removeContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeContact(publicKey)
    # TODO add back leaving timeline
    # let channelId = status_utils.getTimelineChatId(publicKey)
    # if self.status.chat.hasChannel(channelId):
    #   self.status.chat.leave(channelId)
