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

#include "w5100.h"

interface HplW5100
{
  /**
   * Software reset.
   */
  async command void reset ();


  /**
   * Ignore ICMP ping requests.
   */
  async command void enablePingBlock ();

  /**
   * Respond to ICMP ping requests.
   */
  async command void disablePingBlock ();

  /**
   * @returns True if ping block mode is enabled.
   */
  async command bool getPingBlock ();


  /**
   * Enable PPPoE mode.
   */
  async command void enablePPPoE ();

  /**
   * Disable PPPoE mode.
   */
  async command void disablePPPoE ();

  /**
   * @returns True if PPPoE mode is enabled.
   */
  async command bool getPPPoE ();


  /**
   * Enable address auto-increment in Indirect Bus interface mode.
   */
  async command void enableAddressAutoInc ();

  /**
   * Disable address auto-increment in Indirect Bus interface mode.
   */
  async command void disableAddressAutoInc ();

  /**
   * @returns True if address auto-increment is enabled.
   */
  async command bool getAddressAutoInc ();


  /**
   * Enable Indirect Bus interface mode.
   */
  async command void enableIndirectBusMode ();

  /**
   * Disable Indirect Bus interface mode.
   */
  async command void disableIndirectBusMode ();

  /**
   * @returns True if Indirect Bus mode is enabled.
   */
  async command bool getIndirectBusMode ();


  /**
   * Sets the gateway IPv4 address.
   */
  async command void setGateway (in_addr_t gw);

  /**
   * @returns the gateway IPv4 address.
   */
  async command in_addr_t getGateway ();


  /**
   * Sets the IPv4 subnet mask.
   */
  async command void setSubnetMask (in_addr_t mask);

  /**
   * @returns the IPv4 subnet mask.
   */
  async command in_addr_t getSubnetMask ();


  /**
   * Sets the node IPv4 address.
   */
  async command void setIPv4Address (in_addr_t addr);

  /**
   * @returns the node IPv4 address.
   */
  async command in_addr_t getIPv4Address ();


  /**
   * Sets the MAC address.
   */
  async command void setMacAddress (mac_addr_t addr);

  /**
   * @returns the MAC address.
   */
  async command mac_addr_t getMacAddress ();


  /**
   * Clear the given interrupt flags (excl. socket flags).
   * @param flags the flags the clear.
   */
  async command void clearInterruptFlags (uint8_t flags);

  /**
   * @returns the current interrupt flags.
   */
  async command uint8_t getInterruptFlags ();


  /**
   * Sets the interrupt mask. High bits enable interrupts.
   * @param mask the new mask.
   */
  async command void setInterruptMask (uint8_t mask);

  /**
   * @return the current interrupt mask.
   */
  async command uint8_t getInterruptMask ();


  /**
   * Sets the retry interval.
   * @param val The retry interval, in units of 100us.
   */
  async command void setRetryInterval (uint16_t val);

  /**
   * @returns the retry interval, in units of 100us.
   */
  async command uint16_t getRetryInterval ();


  /**
   * Sets the retry count.
   * Exceeding the retry count raises socket timeout.
   * @param val the maximum number of retransmissions before giving up.
   */
  async command void setRetryCount (uint8_t val);

  /**
   * @returns the current retry count.
   */
  async command uint8_t getRetryCount ();


  /**
   * Sets socket receive buffer memory allocations/split.
   * Total chip memory is 8kb, allocations are in socket order 0->1->2->3.
   * Sockets with no (or insufficient) memory allocated can not be used.
   * @param rxms Socket receive buffer allocations.
   */
  async command void setSocketRxBufferSizes (uint8_t rxms);

  /**
   * @returns the current socket receive buffer memory allocations.
   */
  async command uint8_t getSocketRxBufferSizes ();


  /**
   * Sets socket transmit buffer memory allocations/split.
   * Total chip memory is 8kb, allocations are in socket order 0->1->2->3.
   * Sockets with no (or insufficient) memory allocated can not be used.
   * @param txms Socket transmit buffer allocations.
   */
  async command void setSocketTxBufferSizes (uint8_t txms);

  /**
   * @returns the current socket transmit buffer memory allocations.
   */
  async command uint8_t getSocketTxBufferSizes ();


  /**
   * Sets the PPPoE authentication type.
   * @param pap True if PAP auth used, false to use CHAP.
   */
  async command void setAuthType (bool pap);

  /**
   * @returns True if PAP auth is used, false if CHAP is used.
   */
  async command bool isAuthTypePap ();


  /**
   * Sets LCP Echo timer interval.
   * @param val Echo interval in units of 25ms.
   */
  async command void setLcpEchoInterval (uint8_t val);

  /**
   * @returns the LCP Echo interval, in units of 25ms.
   */
  async command uint16_t getLcpEchoInterval ();


  /**
   * @returns the IPv4 address from the last ICMP Destination Unreachable.
   */
  async command in_addr_t getLastUnreachableIPv4Address ();

  /**
   * @returns the port number from the last ICMP Destination Unreachable.
   */
  async command in_port_t getLastUnreachablePort ();


  /**
   * Interrupt requested.
   */
  async event void interrupt ();
}
