cmake_minimum_required(VERSION 3.16.0 FATAL_ERROR)
project(plasma-places-widget)

find_package(ECM 0.0.11 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

find_package(KF6 REQUIRED)
find_package(Plasma 5.92.0 REQUIRED)

plasma_install_package(package org.kde.placesWidget)
