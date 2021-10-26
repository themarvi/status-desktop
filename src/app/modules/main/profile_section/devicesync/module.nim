import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../../../../core/global_singleton

import ../../../../../app_service/service/devicesync/service as devicesync_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T, deviceSyncService: devicesync_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, deviceSyncService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("deviceSyncModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method setDeviceName*[T](self: Module[T], deviceName: string) =
  self.controller.setDeviceName(deviceName)

method syncAllDevices*[T](self: Module[T]) =
  self.controller.syncAllDevices()

method advertiseDevice*[T](self: Module[T]) =
  self.controller.advertiseDevice()

method enableInstallation*[T](self: Module[T], installationId: string, enable: bool) =
  self.controller.enableInstallation(installationId, enable)
