include(ExternalProject)

set(ZIPFILE "${CMAKE_CURRENT_LIST_DIR}/downloads/libwebrtc.zip")
set(DOWNLOAD_URL "https://github.com/flutter-webrtc/flutter-webrtc/releases/download/v1.3.0/libwebrtc.zip")

if(NOT EXISTS "${ZIPFILE}")
  message(NOTICE "download: ${DOWNLOAD_URL}")
    file(DOWNLOAD "${DOWNLOAD_URL}"
        ${ZIPFILE}
        STATUS download_status
        LOG download_log)

    if(NOT download_status EQUAL 0)
    message(FATAL_ERROR "Failed to download dependency: ${download_log}")
    endif()

    file(ARCHIVE_EXTRACT INPUT ${ZIPFILE} DESTINATION "${CMAKE_CURRENT_LIST_DIR}")
else()
  if(NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/libwebrtc")
    message(NOTICE "libwebrtc directory does not exist after extraction.")
    file(ARCHIVE_EXTRACT INPUT ${ZIPFILE} DESTINATION "${CMAKE_CURRENT_LIST_DIR}")
  endif()
  message(TRACE "libwebrtc already downloaded.")
endif()

