# SPDX-License-Identifier: Apache-2.0

wasmedge_add_executable(wasmedgeErrinfoTests
  errinfoTest.cpp
)

add_test(wasmedgeErrinfoTests wasmedgeErrinfoTests)

target_link_libraries(wasmedgeErrinfoTests
  PRIVATE
  ${GTEST_BOTH_LIBRARIES}
  wasmedgeCommon
)
