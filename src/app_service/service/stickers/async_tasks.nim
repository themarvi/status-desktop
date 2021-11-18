include ../../common/json_utils
include ../../../app/core/tasks/common

type
  EstimateTaskArg = ref object of QObjectTaskArg
    packId: int
    address: string
    price: string
    uuid: string
  ObtainAvailableStickerPacksTaskArg = ref object of QObjectTaskArg
    running*: ByteAddress # pointer to threadpool's `.running` Atomic[bool]

# The pragmas `{.gcsafe, nimcall.}` in this context do not force the compiler
# to accept unsafe code, rather they work in conjunction with the proc
# signature for `type Task` in tasks/common.nim to ensure that the proc really
# is gcsafe and that a helpful error message is displayed
const estimateTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[EstimateTaskArg](argEncoded)
  var success: bool
  var estimate = estimateGas(arg.packId, arg.address, arg.price,
    success)
  if not success:
    estimate = 325000
  let tpl: tuple[estimate: int, uuid: string] = (estimate, arg.uuid)
  arg.finish(tpl)

const obtainAvailableStickerPacksTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[ObtainAvailableStickerPacksTaskArg](argEncoded)
  var running = cast[ptr Atomic[bool]](arg.running)
  let availableStickerPacks = status_stickers_legacy.getAvailableStickerPacks(running[])
  var packs: seq[StickerPack] = @[]
  for packId, stickerPack in availableStickerPacks.pairs:
    packs.add(stickerPack)
  arg.finish(%*(packs))
