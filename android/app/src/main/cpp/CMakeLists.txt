cmake_minimum_required(VERSION 3.10.2)

# إضافة دعم 16KB page size
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,max-page-size=16384")

# إنشاء مكتبة dummy حتى يقبل النظام CMake
add_library(dummy SHARED dummy.cpp)
