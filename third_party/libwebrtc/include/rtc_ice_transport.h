/*
 *  Copyright 2019 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef LIB_WEBRTC_RTC_ICE_TRANSPORT_H_
#define LIB_WEBRTC_RTC_ICE_TRANSPORT_H_

#include <string>

#include "api/async_dns_resolver.h"
#include "api/async_resolver_factory.h"
#include "api/rtc_error.h"
#include "api/rtc_event_log/rtc_event_log.h"
#include "api/scoped_refptr.h"
#include "rtc_base/ref_count.h"

namespace libwebrtc {
class IceTransport : public rtc::RefCountInterface {
 public:
  virtual IceTransport* internal() = 0;
};

class IceTransportInit final {
 public:
  IceTransportInit() = default;
  IceTransportInit(const IceTransportInit&) = delete;
  IceTransportInit(IceTransportInit&&) = default;
  IceTransportInit& operator=(const IceTransportInit&) = delete;
  IceTransportInit& operator=(IceTransportInit&&) = default;

  cricket::PortAllocator* port_allocator() { return port_allocator_; }
  void set_port_allocator(cricket::PortAllocator* port_allocator) {
    port_allocator_ = port_allocator;
  }

  AsyncDnsResolverFactoryInterface* async_dns_resolver_factory() {
    return async_dns_resolver_factory_;
  }
  void set_async_dns_resolver_factory(
      AsyncDnsResolverFactoryInterface* async_dns_resolver_factory) {
    RTC_DCHECK(!async_resolver_factory_);
    async_dns_resolver_factory_ = async_dns_resolver_factory;
  }
  AsyncResolverFactory* async_resolver_factory() {
    return async_resolver_factory_;
  }
  ABSL_DEPRECATED("bugs.webrtc.org/12598")
  void set_async_resolver_factory(
      AsyncResolverFactory* async_resolver_factory) {
    RTC_DCHECK(!async_dns_resolver_factory_);
    async_resolver_factory_ = async_resolver_factory;
  }

  RtcEventLog* event_log() { return event_log_; }
  void set_event_log(RtcEventLog* event_log) { event_log_ = event_log; }
};

class IceTransportFactory {
 public:
  virtual ~IceTransportFactory() = default;

  virtual scoped_refptr<IceTransport> CreateIceTransport(
      const std::string& transport_name, int component,
      IceTransportInit init) = 0;
};

}  // namespace libwebrtc
#endif  // API_ICE_TRANSPORT_INTERFACE_H_
