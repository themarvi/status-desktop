#pragma once

#include <QtCore>
#include <QStringLiteral>

namespace Status::Constants
{

namespace Fleet
{
    const auto Prod = u"eth.prod"_qs;
    const auto Staging = u"eth.staging"_qs;
    const auto Test = u"eth.test"_qs;
    const auto WakuV2Prod = u"wakuv2.prod"_qs;
    const auto WakuV2Test = u"wakuv2.test"_qs;
    const auto GoWakuTest = u"go-waku.test"_qs;
}

namespace FleetNodes
{
    const auto Bootnodes = u"boot"_qs;
    const auto Mailservers = u"mail"_qs;
    const auto Rendezvous = u"rendezvous"_qs;
    const auto Whisper = u"whisper"_qs;
    const auto Waku = u"waku"_qs;
    const auto LibP2P = u"libp2p"_qs;
    const auto Websocket = u"websocket"_qs;
}

namespace General
{
    const auto DefaultNetworkName = u"mainnet_rpc"_qs;
    //const DEFAULT_NETWORKS_IDS* = @["mainnet_rpc", "testnet_rpc", "rinkeby_rpc", "goerli_rpc", "xdai_rpc", "poa_rpc" ]

    const auto ZeroAddress = u"0x0000000000000000000000000000000000000000"_qs;

    const auto PathWalletRoot = u"m/44'/60'/0'/0"_qs;
    // EIP1581 Root Key, the extended key from which any whisper key/encryption key can be derived
    const auto PathEIP1581 = u"m/43'/60'/1581'"_qs;
    // BIP44-0 Wallet key, the default wallet key
    const auto PathDefaultWallet = PathWalletRoot + u"/0"_qs;
    // EIP1581 Chat Key 0, the default whisper key
    const auto PathWhisper = PathEIP1581 + u"/0'/0"_qs;

    const QVector<QString> AccountDefaultPaths {PathWalletRoot, PathEIP1581, PathWhisper, PathDefaultWallet};
}

}
