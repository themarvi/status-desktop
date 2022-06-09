target_sources(${PROJECT_NAME}
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/NewAccountController.h
        ${CMAKE_CURRENT_SOURCE_DIR}/OnboardingController.h
        ${CMAKE_CURRENT_SOURCE_DIR}/OnboardingModule.h
        ${CMAKE_CURRENT_SOURCE_DIR}/UserAccount.h
        ${CMAKE_CURRENT_SOURCE_DIR}/UserAccountsModel.h
        
        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/AccountDto.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/GeneratedAccountDto.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/LocalAccountSettings.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/Service.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/ServiceInterface.h
        
        ${CMAKE_CURRENT_SOURCE_DIR}/Keychain/Keychain.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Keychain/KeychainManager.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Keychain/LocalAuthentication.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Keychain/Service.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Keychain/ServiceInterface.h
        
        
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/NewAccountController.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/OnboardingController.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/OnboardingModule.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/UserAccount.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/UserAccountsModel.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/Accounts/Service.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/Common/Constants.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Common/Json.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Common/Logger.h
        ${CMAKE_CURRENT_SOURCE_DIR}/Common/SigningPhrases.h

        ${CMAKE_CURRENT_SOURCE_DIR}/Keychain/Keychain.mm
        ${CMAKE_CURRENT_SOURCE_DIR}/Keychain/KeychainManager.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/Keychain/KeychainManager.mm
        ${CMAKE_CURRENT_SOURCE_DIR}/Keychain/LocalAuthentication.mm
        ${CMAKE_CURRENT_SOURCE_DIR}/Keychain/Service.cpp

)
