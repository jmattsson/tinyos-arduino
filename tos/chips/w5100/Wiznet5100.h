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
#ifndef _WIZNET5100_H_
#define _WIZNET5100_H_

// Common Registers
enum {
  W5100_MR     = 0x0000,

  W5100_GAR0   = 0x0001,
  W5100_GAR1   = 0x0002,
  W5100_GAR2   = 0x0003,
  W5100_GAR3   = 0x0004,

  W5100_SUBR0  = 0x0005,
  W5100_SUBR1  = 0x0006,
  W5100_SUBR2  = 0x0007,
  W5100_SUBR3  = 0x0008,

  W5100_SHAR0  = 0x0009,
  W5100_SHAR1  = 0x000a,
  W5100_SHAR2  = 0x000b,
  W5100_SHAR3  = 0x000c,
  W5100_SHAR4  = 0x000d,
  W5100_SHAR5  = 0x000e,

  W5100_SIPR0  = 0x000f,
  W5100_SIPR1  = 0x0010,
  W5100_SIPR2  = 0x0011,
  W5100_SIPR3  = 0x0012,


  W5100_IR     = 0x0015,
  W5100_IMR    = 0x0016,

  W5100_RTR0   = 0x0017,
  W5100_RTR1   = 0x0018,
  W5100_RCR    = 0x0019,

  W5100_RMSR   = 0x001a,
  W5100_TMSR   = 0x001b,

  W5100_PATR0  = 0x001c,
  W5100_PATR1  = 0x001d,


  W5100_PTIMER = 0x0028,
  W5100_PMAGIC = 0x0029,

  W5100_UIPR0  = 0x002a,
  W5100_UIPR1  = 0x002b,
  W5100_UIPR2  = 0x002c,
  W5100_UIPR3  = 0x002d,

  W5100_UPORT0 = 0x002e,
  W5100_UPORT1 = 0x002f,
};


// Socket registers, base offsets
enum {
  W5100_S0 = 0x0400,
  W5100_S1 = 0x0500,
  W5100_S2 = 0x0600,
  W5100_S3 = 0x0700,
};

// Socket Registers, relative offsets
enum {
  W5100_Sn_MR     = 0x0000,
  W5100_Sn_CR     = 0x0001,
  W5100_Sn_IR     = 0x0002,
  W5100_Sn_SR     = 0x0003,

  W5100_Sn_PORT0  = 0x0004,
  W5100_Sn_PORT1  = 0x0005,

  W5100_Sn_DHAR0  = 0x0006,
  W5100_Sn_DHAR1  = 0x0007,
  W5100_Sn_DHAR2  = 0x0008,
  W5100_Sn_DHAR3  = 0x0009,
  W5100_Sn_DHAR4  = 0x000a,
  W5100_Sn_DHAR5  = 0x000b,

  W5100_Sn_DIPR0  = 0x000c,
  W5100_Sn_DIPR1  = 0x000d,
  W5100_Sn_DIPR2  = 0x000e,
  W5100_Sn_DIPR3  = 0x000f,

  W5100_Sn_DPORT0 = 0x0010,
  W5100_Sn_DPORT1 = 0x0011,

  W5100_Sn_MSSR0  = 0x0012,
  W5100_Sn_MSSR1  = 0x0013,

  W5100_Sn_PROTO  = 0x0014,

  W5100_Sn_TOS    = 0x0015,
  W5100_Sn_TTL    = 0x0016,


  W5100_Sn_TX_FSR0= 0x0020,
  W5100_Sn_TX_FSR1= 0x0021,

  W5100_Sn_TX_RD0 = 0x0022,
  W5100_Sn_TX_RD1 = 0x0023,

  W5100_Sn_TX_WR0 = 0x0024,
  W5100_Sn_TX_WR1 = 0x0025,

  W5100_Sn_RX_RSR0= 0x0026,
  W5100_Sn_RX_RSR1= 0x0027,

  W5100_Sn_RX_RD0 = 0x0028,
  W5100_Sn_RX_RD1 = 0x0029,
};


// Mode register flags
enum {
  W5100_MR_RST   = 7,
  W5100_MR_PB    = 4,
  W5100_MR_PPPOE = 3,
  W5100_MR_AI    = 1,
  W5100_MR_IND   = 0,
};


// Interrupt (and interrupt mask) register flags
enum {
  W5100_IR_CONFLICT = 7,
  W5100_IR_UNREACH  = 6,
  W5100_IR_PPPOE    = 5,

