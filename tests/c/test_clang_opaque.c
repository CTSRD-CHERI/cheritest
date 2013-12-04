/*-
 * Copyright (c) 2013 Michael Roe
 * All rights reserved.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "assert.h"

typedef __SIZE_TYPE__ size_t;

struct example {
  int x;
};

typedef __capability struct example *example_t;

static __capability void *example_key;

/* If we used the following declaration, the compiler would automatically
 * insert calls to csealdata and cunseal. Instead, we explicitly seal and
 * unseal using compiler built-ins.
 *
 * #pragma opaque example_t example_key
 */

static struct example example_object = {0};

static char *entry[] = {0};

void example_init(void)
{
/*
 * example_key will be used to seal and unseal variables of type example_t.
 * Initialize its otype field to &entry, like this: 
 */
  example_key = __builtin_cheri_set_cap_type((__capability void *) entry, 0);
}

example_t example_constructor(void)
{
  struct example *ptr;
  example_t result;

  ptr = &example_object;

  /*
   * csealdata can only be used to seal capabilities which don't have execute
   * permission, so here we explicitly take away execute permission from the
   * capability for example_object.
   */
  result = (example_t) __builtin_cheri_and_cap_perms((__capability void *) ptr,
    0xd);

  result = __builtin_cheri_seal_cap_data(result, example_key);

  return result;
}

int example_method(example_t o)
{
example_t p;

  p = __builtin_cheri_unseal_cap(o, example_key);
  p->x++;
  return p->x;
}

int test(void)
{
example_t e;
int r;

  example_init();
  e = example_constructor();
  r = example_method(e);
  assert(r == 1);

  return 0;
}
