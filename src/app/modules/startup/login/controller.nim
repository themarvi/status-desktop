import NimQml, Tables

import controller_interface
import io_interface
import ../../../global/global_singleton

import ../../../../app_service/service/keychain/service as keychain_service
import ../../../../app_service/service/accounts/service_interface as accounts_service

import eventemitter
import status/[signals]

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    keychainService: keychain_service.Service
    accountsService: accounts_service.ServiceInterface
    selectedAccountKeyUid: string

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.ServiceInterface): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.keychainService = keychainService
  result.accountsService = accountsService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SignalType.NodeLogin.event) do(e:Args):
    let signal = NodeSignal(e)
    if signal.event.error != "":
      self.delegate.emitAccountLoginError(signal.event.error)

  self.events.on("keychainServiceSuccess") do(e:Args):
    let args = KeyChainServiceArg(e)
    self.delegate.emitObtainingPasswordSuccess(args.data)

  self.events.on("keychainServiceError") do(e:Args):
    let args = KeyChainServiceArg(e)
    # We are notifying user only about keychain errors.
    if (args.errType == ERROR_TYPE_AUTHENTICATION):
      return
    
    singletonInstance.localAccountSettings.removeKey(LS_KEY_STORE_TO_KEYCHAIN)
    self.delegate.emitObtainingPasswordError(args.errDescription)

method getOpenedAccounts*(self: Controller): seq[AccountDto] =
  return self.accountsService.openedAccounts()

proc getSelectedAccount(self: Controller): AccountDto =
  let openedAccounts = self.getOpenedAccounts()
  for acc in openedAccounts:
    if(acc.keyUid == self.selectedAccountKeyUid):
      return acc

method setSelectedAccountKeyUid*(self: Controller, keyUid: string) =
  self.selectedAccountKeyUid = keyUid

  # Dealing with Keychain is the MacOS only feature
  if(not defined(macosx)): 
    return

  let selectedAccount = self.getSelectedAccount()
  singletonInstance.localAccountSettings.setFileName(selectedAccount.name)

  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value != LS_VALUE_STORE):
    return

  self.keychainService.tryToObtainPassword(selectedAccount.name)

method login*(self: Controller, password: string) =
  let selectedAccount = self.getSelectedAccount()

  let error = self.accountsService.login(selectedAccount, password)
  if(error.len > 0):
    self.delegate.emitAccountLoginError(error)