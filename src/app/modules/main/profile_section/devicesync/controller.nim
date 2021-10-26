import ./controller_interface
import ../../../../../app_service/service/devicesync/service as devicesync_service

# import ./item as item

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    deviceSyncService: devicesync_service.ServiceInterface

proc newController*[T](delegate: T, deviceSyncService: devicesync_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.deviceSyncService = deviceSyncService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method setDeviceName*[T](self: Controller[T], deviceName: string) =
  self.deviceSyncService.setDeviceName(deviceName)

method syncAllDevices*[T](self: Controller[T]) =
  self.deviceSyncService.syncAllDevices()

method advertiseDevice*[T](self: Controller[T]) =
  self.deviceSyncService.advertiseDevice()

method enableInstallation*[T](self: Controller[T], installationId: string, enable: bool) =
  self.deviceSyncService.enableInstallation(installationId, enable)
