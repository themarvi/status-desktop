import dto

export dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

# method getPubKey*(self: ServiceInterface): string {.base.} =
#   raise newException(ValueError, "No implementation available")

method setDeviceName*(self: ServiceInterface, deviceName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method syncAllDevices*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method advertiseDevice*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method enableInstallation*(self: ServiceInterface, installationId: string, enable: bool) {.base.} =
  raise newException(ValueError, "No implementation available")
