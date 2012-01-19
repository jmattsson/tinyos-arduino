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
}
implementation
{
  typedef struct list_node
  {
    size_t len;  // space available to user (i.e. excluding this field)
    struct list_node *next;  // link field, also start of user data when alloc'd
  } list_node_t;

  union {
    list_node_t first_node;
    char raw[pool_size];
  } pool = { { pool_size - sizeof (size_t), 0 } };

  list_node_t *free_list = &pool.first_node;


#ifdef VARIANT_POOL_DEBUG
  void dump_free_list (const char *where)
  {
    list_node_t *node = free_list;
    printf("free_list[%s]: ", where);
    for (; node; node = node->next)
    {
      printf("%u@%p->%p ", node->len, node, node->next);
    }
    printf("\r\n");
  }
#else
  #define dump_free_list(x)
#endif


  inline bool can_split (list_node_t *node, size_t newlen)
  {
    size_t min_size = sizeof (list_node_t *);
    return (newlen < node->len) &&
           (newlen > min_size) &&
           (node->len - newlen) > min_size;
  }

  inline void *node_to_data (list_node_t *node)
  {
    return &node->next;
  }

  inline list_node_t *data_to_node (void *p)
  {
    return (list_node_t *)(((char *)p) - sizeof (size_t));
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

  void merge_with_next (list_node_t *node)
  {
    if (node && end_of_node (node) == node->next)
    {
      node->len += node->next->len + sizeof (size_t);
      node->next = node->next->next;
    }
  }

  void link (list_node_t *node)
  {
    list_node_t **where = &free_list, *prev = 0;

    while (*where && node > *where)
    {
      prev = *where;
      where = &(*where)->next;
    }

    node->next = *where;
    *where = node;

    merge_with_next (node);
    merge_with_next (prev);
  }

  command void *VariantPool.alloc (size_t len)
  {
    list_node_t *cur, *best;

    if (!free_list)
      return 0;

    dump_free_list("alloc-in");

    best = free_list;
    for (cur = free_list->next; cur; cur = cur->next)
    {
      if (cur->len >= len && cur->len < best->len)
        best = cur;
    }

    if (best->len < len)
      return 0;

    unlink (best);

    // don't return unnecessarily large chunks
    call VariantPool.reduce (&best->next, len);

    dump_free_list("alloc-out");

    return node_to_data (best);
  }

  command void *VariantPool.reserve (size_t *actual_len)
  {
    list_node_t *cur, *best;
    if (!actual_len || !free_list)
      return 0;

    dump_free_list("reserve-in");

    best = free_list;
    for (cur = free_list->next; cur; cur = cur->next)
    {
      if (cur->len > best->len)
        best = cur;
    }

    unlink (best);

    dump_free_list("reserve-out");

    *actual_len = best->len;
    return node_to_data (best);
  }

  command void VariantPool.reduce (void *p, size_t newlen)
  {
    list_node_t *node = data_to_node (p);

    dump_free_list("reduce-in");

    // if we can't split this block, reduce is a no-op
    if (can_split (node, newlen))
    {
      list_node_t *fragment = (list_node_t *)((char *)p + newlen);
      fragment->len = node->len - newlen - sizeof (size_t);
      node->len = newlen;
      call VariantPool.release (node_to_data (fragment));
    }

    dump_free_list("reduce-out");
  }

  command void VariantPool.release (void *p)
  {
    list_node_t *node = data_to_node (p);

    dump_free_list("release-in");

    if (p)
      link (node);

    dump_free_list("release-out");
  }
}
