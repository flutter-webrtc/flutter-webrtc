package com.cloudwebrtc.webrtc;

import static org.junit.Assert.assertEquals;

import com.cloudwebrtc.webrtc.utils.ConstraintsMap;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;
import org.webrtc.PeerConnection.IceServer;
import org.webrtc.PeerConnection.TlsCertPolicy;

public class IceServerTlsCertPolicyTest {
  private static IceServer build(Map<String, Object> entry) {
    return MethodCallHandlerImpl.buildIceServer(
        IceServer.builder("turns:turn.example.com:443"), new ConstraintsMap(entry));
  }

  @Test
  public void insecureNoCheckSkipsTheCheck() {
    Map<String, Object> entry = new HashMap<>();
    entry.put("tlsCertPolicy", "insecure_no_check");

    assertEquals(TlsCertPolicy.TLS_CERT_POLICY_INSECURE_NO_CHECK, build(entry).tlsCertPolicy);
  }

  @Test
  public void secureKeepsTheCheck() {
    Map<String, Object> entry = new HashMap<>();
    entry.put("tlsCertPolicy", "secure");

    assertEquals(TlsCertPolicy.TLS_CERT_POLICY_SECURE, build(entry).tlsCertPolicy);
  }

  @Test
  public void absentOrNullPolicyKeepsTheCheck() {
    assertEquals(TlsCertPolicy.TLS_CERT_POLICY_SECURE, build(new HashMap<>()).tlsCertPolicy);

    Map<String, Object> entry = new HashMap<>();
    entry.put("tlsCertPolicy", null);
    assertEquals(TlsCertPolicy.TLS_CERT_POLICY_SECURE, build(entry).tlsCertPolicy);
  }

  @Test
  public void appliesCredentialsWhenBothAreStrings() {
    Map<String, Object> entry = new HashMap<>();
    entry.put("username", "alice");
    entry.put("credential", "secret");

    IceServer server = build(entry);
    assertEquals("alice", server.username);
    assertEquals("secret", server.password);
  }

  @Test
  public void ignoresNullCredentials() {
    Map<String, Object> entry = new HashMap<>();
    entry.put("username", null);
    entry.put("credential", null);

    IceServer server = build(entry);
    assertEquals("", server.username);
    assertEquals("", server.password);
  }

  @Test
  public void unknownPolicyKeepsTheCheck() {
    Map<String, Object> entry = new HashMap<>();
    entry.put("tlsCertPolicy", "insecure-no-check");

    assertEquals(TlsCertPolicy.TLS_CERT_POLICY_SECURE, build(entry).tlsCertPolicy);
  }

  @Test
  public void nonStringPolicyKeepsTheCheck() {
    Map<String, Object> entry = new HashMap<>();
    entry.put("tlsCertPolicy", true);
    assertEquals(TlsCertPolicy.TLS_CERT_POLICY_SECURE, build(entry).tlsCertPolicy);

    // A Dart Uint8List arrives as byte[], a type ConstraintsMap.getType throws on.
    entry.put("tlsCertPolicy", new byte[] {1});
    assertEquals(TlsCertPolicy.TLS_CERT_POLICY_SECURE, build(entry).tlsCertPolicy);
  }

  @Test
  public void skipsCredentialsWhenOneIsNotAString() {
    Map<String, Object> entry = new HashMap<>();
    entry.put("username", "alice");
    entry.put("credential", 42);

    IceServer server = build(entry);
    assertEquals("", server.username);
    assertEquals("", server.password);
  }
}
