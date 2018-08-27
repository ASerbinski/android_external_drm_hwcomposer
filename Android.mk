# Copyright (C) 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ifeq ($(strip $(BOARD_USES_DRM_HWCOMPOSER)),true)

DRM_HWC_ANDROID_MAJOR_VERSION := $(word 1, $(subst ., , $(PLATFORM_VERSION)))

LOCAL_PATH := $(call my-dir)

common_drm_hwcomposer_cflags := \
    -Wall \
    -Werror \

# =====================
# libdrmhwc_utils.a
# =====================
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	worker.cpp

LOCAL_CFLAGS := $(common_drm_hwcomposer_cflags)

LOCAL_MODULE := libdrmhwc_utils
LOCAL_VENDOR_MODULE := true

include $(BUILD_STATIC_LIBRARY)

# =====================
# hwcomposer.drm.so
# =====================
include $(CLEAR_VARS)

LOCAL_SHARED_LIBRARIES := \
	libcutils \
	libdrm \
	libhardware \
	liblog \
	libsync \
	libui \
	libutils

LOCAL_STATIC_LIBRARIES := libdrmhwc_utils

LOCAL_C_INCLUDES := \
	external/drm_gralloc \
	system/core/libsync \
	include/android

LOCAL_SRC_FILES := \
	autolock.cpp \
	resourcemanager.cpp \
	drmdevice.cpp \
	drmconnector.cpp \
	drmcrtc.cpp \
	drmdisplaycomposition.cpp \
	drmdisplaycompositor.cpp \
	drmencoder.cpp \
	drmeventlistener.cpp \
	drmhwctwo.cpp \
	drmmode.cpp \
	drmplane.cpp \
	drmproperty.cpp \
	hwcutils.cpp \
	platform.cpp \
	vsyncworker.cpp

LOCAL_CFLAGS := $(common_drm_hwcomposer_cflags)

LOCAL_CPPFLAGS += \
	-DHWC2_USE_CPP11 \
	-DHWC2_INCLUDE_STRINGIFICATION

ifeq ($(TARGET_PRODUCT),xenvm)
LOCAL_CPPFLAGS += -DUSE_IMG_IMPORTER
LOCAL_SRC_FILES += platformimg.cpp 
else ifeq ($(TARGET_PRODUCT),hikey960)
LOCAL_CPPFLAGS += -DUSE_HISI_IMPORTER
LOCAL_SRC_FILES += platformhisi.cpp
LOCAL_C_INCLUDES += device/linaro/hikey/gralloc960/
else ifeq ($(TARGET_PRODUCT),hikey)
LOCAL_CPPFLAGS += -DUSE_HISI_IMPORTER
LOCAL_SRC_FILES += platformhisi.cpp
LOCAL_C_INCLUDES += device/linaro/hikey/gralloc/
else ifeq ($(strip $(BOARD_DRM_HWCOMPOSER_BUFFER_IMPORTER)),minigbm)
LOCAL_SRC_FILES += platformminigbm.cpp
LOCAL_C_INCLUDES += external/minigbm/cros_gralloc/
else
LOCAL_CPPFLAGS += -DUSE_DRM_GENERIC_IMPORTER
endif

ifneq ($(filter 2 3 4 5 6 7 8, $(DRM_HWC_ANDROID_MAJOR_VERSION)),)
LOCAL_CPP_FLAGS += -DHWC2_USE_OLD_GB_IMPORT
endif


LOCAL_MODULE := hwcomposer.$(TARGET_BOARD_PLATFORM)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := $(TARGET_SHLIB_SUFFIX)
LOCAL_VENDOR_MODULE := true

include $(BUILD_SHARED_LIBRARY)

include $(call all-makefiles-under,$(LOCAL_PATH))
endif