  W5100_IR_S3_INT   = 3,
  W5100_IR_S2_INT   = 2,
  W5100_IR_S1_INT   = 1,
  W5100_IR_S0_INT   = 0,
};


// RX memory size register values
enum {
  W5100_S3_SZ_1KB = 0x00,
  W5100_S3_SZ_2KB = 0x40,
  W5100_S3_SZ_4KB = 0x80,
  W5100_S3_SZ_8KB = 0xc0,
  W5100_S3_SZ_MASK = 0xc0,

  W5100_S2_SZ_1KB = 0x00,
  W5100_S2_SZ_2KB = 0x10,
  W5100_S2_SZ_4KB = 0x20,
  W5100_S2_SZ_8KB = 0x30,
  W5100_S2_SZ_MASK = 0x30,

  W5100_S1_SZ_1KB = 0x00,
  W5100_S1_SZ_2KB = 0x04,
  W5100_S1_SZ_4KB = 0x08,
  W5100_S1_SZ_8KB = 0x0c,
  W5100_S1_SZ_MASK = 0x0c,

  W5100_S0_SZ_1KB = 0x00,
  W5100_S0_SZ_2KB = 0x01,
  W5100_S0_SZ_4KB = 0x02,
  W5100_S0_SZ_8KB = 0x03,
  W5100_S0_SZ_MASK = 0x03,
};


// PPPoE auth mode register values
enum {
  W5100_PATR_PAP  = 0xc023,
  W5100_PATR_CHAP = 0xc223,
};


// Socket mode register flags
enum {
  W5100_Sn_MR_MULTI = 7,
  W5100_Sn_MR_MF    = 6,
  W5100_Sn_MR_NDMC  = 5,

  W5100_Sn_MR_PROTO_MASK   = 0x0f,
  W5100_Sn_MR_PROTO_CLOSED = 0x00,
  W5100_Sn_MR_PROTO_TCP    = 0x01,
  W5100_Sn_MR_PROTO_UDP    = 0x02,
  W5100_Sn_MR_PROTO_IPRAW  = 0x03,
  W5100_Sn_MR_PROTO_MACRAW = 0x04, // Socket 0 only
  W5100_Sn_MR_PROTO_PPPOE  = 0x05, // Socket 0 only
};


// Socket command register values
enum {
  W5100_Sn_CR_OPEN      = 0x01,
  W5100_Sn_CR_LISTEN    = 0x02,
  W5100_Sn_CR_CONNECT   = 0x04,
  W5100_Sn_CR_DISCON    = 0x08,

  W5100_Sn_CR_CLOSE     = 0x10,
  W5100_Sn_CR_SEND      = 0x20,
  W5100_Sn_CR_SEND_MAC  = 0x21,
  W5100_Sn_CR_SEND_KEEP = 0x22,
  W5100_Sn_CR_RECV      = 0x40,
};


// Socket interrupt register flags
enum {
  W5100_Sn_IR_SEND_OK   = 4,
  W5100_Sn_IR_TIMEOUT   = 3,
  W5100_Sn_IR_RECV      = 2,
  W5100_Sn_IR_DISCON    = 1,
  W5100_Sn_IR_CON       = 0,
};


// Socket status register values
enum {
  W5100_Sn_SR_SOCK_CLOSED      = 0x00,
  W5100_Sn_SR_SOCK_ARP         = 0x01,
  W5100_Sn_SR_SOCK_INIT        = 0x13,
  W5100_Sn_SR_SOCK_LISTEN      = 0x14,
  W5100_Sn_SR_SOCK_SYNSENT     = 0x15,
  W5100_Sn_SR_SOCK_SYNRECV     = 0x16,
  W5100_Sn_SR_SOCK_ESTABLISHED = 0x17,
  W5100_Sn_SR_SOCK_FIN_WAIT    = 0x18,
  W5100_Sn_SR_SOCK_CLOSING     = 0x1a,
  W5100_Sn_SR_SOCK_TIME_WAIT   = 0x1b,
  W5100_Sn_SR_SOCK_CLOSE_WAIT  = 0x1c,
  W5100_Sn_SR_SOCK_LAST_ACK    = 0x1d,
  W5100_Sn_SR_SOCK_UDP         = 0x22,
  W5100_Sn_SR_SOCK_IPRAW       = 0x32,
  W5100_Sn_SR_SOCK_MACRAW      = 0x42,
  W5100_Sn_SR_SOCK_PPPOE       = 0x5f,
};


#endif
