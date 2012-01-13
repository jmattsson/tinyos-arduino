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

generic module VariantPoolC(size_t pool_size)
{
  provides interface VariantPool;
  provides interface Init;
}
implementation
{
  typedef struct 
  {
    size_t len;         // space available to user (i.e. excluding this field)
    list_node_t *next;  // link field, also start of user data when alloc'd
  } list_node_t;

  char pool[pool_size];
  static alloc_t *free_list;

  inline bool can_split (list_node_t *node, size_t newlen)
  {
    return (newlen < node->len) && (node->len - newlen) >= sizeof (list_node_t);
  }

  inline void *node_to_data (list_node_t *node)
  {
    return &node->next;
  }

  inline void *end_of_node (list_node_t *node)
  {
    return (char *)node + node->len + sizeof (size_t);
  }

  void unlink (list_node_t *node)
  {
    list_node_t **where = &free_list;
    while (*where)
    {
      list_node_t *cur = *where;
      if (cur == node)
      {
        *where = cur->next;
        return;
      }
      else
        where = &cur->next;
    }
  }

  void link (list_node_t *node)
  {
    list_node_t *prev;
    for (prev = free_list; prev; prev = prev->next)
    {
      if (node > prev)
      {
        if (end_of_node (prev) == node)
        {
          // merge with previous node
          prev->len += node->len + sizeof (size_t);
        }
        else if (end_of_node (node) == prev->next)
        {
          // merge next node with this, and replace this node
          node->len += prev->next->len + sizeof (size_t);
          prev->next = node;
        }
        else
        {
          node->next = prev->next;
          prev->next = node;
        }
        return;
      }
    }
  }


  command error_t Init.init ()
  {
    list_node_t *node = (list_node_t *)pool;
    node->len = pool_size - sizeof (size_t);
    node->next = 0;
    free_list = node;
  }

  command void *VariantPool.alloc (size_t len)
  {
    list_node_t *cur, *best;

    if (!free_list)
      return 0;

    best = free_list;
    for (cur = free_list->next; cur; cur = cur->next)
    {
      if (cur->len >= len && cur->len < best->len)
        best = cur;
    }

    if (best->len < len)
      return 0;

    // don't return unnecessarily large chunks
    call VariantPool.reduce (&best->next, len);

    unlink (best);

    return node_to_data (best);
  }

  command void *VariantPool.reserve (size_t *actual_len)
  {
    list_node_t *cur, *best;
    if (!actual_len || !free_list)
      return 0;

    best = free_list;
    for (cur = free_list->next; cur; cur = cur->next)
    {
      if (cur->len > best->len)
        best = cur;
    }

    unlink (best);

    *actual_len = best->len;
    return node_to_data (best);
  }

  command void VariantPool.reduce (void *p, size_t newlen)
  {
    list_node_t *node = p;

    // if we can't split this block, reduce is a no-op
    if (can_split (node, newlen))
    {
      list_node_t *fragment = (list_node_t *)((char *)p + newlen);
      fragment->len = node->len - newlen - sizeof (size_t);
      node->len = newlen;
      call VariantPool.release (fragment);
    }
  }

  command void VariantPool.release (void *p)
  {
    list_node_t *node = (list_node_t *)p;

    if (node)
      link (node);
  }
}
