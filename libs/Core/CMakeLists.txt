# Base library. Expect most of the module libraries to depend on it
#
cmake_minimum_required(VERSION 3.21)

project(Core
    VERSION 0.1.0
    LANGUAGES CXX)

set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS true)

find_package(Qt6 ${STATUS_QT_VERSION} COMPONENTS Quick Qml REQUIRED)
qt6_standard_project_setup()

qt6_add_qml_module(${PROJECT_NAME}
    URI Status.${PROJECT_NAME}
    VERSION 1.0
)
add_library(Status::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

add_subdirectory(src)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Quick
        Qt6::Qml
)

install(
    TARGETS
        ${PROJECT_NAME}
    RUNTIME
)

# QtCreator needs this
set(QML_IMPORT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/qml;${QML_IMPORT_PATH} CACHE STRING "For QtCreator" FORCE)
list(REMOVE_DUPLICATES QML_IMPORT_PATH)
