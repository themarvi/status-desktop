import io_interface
import ../../../../../app_service/service/wallet_account/service as wallet_account_service


type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    walletAccountService: wallet_account_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  walletAccountService: wallet_account_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.walletAccountService = walletAccountService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getWalletAccount*(self: Controller, accountIndex: int): wallet_account_service.WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

proc update*(self: Controller, address: string, accountName: string, color: string, emoji: string) =
  self.walletAccountService.updateWalletAccount(address, accountName, color, emoji)
