/*
 * Copyright (c) 2012 Johny Mattsson
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

interface HplW5100Socket
{
  /**
   * Enables multicast on a UDP socket.
   */
  async command void enableMulticast ();

  /**
   * Disables multicast option (UDP socket only).
   */
  async command void disableMulticast ();

  /**
   * @returns whether multicast is enabled.
   */
  async command bool getMulticast ();


  /**
   * Enables promiscuous mode (disables MAC filtering).
   */
  async command void enablePromiscuousMode ();

  /**
   * Disables promiscuous mode.
   */
  async command void disablePromiscuousMode ();

  /**
   * @returns whether promiscuous mode.
   */
  async command bool getPromiscuousMode ();


  /**
   * For TCP sockets, enables delayed ACK.
   */
  async command void enableDelayedAck ();

  /**
   * Disables delayed ACK (TCP socket only).
   */
  async command void disableDelayedAck ();

  /**
   * @returns whether delayed ACK is enabled.
   */
  async command bool getDelayedAck ();


  /**
   * For UDP sockets with multicasting enabled, sets IGMP version to 1.
   */
  async command void setIgmpV1 ();

  /**
   * For UDP sockets with multicasting enabled, sets IGMP version to 2.
   */
  async command void setIgmpV2 ();


  /**
   * Sets the socket procotol.
   * MACRAW and PPPoE protocols are only available on socket 0.
   *
   * @param proto The new socket protocol for this socket.
   */
  async command void setProtocol (uint8_t proto);

  /**
   * @returns the current socket protocol.
   */
  async command uint8_t getProtocol ();

 
  /**
   * Executes the given socket command.
   *
   * @param code The command code.
   */
  async command void executeCommand (uint8_t code);


  /**
   * @returns the current interrupt flags.
   */
  async command uint8_t getInterruptFlags ();

 
  /**
   * @returns the current socket status.
   */
  async command uint8_t getStatus ();


  /**
   * Sets the source port for a socket in TCP or UDP mode.
   *
   * @param port The port number.
   */
  async command void setSrcPort (in_port_t port);


  /**
   * @returns the current port number for a TCP or UDP socket.
   */
  async command in_port_t getSrcPort ();


  /**
   * Sets the destination MAC address.
   * Presumably only needed for MACRAW or PPPoE mode.
   *
   * @param addr The MAC address.
   */
  async command void setDstMacAddress (mac_addr_t addr);


  /**
   * @returns the configured destination MAC address.
   */
  async command mac_addr_t getDstMacAddress ();


  /**
   * Sets the destination IPv4 address for an IP socket.
   *
   * @param addr The destination address.
   */
  async command void setDstIPv4Address (in_addr_t addr);

  /**
   * @returns the destination IPv4 address for an IP socket.
   */
  async command in_addr_t getDstIPv4Address ();


  /**
   * Sets the destination port for an IP socket.
   *
   * @param port The destination port.
   */
  async command void setDstPort (in_port_t port);

  /**
   * @returns the destination port for an IP socket.
   */
  async command in_port_t getDstPort ();


  /**
   * Sets the Maximum Segment Size for a TCP socket.
   *
   * @param mss The MSS value.
   */
  async command void setMss (uint16_t mss);

  /**
   * @returns the MSS value. For a TCP server socket, this is from the client.
   */
  async command uint16_t getMss ();


  /**
   * For a socket in IPRAW mode, sets the IP protocol number.
   *
   * @param ip_proto The IP layer protocol.
   */
  async command void setIpRawProtocol (uint8_t ip_proto);

  /**
   * @returns the IP layer protocol for a socket in IPRAW mode.
   */
  async command uint8_t getIpRawProtocol ();


  /**
   * Sets the ToS field value for IP sockets.
   *
   * @param tos The ToS field value.
   */
  async command void setTypeOfService (uint8_t tos);

  /**
   * @returns the ToS field value.
   */
  async command uint8_t getTypeOfService ();


  /**
   * Sets the TTL field value for IP sockets.
   *
   * @param ttl The TTL field value.
   */
  async command void setTimeToLive (uint8_t ttl);

  /**
   * @returns the configured TTL value.
   */
  async command uint8_t getTimeToLive ();


  /**
   * @returns the available space in the TX buffer.
   */
  async command uint16_t getTxFreeSize ();


  /**
   * @returns the current TX read offset (equal to write pos offset when
   * all data has been sent).
   */
  async command uint16_t getTxReadOffs ();


  /**
   * Moves the TX write offset to indicate data is available for transfer.
   *
   * @param offs Offset to the next free byte in the TX buffer.
   */
  async command void setTxWriteOffs (uint16_t offs);

  /**
   * @returns the TX write offset (where data can be appended to be sent).
   */
  async command uint16_t getTxWriteOffs ();


  /**
   * @returns the received data size.
   */
  async command uint16_t getRxSize ();


  /**
   * Moves the RX read offset to indicate received data has been consumed.
   *
   * @param offs The offset of the next byte to be read.
   */
  async command void setRxReadOffs (uint16_t offs);

  /**
   * @returns the RX read offset.
   */
  async command uint16_t getRxReadOffs ();


  /**
   * Socket interrupt requested.
   */
  async event void interrupt ();
}
