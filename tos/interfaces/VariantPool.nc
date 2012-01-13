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

/**
 * The VariantPool is an alternative to Pool and malloc(). It provides access
 * to a compile-time bounded memory area (unlike malloc), but unlike Pool
 * it allows allocations of varying sizes.
 *
 * Additionally, it provides the capability for allocations of unknown size
 * via the reserve() function. Calling reserve() allocates as much contiguous
 * memory in the pool that it can, and returns it and the actual size
 * allocated. When the desired size is learnt, the allocation can (and should)
 * then be reduced to said size by calling reduce(). This releases the excess
 * memory back into the pool. A typical use case for this is for formatting
 * buffers, where temporary memory is desired for short periods of time.
 *
 * Any memory obtained from alloc() or reserve() MUST be released back to the
 * pool through release(). Calling reduce(p, 0) is NOT a substitute.
 */
interface VariantPool
{
  /**
   * Allocates memory of the requested size from the pool, if possible.
   * Any memory allocated MUST Be returned to the pool by calling release().
   *
   * @param len The length (in bytes) of memory requested.
   * @return A pointer to the allocated memory, or zero if the allocation
   *  request could not be satisfied.
   */
  command void *alloc (size_t len);

  /**
   * Allocates as much contiguous memory from the pool as it can, possibly
   * the entirety of the pool. Memory allocated this way SHOULD be reduced
   * to the minimum required as soon as said minimum is discovered. This
   * SHOULD happen before the current task completes (as doing otherwise
   * might leave other tasks starved).
   *
   * @param actual_len A pointer to a length field where the actual allocation
   *  length will be stored. Only updated if memory is actually reserved.
   * @return A pointer to the allocated memory, or zero if the request could
   *  not be satisfied.
   */
  command void *reserve (size_t *actual_len);

  /**
   * Reduces previously reserved (or allocated) memory to a smaller size,
   * returning the excess memory to the pool.
   *
   * @param p Pointer to memory previously obtained from alloc() or reserve().
   * @param newlen The size to reduce the allocation to. It is not possible
   *  to increase the allocation by supplying a larger size than originally
   *  allocated.
   */
  command void reduce (void *p, size_t newlen);

  /**
   * Returns previously allocated memory to the pool.
   *
   * @param p The memory to return to the pool. MUST have been previously
   *  returned from alloc() or reserve().
   */
  command void release (void *p);
}
