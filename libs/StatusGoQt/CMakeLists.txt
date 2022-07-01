# Light helpers library expected to be used by all other libraries
#
cmake_minimum_required(VERSION 3.21)

project(StatusGoQt
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(nlohmann_json 3.2.0 REQUIRED)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Core Concurrent REQUIRED)
qt6_standard_project_setup()

add_library(${PROJECT_NAME} SHARED "")

# Use by linker only
set_property(GLOBAL PROPERTY DEBUG_CONFIGURATIONS Debug)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Core
        Qt6::Concurrent

        statusgo_shared

        nlohmann_json::nlohmann_json
)
add_library(Status::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo
    # TODO: Workaround to QML_ELEMENT Qt6
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo

    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Copy status-go lib close to the executable
# Temporary workaround; TODO: see a better alternative that doesn't depend on target order (dedicated dependencies dir?)
# and current directory (on mac). Use bundle or set rpath relative to executable
get_target_property(STATUSGO_LIBRARY_PATH statusgo_shared IMPORTED_LOCATION)
add_custom_command(
    TARGET
        ${PROJECT_NAME}
    POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            $<TARGET_FILE:statusgo_shared>
            ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
        COMMENT "Copying status-go lib beside project executable"
)

install(
    IMPORTED_RUNTIME_ARTIFACTS
        statusgo_shared
)

target_sources(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/General.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/General.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Types.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Utils.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Utils.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Accounts/Accounts.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Accounts/Accounts.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Messenger/Service.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Messenger/Service.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/SignalsManager.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/SignalsManager.cpp

        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Wallet/WalletAccount.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Wallet/WalletAccounts.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Wallet/WalletToken.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/StatusGo/Wallet/WalletAccounts.cpp
)
