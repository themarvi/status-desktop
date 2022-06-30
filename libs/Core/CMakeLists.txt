# Base library. Expect most of the module libraries to depend on it
#
cmake_minimum_required(VERSION 3.21)

project(Core
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

#find_package(nlohmann_json 3.2.0 REQUIRED)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(Core
    URI Status.Core
    VERSION 1.0
)
add_library(Status::Core ALIAS Core)

target_link_libraries(Core
    PRIVATE
        Qt6::Quick
        Qt6::Qml
)

install(
    TARGETS
        Core
    RUNTIME
)

target_include_directories(Core
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core
    # TODO: Workaround to QML_ELEMENT Qt6
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core

    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_sources(Core
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core/Conversions.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core/Conversions.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core/UserConfiguration.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core/UserConfiguration.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core/StaticUserConfiguration.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Core/StaticUserConfiguration.cpp
)

# QtCreator needs this
set(QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/qml;${QML_IMPORT_PATH} CACHE STRING "For QtCreator" FORCE)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)

